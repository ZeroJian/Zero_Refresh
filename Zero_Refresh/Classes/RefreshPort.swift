//
//  RefreshPort.swift
//  MJRefresh
//
//  Created by ZeroJian on 2019/5/9.
//

import Foundation

public protocol RefreshPort {
    
    func port_makeHeader<R>(refresh: Refresh<R>)
    
    func prot_makeFooter<R>(refresh: Refresh<R>)
    
    
    func port_headerRefreshAction<R>(refresh: Refresh<R>)
    
    func port_footerRefreshAction<R>(refresh: Refresh<R>)
    
    
    
    func port_endRefresh<R>(refresh: Refresh<R>, page: Int, isFailure: Bool)
    
    
    
}
