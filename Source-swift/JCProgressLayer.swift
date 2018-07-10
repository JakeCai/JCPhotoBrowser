//
//  JCProgressLayer.swift
//  JCPhotoBrowser-Swift
//
//  Created by Jake on 31/05/2017.
//  Copyright © 2017 Jake. All rights reserved.
//

import UIKit

class JCProgressLayer: CAShapeLayer, CAAnimationDelegate {
    var _progress:CGFloat!
    var progress:CGFloat!{
        get{
            return _progress
        }
        set{
            _progress = newValue
            self.strokeEnd = progress
        }
    }
    
    fileprivate var isSpinning = false
    
    public init(Frame:CGRect) {
        super.init()
        self.frame = Frame
        self.cornerRadius = 20
        self.fillColor = UIColor.clear.cgColor
        self.strokeColor = UIColor.white.cgColor
        self.lineWidth = 4;
        self.lineCap = kCALineCapRound;
        self.strokeStart = 0;
        self.strokeEnd = 0.01;
        self.backgroundColor = UIColor.init(white: 0, alpha: 0.5).cgColor
        let path:UIBezierPath = UIBezierPath.init(roundedRect:self.bounds , cornerRadius: 20-2)
        self.path = path.cgPath
        
        NotificationCenter.default.addObserver(self, selector:#selector(becomeActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func becomeActive(_:Notification){
        if self.isSpinning {
            self.startPin()
        }
    }
    
    @objc public func startPin(){
        self.isSpinning = true
        self.pinWith(angle: .pi)
    }
    
    @objc private func pinWith(angle:CGFloat) {
        self.strokeEnd = 0.33;
        var rotationAnimation:CABasicAnimation;
        rotationAnimation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = .pi-0.5
        rotationAnimation.duration = 0.4
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = HUGE
        self.add(rotationAnimation, forKey: nil)
    }
    
    @objc public func stopPin() {
        self.isSpinning = false
        self.removeAllAnimations()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
}
