//
//  EmptyRefreshView.swift
//
//  Created by ZeroJianMBP on 2018/4/3.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
//import RefreshInterpreter

extension RefreshInterpreter {
	
	
	/// 显示数据为空 lable 和 imageView
	///
	/// - Parameters:
	///   - lableText: text
	///   - imageName:  图片名称
	///   - imageRatio: 图片宽度相对 RefreshView 宽度比例
	public func makeEmptyView(lableText: String, imageName: String? = nil, imageRatio: CGFloat = 0.5 ) {
		let emptyView = EmptyRefreshView(toView: self.refreshView)
        _ = emptyView.showLabel(text: lableText, textColor: .lightGray)
		if let imageName = imageName {
			_ = emptyView.showImage(name: imageName, ratio: imageRatio)
		}
        addStatusPlug(plug: emptyView)
	}
	
	
	/// 显示数据为空 button
	///
	/// - Parameter button: 传入的 button
	public func makeEmptyButton(button: UIButton) {
		let emptyView = EmptyRefreshView(toView: self.refreshView)
		_ = emptyView.addButton(button: button)
        addStatusPlug(plug: emptyView)
	}
}

/// 遵循 RefreshStatusPlug 协议的刷新 View
public class EmptyRefreshView {
	
	fileprivate var refreshView: UIView
	
	fileprivate var emptyLable: UILabel?
	fileprivate var emptyImageView: UIImageView?
	fileprivate var emptyButton: UIButton?
	
	fileprivate var emptyImageViewRatio: CGFloat = 0.5
	
	
	public init(toView view: UIView) {
		self.refreshView = view
	}
}

extension EmptyRefreshView {
	
	public func showLabel(text: String, textColor: UIColor = .white) -> Self {
		makeLabel(withText: text, textColor: textColor)
		return self
	}
	
	public func showImage(name: String, ratio: CGFloat = 0.5) -> Self {
		makeImageView(imageName: name)
		emptyImageViewRatio = ratio > 1.0 ? 1.0 : ratio
		return self
	}
	
	public func addButton(button: UIButton) -> Self {
		
		if emptyButton != nil {
			emptyButton = button
			emptyButton?.isHidden = true
		}
		
		let toView: UIView = refreshView
        button.center.x = toView.center.x
        button.center.y = toView.center.y
        
        if button.bounds.size == .zero {
            button.bounds.size.height = 35
            button.bounds.size.width = 100
        }
        
		toView.addSubview(button)
		button.isHidden = true
		emptyButton = button
		return self
	}
}

extension EmptyRefreshView: RefreshStatusPlug {
    
    public func appearanceStatus<R>(_ refresh: RefreshInterpreter<R>, status: RefreshStatus) -> Bool {
        switch status {
        case .loading, .failure(_, _):
            emptyLable?.isHidden = true
            emptyImageView?.isHidden = true
            emptyButton?.isHidden = true

        case .finished:
            emptyLable?.isHidden = !refresh.dataSource.isEmpty
            emptyImageView?.isHidden = !refresh.dataSource.isEmpty
            emptyButton?.isHidden = !refresh.dataSource.isEmpty
        }
        
        return true
    }
}


extension EmptyRefreshView {
	
	fileprivate var imageHeight: CGFloat {
		return (self.refreshView.superview?.bounds.width ?? self.refreshView.bounds.width) * self.emptyImageViewRatio
	}
	
	fileprivate func makeLabel(withText text: String, textColor: UIColor) {
		
		if emptyLable != nil {
			emptyLable?.text = text
			return
		}
		
		let label = UILabel()
		label.text = text
		label.numberOfLines = 0
		label.textColor = textColor
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 14)
        let toView: UIView = refreshView
        
        let size = label.sizeThatFits(CGSize(width: toView.bounds.width - 30, height: 1000))
        
        label.center.x = toView.center.x
        label.center.y = toView.center.y
        label.bounds.size.width = toView.bounds.width - 30
        label.bounds.size.height = size.height
        toView.addSubview(label)
        
		
		label.isHidden = true
		emptyLable = label
	}
	
	fileprivate func makeImageView(imageName: String) {
		
		if emptyImageView != nil {
			emptyImageView?.image = UIImage(named: imageName)
			return
		}
		
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		imageView.image = UIImage(named: imageName)
		
		let toView: UIView = refreshView
        
        imageView.center.x = toView.center.x
        imageView.center.y = toView.center.y + (-imageHeight / 2 - 10)
        imageView.bounds.size.width = imageHeight
        imageView.bounds.size.height = imageHeight
		toView.addSubview(imageView)
				
		imageView.isHidden = true
		emptyImageView = imageView
	}
	
}
