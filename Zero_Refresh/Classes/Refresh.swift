//
//  RefreshManager.swift
//
//  Created by ZeroJianMBP on 2017/2/22.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import MJRefresh
import Foundation

public typealias RefreshPageHandle = (Int) -> Void

/// 状态外观
public enum AppearanceStatus {
	/// 加载中
	case loading
	/// 完成
	case finished
	/// 请求失败(错误提示, 点击重新请求闭包)
	case failure(String, (() -> Void)?)
}

/// 首次请求显示外观协议
public protocol RefreshStatusViewAppearance {
	func appearanceStatus(_ status: AppearanceStatus)
}

/// 数据为空显示外观协议
public protocol EmptyDataAppearance {
	func showEmptyAppearance(isHidden: Bool)
}

//////////////////////////////////////////////////////////////////////////
public class Refresh<ModelType> {
	
    
    /// 外部网络请求成功后 closure
    /// success: 成功后回调, Int: 服务器返回的 totalCount, []: 数组数组
    /// failure: 请求错误回调:
	public typealias RequestResult = (success: ((Int?, [ModelType]) -> Void)?, failure: ((String) -> Void)?)

	/// 第几页
    public var page = 1
    
    /// 初始页数
    public var beginPage = 1
	
	/// 一页请求多少条数据
    public var pageSize = 20
	
	/// 服务器获取的数量总数
    public var totalCount: Int = 0
	
	/// 刷新结果
    public var dataArray: [ModelType] = []
	
	/// 是否显示头
    public var isShowHeadRefreshView: Bool = false
	
	/// 底部是否显示
    public var mjFooterIsShow: Bool = true {
        didSet { refreshView.mj_footer?.isHidden = !mjFooterIsShow }
    }
    
    /// 总是显示加载失败的视图 默认是 true
    public var isAllowShowFailedStateView: Bool = true
	
	/// 没有更多数据提示 默认为空
	public var noMoreDataText: String?
	
	/// 是否已经请求过一次
    public private(set) var hasAlreadyCompletedReuqest: Bool = false
	
	/// 加载提示颜色
	public var indicatorStyle: UIActivityIndicatorView.Style = .gray
	
	public var indicatorStyleColor: UIColor {
		switch indicatorStyle {
		case .white, .whiteLarge:
			return .white
		case .gray:
			return UIColor.init(red: 171.0/255.0, green: 171.0/255.0, blue: 171.0/255.0, alpha: 1.0)
		}
	}
    
    public var port: RefreshPort
	
	/// 初始化方法, ModeType 泛型传入 Model 类型
	///
	/// - Parameters:
	///   - tableView: 传入要刷新的 tableView
	///   - parseAction: 解析 model closer, 外部处理解析
    public init(refreshView: UIScrollView, port: RefreshPort) {
		self.refreshView = refreshView
        self.port = port
		configHeader()
	}
	
	
	/// 设置外观 (首次请求显示)
	///
	/// - Parameters:
	///   - statusAppearance: 首次请求显示外观
	public func makeAppearance<StatusA: RefreshStatusViewAppearance>(statusAppearance: StatusA) {
		self.statusViewAppearance?.appearanceStatus(.finished)
		self.statusViewAppearance = nil
		self.statusViewAppearance = statusAppearance
	}
	
	
	/// 设置外观 (空数据)
	///
	/// - Parameters:
	///   - emptyAppearance: 数据为空显示外观
	public func makeAppearance<EmptyA: EmptyDataAppearance>(emptyAppearance: EmptyA) {
		self.emptyAppearance?.showEmptyAppearance(isHidden: true)
		self.emptyAppearance = nil
		self.emptyAppearance = emptyAppearance
	}
	
    /// 开始列表刷新
    ///
    /// - Parameters:
    ///   - pageHandle: 每次网络请求的闭包,如果每次刷新可能网络参数有改动可以写在闭包里面,默认为空不调用
    ///   - beginPage: 起始 page 默认 1
    ///   - pageSize: default 20
	public func configRefresh(pageHandle: RefreshPageHandle? = nil, beginPage: Int = 1, pageSize: Int = 20) {
		refreshPageHandle = pageHandle
		self.page = beginPage
		self.pageSize = pageSize
        self.beginPage = beginPage
	}
    	
	public func requestHandle(action: @escaping (Int, RequestResult) -> Void) {
		requestAction = action
	}

	/// 主动刷新数据
	public func beginRefresh() {
		refreshView.mj_header.beginRefreshing()
	}
	
    /// 更新 models 并且设置 page 与 mj_footer
    public func updateValues(_ models: [ModelType]) {
        self.dataArray = models
        if models.count >= pageSize {
            self.page = Int(ceil(Double(models.count)/Double(pageSize)))
            self.showLoadMoreControl()
        }
    }
	
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////
	public fileprivate(set) var noMoreData: Bool = false // 没有更多数据了
	public fileprivate(set) var refreshView: UIScrollView
	public fileprivate(set) var refreshPageHandle: RefreshPageHandle?
	
	public fileprivate(set) var statusViewAppearance: RefreshStatusViewAppearance?
	public fileprivate(set) var emptyAppearance: EmptyDataAppearance?
	
	public fileprivate(set) var requestAction: ((Int, RequestResult) -> Void)?
	
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

//MARK: - 处理上下拉刷新
extension Refresh {
    
