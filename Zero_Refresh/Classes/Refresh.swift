//
//  Refresh.swift
//  MJRefresh
//
//  Created by ZeroJian on 2019/5/10.
//

import Foundation
import RefreshInterpreter


public class Refresh<ModelType>: RefreshInterpreter<ModelType> {
    
    public init(refreshView: UIScrollView) {
        super.init(refreshView: refreshView, bridge: MJRefreshBridge())
    }
    
    var mjBridge: MJRefreshBridge? {
        return self.bridge as? MJRefreshBridge
    }
    
    
    public var noMoreDataText: String? {
        didSet {
            mjBridge?.noMoreDataText = noMoreDataText
        }
    }
    
    
    /// 加载提示颜色
    public var indicatorStyle: UIActivityIndicatorView.Style = .gray {
        didSet {
            mjBridge?.indicatorStyle = indicatorStyle
        }
    }

    
    
    
}
