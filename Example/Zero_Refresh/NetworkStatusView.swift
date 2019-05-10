//
//  NetworkStatusView.swift
//
//  Created by ZeroJianMBP on 27/04/2017.
//  Copyright © 2017 ZeroJian. All rights reserved.
//

import UIKit
import SnapKit

open class NetworkStatusView: UIView {
	
	public typealias FailureInfo = (isTimeOut: Bool, isNoNetwork: Bool, message: String)

	public struct ImageName {
		var empty = "pic_currency"
		var error = "error"
		var unLogin = "notlogged"
		var notNetwork = "notnet"
		var timeout = "timeout"
	}
	
	open var imageName: ImageName {
		var name = ImageName()
		name.empty = "empty-datasource"
		name.error = "empty-network"
		name.unLogin = "empty-network"
		name.notNetwork = "empty-network"
		name.timeout = "empty-network"
		return name
	}
	
	
	open var labelColor: (lable: UIColor, messageLabel: UIColor) {
        let lC = UIColor(red: 176.0/255.0, green: 177.0/255.0, blue: 178.0/255.0, alpha: 1.0)
        let mC = UIColor(red: 51.0/255.0, green: 51.0/255.0, blue: 51.0/255.0, alpha: 1.0)
        return (lC, mC)
	}
	
    /// label和上面视图的边距
    open var lbTopMargin: CGFloat = 5
    
    
    /// 提示图片的宽比
    open var imgViewWidthMultiply: CGFloat = 0.4
    
	/// 视图状态
	///
	/// - loading: 加载中
	/// - success: 完成
	/// - failure->Void?: 错误, 点击回调
	/// - empty: 图片名称, message
	public enum ViewStatus {
		case loading, success, message(String), failure(FailureInfo, (() -> Void)?), empty(String?, message: String?)
	}
	
	
	/// 配置错误信息
	///
	/// - Parameters:
	///   - isTimeOut: 超时
	///   - isNoNetwork: 没有网络
	///   - message: 错误信息
	/// - Returns:  FailureInfo
	public static func failureInfo(isTimeOut: Bool, isNoNetwork: Bool, message: String) -> FailureInfo {
		return FailureInfo(isTimeOut: isTimeOut, isNoNetwork: isNoNetwork, message: message)
	}
	/// 显示样式
	///
	/// - system: 系统菊花样式,错误状态只显示一行 label (适合用在子视图上)
	/// - custom: 自定义的 SpinnerView 样式,错误显示图片和 label (适合用在主视图上)
	public enum Style {
		case system, custom
	}
	    
	/// 初始化状态视图
	///
	/// - Parameters:
	///   - view:  superview
	///   - style: 显示样式
	public init(toView view: UIView, style: Style = .custom) {
		super.init(frame: .zero)
		backgroundColor = view.backgroundColor
		view.addSubview(self)
		self.snp.makeConstraints { (maker) in
			maker.edges.equalToSuperview()
		}
		self.style = style
	}
	
	/// 显示的状态
	///
	/// - Parameter status: 状态枚举
	public func show(status: ViewStatus) {
		switch status {
		case .loading:
			if style == .custom {
				spinnerView.startAnimated()
			} else {
				indicatorView.startAnimating()
			}
		
		case .success:
			removeLoading()
			removeFromSuperview()
			
		case .message(let str):
			removeLoading()
			messageLabel.text = str
			
		case .failure(let info, let action):
			removeLoading()
			setupFailureStatus(info)
			tapAction = action
		
		case .empty(let imageName, let message):
			removeLoading()
			if let message = message {
				label.text = message
			}
			
			guard style == .custom else { break }
			
			if let imageName = imageName {
				imageView.image = UIImage(named: imageName)
			} else {
				imageView.image = UIImage(named: self.imageName.empty)
			}
		}
	}
	
	fileprivate var tapAction: (() -> Void)?
	
