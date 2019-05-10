//
//  EmptyRefreshView.swift
//
//  Created by ZeroJianMBP on 2018/4/3.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

extension RefreshManager {
	
	
	/// 显示数据为空 lable 和 imageView
	///
	/// - Parameters:
	///   - lableText: text
	///   - imageName:  图片名称
	///   - imageRatio: 图片宽度相对 RefreshView 宽度比例
	public func makeEmptyView(lableText: String, imageName: String? = nil, imageRatio: CGFloat = 0.5 ) {
		let emptyView = self.emptyAppearance as? EmptyRefreshView ?? EmptyRefreshView(toView: self.refreshView)
		_ = emptyView.showLabel(text: lableText, textColor: self.indicatorStyleColor)
		if let imageName = imageName {
			_ = emptyView.showImage(name: imageName, ratio: imageRatio)
		}
//		empty-order
		makeAppearance(emptyAppearance: emptyView)
	}
	
	
	/// 显示数据为空 button
	///
	/// - Parameter button: 传入的 button
	public func makeEmptyButton(button: UIButton) {
		let emptyView = self.emptyAppearance as? EmptyRefreshView ?? EmptyRefreshView(toView: self.refreshView)
		_ = emptyView.addButton(button: button)
	}
}

/// 遵循 EmptyDataAppearance 协议的刷新 View
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
		toView.addSubview(button)
//        button.snp.makeConstraints({ (maker) in
//            maker.height.equalTo(35)
//            maker.centerX.equalToSuperview()
//            maker.centerY.equalToSuperview().offset(67)
//            maker.width.equalTo(100)
//        })
		button.isHidden = true
		emptyButton = button
		return self
	}
}

extension EmptyRefreshView: EmptyDataAppearance {

	public func showEmptyAppearance(isHidden: Bool) {
		emptyLable?.isHidden = isHidden
		emptyImageView?.isHidden = isHidden
		emptyButton?.isHidden = isHidden
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
		toView.addSubview(label)
		
		let height = label.sizeThatFits(CGSize.init(width: 300, height: 30))
//        label.snp.makeConstraints({ (make) in
//            make.centerX.equalToSuperview()
//            make.centerY.equalToSuperview().offset(14)
//            make.height.equalTo(height)
//            make.width.equalToSuperview()
//        })
		
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
		toView.addSubview(imageView)
		
//        imageView.snp.makeConstraints({ (make) in
//            make.centerX.equalToSuperview()
//            make.width.equalToSuperview().multipliedBy(self.emptyImageViewRatio)
//            make.height.equalTo(toView.snp.width).multipliedBy(self.emptyImageViewRatio)
//            make.centerY.equalToSuperview().offset(-imageHeight / 2 + 10)
//        })
		
		imageView.isHidden = true
		emptyImageView = imageView
	}
	
}
