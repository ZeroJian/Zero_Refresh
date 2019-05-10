//
//  SpinnerView.swift
//
//  Created by ZeroJianMBP on 26/04/2017.
//  Copyright © 2017 ZeroJian. All rights reserved.
//

import UIKit

/// 加载指示视图
open class SpinnerView: UIView {
	
	public let logoImageView = UIImageView()
	public let circleImagView = UIImageView()
	
	/// 图片名称, logo: 中间显示的图像 circle: 圆环
	fileprivate var imageName: (logo: String, circle: String) = (logo: "spinner_logo_blue", circle: "spinner_circle_blue")
	fileprivate var logoLayerKey: String = ""
	fileprivate var circleLyaerKey: String = ""
	
	public init(imageName:(logo: String, circle: String)? = nil ,frame: CGRect = .zero) {
		super.init(frame: frame)
		
		if let imageName = imageName {
			self.imageName = imageName
		}
		
		backgroundColor = .clear
		
		circleImagView.contentMode = .scaleAspectFit
		circleImagView.image = UIImage(named: self.imageName.circle)
		
		logoImageView.contentMode = .scaleAspectFit
		logoImageView.image = UIImage(named: self.imageName.logo)
		
		addSubview(circleImagView)
		addSubview(logoImageView)
		
		circleImagView.snp.makeConstraints { (maker) in
			maker.edges.equalToSuperview()
		}
		
		logoImageView.snp.makeConstraints { (maker) in
			maker.edges.equalToSuperview().inset(5)
		}
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	/// 开始动画
	public func startAnimated() {
		logoImageView.isHidden = false
		circleImagView.isHidden = false
		logoLayerKey = logoImageView.opacityAnimation()
		circleLyaerKey = circleImagView.rotationAnimation()
	}
	
	/// 结束动画
	public func stopAnimated() {
		logoImageView.removeLayerAnimated(forKey: logoLayerKey)
		circleImagView.removeLayerAnimated(forKey: circleLyaerKey)
		logoImageView.isHidden = true
		circleImagView.isHidden = true
	}
	
	open override func removeFromSuperview() {
		stopAnimated()
		super.removeFromSuperview()
	}
}

extension SpinnerView {
	
	
	/// 显示加载视图到中心位置
	///
	/// - Parameters:
	///   - view:  superview
	///   - width: 视图宽度
	/// - Returns: 加载视图
	@discardableResult
	public static func showToView(_ view: UIView, width: CGFloat = 40) -> SpinnerView {
		
		let spinnerView = SpinnerView()
//		spinnerView.center = view.center
//		spinnerView.bounds.size = CGSize(width: width, height: width)
		view.addSubview(spinnerView)
		spinnerView.snp.makeConstraints { (maker) in
			maker.center.equalToSuperview()
			maker.size.equalTo(CGSize(width:width, height: width))
		}
		spinnerView.startAnimated()
		return spinnerView
	}
	
	
	/// 隐藏加载视图
	///
	/// - Parameter view:  superView
	/// - Returns: 是否成功
	@discardableResult
	public static func hideForView(_ view: UIView) -> Bool {
		for subview in view.subviews.reversed() {
			if subview is SpinnerView {
				subview.removeFromSuperview()
				return true
			}
		}
		return false
	}
}

extension UIView {
        
    func showSpinnerView(size: CGSize = CGSize(width:42.5, height: 42.5), insetTop: CGFloat = 0) {
//        zj.removeMaskView()
        self.isUserInteractionEnabled = false
        
//        let maskView = zj.addMaskView()
        let spinnerView = SpinnerView()
        self.addSubview(spinnerView)
        spinnerView.snp.makeConstraints { (maker) in
//            maker.center.equalToSuperview()
            maker.centerY.equalToSuperview().inset(insetTop)
            maker.centerX.equalToSuperview()
            maker.size.equalTo(size)
        }
        spinnerView.startAnimated()
    }
    
}

extension UIView {
	
	/// 透明渐变动画
	fileprivate func opacityAnimation(time: TimeInterval = 0.6) -> String {
		let kAnimationKey = "opacityAnimation"
		if self.layer.animation(forKey: kAnimationKey) == nil {
			
			let animation = CABasicAnimation(keyPath: "opacity")
			animation.fromValue = 1
			animation.toValue = 0.4
			animation.duration = time
			animation.autoreverses = true
			animation.repeatCount = Float.infinity
            animation.fillMode = CAMediaTimingFillMode.forwards
            animation.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeIn)
			animation.isRemovedOnCompletion = false
			self.layer.add(animation, forKey: kAnimationKey)
			
		}
		return kAnimationKey
	}
	
	/// 视图旋转动画
	fileprivate func rotationAnimation(time: TimeInterval = 1.5) -> String {
		let kAnimationKey = "rotationAnimation"
		
		if self.layer.animation(forKey: kAnimationKey) == nil {
			
			let rotaionAnimation = CABasicAnimation(keyPath: "transform.rotation")
			rotaionAnimation.fromValue = 0.0
			rotaionAnimation.toValue = Double.pi * 2.0
			rotaionAnimation.duration = time
			rotaionAnimation.repeatCount = Float.infinity
			rotaionAnimation.isRemovedOnCompletion = false
			self.layer.add(rotaionAnimation, forKey: kAnimationKey)
		}
		return kAnimationKey
	}
	
	fileprivate func removeLayerAnimated(forKey key: String) {
		if self.layer.animation(forKey: key) != nil {
			self.layer.removeAnimation(forKey: key)
		}
	}
	
}
