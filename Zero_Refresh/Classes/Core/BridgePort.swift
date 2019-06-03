//
//  BridgePort.swift
//  Pods-RefreshInterpreter_Example
//
//  Created by ZeroJian on 2019/5/10.
//

import Foundation

public protocol BridgePort {
    
    /// 配置 Header
    func port_makeHeader<R>(refresh: RefreshInterpreter<R>, action: (() -> Void)?)
    
    /// 配置 Footer
    func port_makeFooter<R>(refresh: RefreshInterpreter<R>, action: (() -> Void)?)
    
    /// 头部刷新动作
    func port_headerRefreshAction<R>(refresh: RefreshInterpreter<R>)
    
    /// 停止头部刷新动作
    func port_headerStopRefreshAaction<R>(refresh: RefreshInterpreter<R>)
    
    /// 底部刷新动作(暂时无用)
    func port_footerRefreshAction<R>(refresh: RefreshInterpreter<R>)
    
    /// 停止底部刷新动作
    func port_footerStopRefreshAaction<R>(refresh: RefreshInterpreter<R>)

    
    /// 刷新结束时
    func port_endRefresh<R>(refresh: RefreshInterpreter<R>, page: Int, isFailure: Bool)
    
}