    fileprivate func configHeader() {
		
        let header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            guard let `self` = self else { return }
            self.page = self.beginPage
            self.loadNewData(withPage: self.beginPage)
        })
        
        header?.isAutomaticallyChangeAlpha = true
		header?.lastUpdatedTimeText = { date in
			return nil
		}
        
		header?.setTitle("", for: .idle)
        header?.setTitle("", for: .pulling)
        header?.setTitle("", for: .noMoreData)
        header?.setTitle("", for: .refreshing)
        header?.setTitle("", for: .willRefresh)
		header?.labelLeftInset = 0
        header?.lastUpdatedTimeLabel.isHidden = true
		header?.stateLabel.textColor = indicatorStyleColor
		header?.activityIndicatorViewStyle  = indicatorStyle
        
        refreshView.mj_header = header
    }
    
    fileprivate func loadNewData(withPage page: Int) {
		refreshPageHandle?(page)
        
        /// ???
//        if let statusViewAppearance = statusViewAppearance {
//            statusViewAppearance.appearanceStatus(.loading)
//        }
        statusViewAppearance?.appearanceStatus(.loading)
		
		let suceessAction: (Int?, [ModelType]) -> Void = { [weak self] (totalCount, modelArr) in
			self?.requestSuccess(pageIndex: page, modelArr: modelArr, totalCount: totalCount)
		}
		let failureAction: (String) -> Void = { [weak self] failure in
			self?.requestFailure(pageIndex: page, failure: failure)
		}
		
		let requestClosure: RequestResult = (success: suceessAction, failure: failureAction)
		
		requestAction?(page, requestClosure)
		
        /// ???
//        if statusViewAppearance != nil {
//            refreshView.mj_header.endRefreshing()
//        }
    }
    
	fileprivate func showLoadMoreControl() {
        
        let mjFooter = refreshView.mj_footer ?? {
            
            let footer = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
                guard let `self` = self else { return }
                
                if self.noMoreData {
                    self.endRefreshing(withPage: self.page)
                } else {
                    self.loadNewData(withPage: self.page)
                }
            })
			
			footer?.stateLabel.textColor = indicatorStyleColor
            footer?.setTitle("", for: .idle)
            footer?.setTitle("", for: .pulling)
            footer?.setTitle(noMoreDataText ?? "", for: .noMoreData)
            footer?.setTitle("", for: .refreshing)
            footer?.setTitle("", for: .willRefresh)
            footer?.labelLeftInset = 0
            footer?.stateLabel.textColor = indicatorStyleColor
            footer?.activityIndicatorViewStyle  = indicatorStyle

            self.refreshView.mj_footer = footer
            return footer!
            }()
	
		if mjFooterIsShow {
            mjFooter.isHidden = dataArray.isEmpty
        } else {
            mjFooter.isHidden = true
		}
    }
    
    fileprivate func endRefreshing(withPage page: Int, isRequestFailure: Bool = false) {
        
        if isShowHeadRefreshView {
            refreshView.mj_header?.state = .idle
        } else {
            refreshView.mj_header?.state = .noMoreData
            refreshView.mj_header?.isHidden = true
        }
		
        refreshView.mj_footer?.state = noMoreData ? .noMoreData : .idle
//        if let customNoMoreDataText = self.customNoMoreDataText,
//            let footer = refreshView.mj_footer as? MJRefreshAutoNormalFooter, noMoreData {
//                footer.setTitle(customNoMoreDataText, for: .noMoreData)
//        }
		
		
		if !isRequestFailure{
			emptyAppearance?.showEmptyAppearance(isHidden: !dataArray.isEmpty )
		}
    }
}

//MARK: - 网络请求回调
extension Refresh {
	
	fileprivate func reloadData() {
		if let view = refreshView as? UICollectionView {
			view.reloadData()
		} else if let view = refreshView as? UITableView {
			view.reloadData()
		}
	}
	
	fileprivate func requestFailure(pageIndex: Int, failure: String) {
		
		hasAlreadyCompletedReuqest = true
		
			if isAllowShowFailedStateView {
				statusViewAppearance?.appearanceStatus(.failure(failure, { [weak self] in
					self?.beginRefresh()
				}))
			}
			else {
				statusViewAppearance?.appearanceStatus(.finished)
				statusViewAppearance = nil
			}
		
		endRefreshing(withPage: pageIndex, isRequestFailure: true)
		
	}
    
	fileprivate func requestSuccess(pageIndex:Int, modelArr: [ModelType], totalCount: Int?) {
        
        hasAlreadyCompletedReuqest = true
		
        // 数据总数
        
        /// 如果当前 page 是初始 page, 移除数组所有内容
        if pageIndex == beginPage {
            dataArray.removeAll()
        }
        
        dataArray.append(contentsOf: modelArr)
        
        if let totalCount = totalCount  {
            self.totalCount = totalCount
        } else {
            self.totalCount = dataArray.count
        }
        
        // 显示是否有更多数据
        if let total = totalCount {
            noMoreData = dataArray.count >= total
        } else {
            noMoreData = modelArr.count != pageSize // || page == totalPage
        }

        
        if !noMoreData {
            page += 1
        }
        
        showLoadMoreControl()
        reloadData()
        
        endRefreshing(withPage: pageIndex)
		
		statusViewAppearance?.appearanceStatus(.finished)
		statusViewAppearance = nil
    }
    
}
