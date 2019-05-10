//
//  SpinnerRefreshView.swift
//
//  Created by ZeroJianMBP on 2018/12/24.
//  Copyright © 2018 ZeroJian. All rights reserved.
//

import UIKit
import RefreshInterpreter

extension RefreshInterpreter {
    
    /// 显示首次刷新覆盖视图
    /// inView: 显示的视图
    public func showFirstSpinnerView(inView view: UIView?) {
        let toView = view ?? self.refreshView
        let spinnerRefreshView = SpinnerRefreshView.init(toView: toView, style: .custom)
        addStatusPlug(plug: spinnerRefreshView)
    }
    
}

public class SpinnerRefreshView: NetworkStatusView {
    
    var isFinished = false
    
}

extension SpinnerRefreshView: RefreshStatusPlug {
    
    public func appearanceStatus<R>(_ refresh: RefreshInterpreter<R>, status: RefreshStatus) -> Bool {
        if isFinished {
            return true
        }
        switch status {
        case .loading:
            refresh.stopHeaderRefresh()
            show(status: .loading)
        case .finished:
            isFinished = true
            show(status: .success)
        case .failure(let info, let handle):
            let failureInfo: NetworkStatusView.FailureInfo = (info == "请求超时", info == "请检查网络", info)
            show(status: .failure(failureInfo, handle))
        }
        
        return true
    }
}
