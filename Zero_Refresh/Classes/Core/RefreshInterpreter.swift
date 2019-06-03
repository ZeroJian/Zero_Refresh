//
//  RefreshInterpreter.swift
//  Pods-RefreshInterpreter_Example
//
//  Created by ZeroJian on 2019/5/10.
//

import UIKit

/// 刷新状态
public enum RefreshStatus {
    /// 加载刷新中
    case loading
    /// 完成
    case finished
    /// 请求失败(错误提示, 点击重新请求闭包)
    case failure(String, (() -> Void)?)
}

/// 刷新状态插件
public protocol RefreshStatusPlug {
    func appearanceStatus<R>(_ refresh: RefreshInterpreter<R>, status: RefreshStatus) -> Bool
}

open class RefreshInterpreter<ModelType> {
    
    public typealias RefreshPageHandle = (Int) -> Void
    
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
    public var dataSource: [ModelType] = []
    
    /// 是否已经请求过一次
    public private(set) var hasAlreadyCompletedReuqest: Bool = false
    
    
    /// 初始化方法, ModeType 泛型传入 Model 类型
    ///
    /// - Parameters:
    ///   - refreshView: 传入要刷新的 tableView
    ///   - bridge: 封装的刷新组件 例如 MJRefresh
    public init(refreshView: UIScrollView, bridge: BridgePort) {
        self.refreshView = refreshView
        self.bridge = bridge
        configHeader()
        configFooter()
    }
    
    
    /// 添加插件
    ///
    /// - Parameters:
    ///   - pulg: 添加插件对象
    public func addStatusPlug<Status: RefreshStatusPlug>(plug: Status) {
        self.statusPlugs.append(plug)
    }
    
    
    /// 添加插件数组(会清空已经存在的插件)
    ///
    /// - Parameter plugs: 插件
    public func makeStatusPlugs<Status: RefreshStatusPlug>(plugs: [Status]) {
        self.statusPlugs.forEach({ _ = $0.appearanceStatus(self, status:  .finished) })
        self.statusPlugs.removeAll()
        self.statusPlugs = plugs
    }
    
    /// 配置基础数据
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
    
    /// 刷新中请求数据
    /// 通过 closure 返回数据后结束刷新
    /// closure: Int 当前 page
    /// closure: RequestResult.success - 成功后回调, Int: 服务器返回的 totalCount, []: 数组数组
    /// closure: RequestResult.failure - 请求错误回调:
    public func requestHandle(action: @escaping (Int, RequestResult) -> Void) {
        requestAction = action
    }
    
    /// 主动刷新数据
    public func beginRefresh() {
        bridge.port_headerRefreshAction(refresh: self)
    }
    
    public func stopHeaderRefresh() {
        bridge.port_headerStopRefreshAaction(refresh: self)
    }
    
    public func stopFooterRefresh() {
        bridge.port_footerStopRefreshAaction(refresh: self)
    }
    
    /// 更新 models 并且设置 page 与 mj_footer
    public func updateValues(_ models: [ModelType]) {
        self.dataSource = models
        
        page = Int(ceil(Double(models.count)/Double(pageSize))) + beginPage
        
        reloadData()
        
        endRefreshing(withPage: page)
        
        statusPlugs.forEach({
            _ = $0.appearanceStatus(self, status: .finished)
        })
    }
    
    
    public fileprivate(set) var noMoreData: Bool = false // 没有更多数据了
    
    public fileprivate(set) var refreshView: UIScrollView
    public fileprivate(set) var bridge: BridgePort
    
    public fileprivate(set) var refreshPageHandle: RefreshPageHandle?
    
    public fileprivate(set) var statusPlugs: [RefreshStatusPlug] = []
    
    public fileprivate(set) var requestAction: ((Int, RequestResult) -> Void)?
    
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

//MARK: - 处理上下拉刷新
extension RefreshInterpreter {
    
    fileprivate func configHeader() {
        bridge.port_makeHeader(refresh: self, action: { [weak self] in
            guard let `self` = self else { return }
            self.page = self.beginPage
            self.loadNewData(withPage: self.beginPage)
        })
    }
    
    fileprivate func configFooter() {
        bridge.port_makeFooter(refresh: self) { [weak self] in
            guard let `self` = self else { return }
            
            if self.noMoreData {
                self.endRefreshing(withPage: self.page)
            } else {
                self.loadNewData(withPage: self.page)
            }
        }
    }
    
    fileprivate func loadNewData(withPage page: Int) {
        refreshPageHandle?(page)
        
        statusPlugs.forEach({
            _ = $0.appearanceStatus(self, status: .loading)
        })
        
        let suceessAction: (Int?, [ModelType]) -> Void = { [weak self] (totalCount, modelArr) in
            self?.requestSuccess(pageIndex: page, modelArr: modelArr, totalCount: totalCount)
        }
        let failureAction: (String) -> Void = { [weak self] failure in
            self?.requestFailure(pageIndex: page, failure: failure)
        }
        
        let requestClosure: RequestResult = (success: suceessAction, failure: failureAction)
        
        requestAction?(page, requestClosure)
    }
    
    fileprivate func endRefreshing(withPage page: Int, isRequestFailure: Bool = false) {
        bridge.port_endRefresh(refresh: self, page: page, isFailure: isRequestFailure)
    }
}

//MARK: - 网络请求回调
extension RefreshInterpreter {
    
    fileprivate func reloadData() {
        if let view = refreshView as? UICollectionView {
            view.reloadData()
        } else if let view = refreshView as? UITableView {
            view.reloadData()
        }
    }
    
    fileprivate func requestFailure(pageIndex: Int, failure: String) {
        
        hasAlreadyCompletedReuqest = true
        
        endRefreshing(withPage: pageIndex, isRequestFailure: true)
        
        statusPlugs.forEach({
            _ = $0.appearanceStatus(self, status: .failure(failure, { [weak self] in
                self?.beginRefresh()
            }))
        })
    }
    
    fileprivate func requestSuccess(pageIndex:Int, modelArr: [ModelType], totalCount: Int?) {
        
        hasAlreadyCompletedReuqest = true
        
        // 数据总数
        
        /// 如果当前 page 是初始 page, 移除数组所有内容
        if pageIndex == beginPage {
            dataSource.removeAll()
        }
        
        dataSource.append(contentsOf: modelArr)
        
        if let totalCount = totalCount  {
            self.totalCount = totalCount
        } else {
            self.totalCount = dataSource.count
        }
        
        // 显示是否有更多数据
        if let total = totalCount {
            noMoreData = dataSource.count >= total
        } else {
            noMoreData = modelArr.count != pageSize // || page == totalPage
        }
        
        
        if !noMoreData {
            page += 1
        }
        
        reloadData()
        
        endRefreshing(withPage: pageIndex)
        
        statusPlugs.forEach({
            _ = $0.appearanceStatus(self, status: .finished)
        })
    }
    
}
