//
//  MjRefreshBridge.swift
//  MJRefresh
//
//  Created by ZeroJian on 2019/5/10.
//

import Foundation
import MJRefresh
import RefreshInterpreter

public class MJRefreshBridge: BridgePort {
    
    /// 没有更多数据提示 默认为空
    public var noMoreDataText: String?

    
    /// 加载提示颜色
    public var indicatorStyle: UIActivityIndicatorView.Style = .gray
    
    public var indicatorStyleColor: UIColor {
        switch indicatorStyle {
        case .white, .whiteLarge:
            return .white
        case .gray:
            return UIColor.init(red: 171.0/255.0, green: 171.0/255.0, blue: 171.0/255.0, alpha: 1.0)
        @unknown default:
            return .white
        }
    }

    
    public func port_makeHeader<R>(refresh: RefreshInterpreter<R>, action: (() -> Void)?) {
        let header = MJRefreshNormalHeader(refreshingBlock: {
            action?()
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
        
        refresh.refreshView.mj_header = header
    }
    
    public func port_makeFooter<R>(refresh: RefreshInterpreter<R>, action: (() -> Void)?) {
        let footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            action?()
        })
        
        footer?.setTitle("", for: .idle)
        footer?.setTitle("", for: .pulling)
        footer?.setTitle(noMoreDataText ?? "", for: .noMoreData)
        footer?.setTitle("", for: .refreshing)
        footer?.setTitle("", for: .willRefresh)
        footer?.labelLeftInset = 0
        footer?.stateLabel.textColor = indicatorStyleColor
        footer?.activityIndicatorViewStyle  = indicatorStyle
        
        refresh.refreshView.mj_footer = footer
    }
    
    
    
    
    public func port_headerRefreshAction<R>(refresh: RefreshInterpreter<R>) {
        refresh.refreshView.mj_header.beginRefreshing()
    }
    
    public func port_footerRefreshAction<R>(refresh: RefreshInterpreter<R>) {
    }
    
    public func port_headerStopRefreshAaction<R>(refresh: RefreshInterpreter<R>) {
        refresh.refreshView.mj_header.endRefreshing()
    }
    
    public func port_footerStopRefreshAaction<R>(refresh: RefreshInterpreter<R>) {
        refresh.refreshView.mj_footer.endRefreshing()
    }
    
    public func port_endRefresh<R>(refresh: RefreshInterpreter<R>, page: Int, isFailure: Bool) {
        refresh.refreshView.mj_header?.state = .idle
        refresh.refreshView.mj_footer?.state = refresh.noMoreData ? .noMoreData : .idle
    }
    
    
}