	fileprivate lazy var imageView: UIImageView = {
		let iv = UIImageView()
		iv.contentMode = .scaleAspectFit
		self.addSubview(iv)
		iv.snp.makeConstraints { (maker) in
			maker.centerX.equalToSuperview()
			maker.bottom.equalTo(self.margnView.snp.top)
			maker.width.equalToSuperview().multipliedBy(imgViewWidthMultiply)
			maker.height.equalTo(self.snp.width).multipliedBy(0.4)
		}
		return iv
	}()
	
	fileprivate lazy var margnView: UIView = {
		let view = UIView()
		view.backgroundColor = .clear
		self.addSubview(view)
		view.snp.makeConstraints { (maker) in
			maker.center.equalToSuperview()
			maker.left.right.equalToSuperview()
			maker.height.equalTo(1)
		}
		return view
	}()
	
	
	// 错误提示 label
	fileprivate lazy var label: UILabel = {
		let lb = UILabel()
		lb.font = UIFont.systemFont(ofSize: 14)
		lb.textColor = labelColor.lable
		lb.textAlignment = .center
        lb.lineBreakMode = .byTruncatingHead
        lb.numberOfLines = 2
		self.addSubview(lb)
		
		switch self.style {
		case .custom:
			lb.snp.makeConstraints { (maker) in
				maker.centerX.equalToSuperview()
				maker.top.equalTo(self.margnView.snp.bottom).offset(lbTopMargin)
				maker.left.right.equalToSuperview()
			}
		case .system:
			lb.snp.makeConstraints({ (maker) in
				maker.edges.equalToSuperview()
			})
		}
		
		return lb
	}()
	
	// message type label
	fileprivate lazy var messageLabel: UILabel = {
		let lb = UILabel()
		lb.font = UIFont.boldSystemFont(ofSize: 14)
		lb.textColor = labelColor.messageLabel
		lb.textAlignment = .center
		self.addSubview(lb)
		
		lb.snp.makeConstraints({ (maker) in
			maker.center.equalToSuperview()
		})
		
		return lb
	}()
	
	
	fileprivate lazy var indicatorView: UIActivityIndicatorView = {
		let view = UIActivityIndicatorView()
        view.style = .gray
		self.addSubview(view)
		view.snp.makeConstraints({ (maker) in
			maker.edges.equalToSuperview()
		})
		return view
	}()
	
	fileprivate lazy var spinnerView: SpinnerView = {
		let view = SpinnerView()
		self.addSubview(view)
		view.snp.makeConstraints { (maker) in
			maker.center.equalToSuperview()
			maker.size.equalTo(CGSize(width:42.5, height: 42.5))
		}
		return view
	}()
	
	fileprivate var viewGusture: Bool = false {
		didSet {
			let view = self.style == .system ? self.label : self.imageView
			view.isUserInteractionEnabled = viewGusture
			if viewGusture {
				tapGusture = UITapGestureRecognizer()
				tapGusture?.addTarget(self, action: #selector(reload))
				tapGusture.flatMap{ view.addGestureRecognizer($0)}
			} else {
				tapGusture.flatMap({view.removeGestureRecognizer($0)})
			}
			
			if self.style == .custom {
				imageView.isHidden = !viewGusture
			}
			label.isHidden = !viewGusture
		}
	}
	
	fileprivate var tapGusture: UIGestureRecognizer?
	
	fileprivate var style: Style = .custom
	
	fileprivate func removeLoading() {
		if style == .custom {
			spinnerView.stopAnimated()
		} else {
			indicatorView.stopAnimating()
		}
	}
	
	fileprivate func setupFailureStatus(_ appError: FailureInfo) {
		
		let message: String = appError.message
		var imageName: String = self.imageName.error
        
        if appError.isTimeOut {
            imageName = self.imageName.timeout
        } else if appError.isNoNetwork {
            imageName = self.imageName.notNetwork
        }
        
		switch style {
		case .custom:
			imageView.image = UIImage(named: imageName)
			label.text = message + ", 轻触图片重试"
		
		case .system:
			label.text = message + ", 轻触重试"
		}
		
		viewGusture = true
	}
	
	@objc fileprivate func reload() {
		viewGusture = false
		tapAction?()
		tapAction = nil
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	
}
