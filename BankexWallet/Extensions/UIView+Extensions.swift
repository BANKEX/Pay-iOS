//
//  UIView+Extensions.swift
//  BankexWallet
//
//  Created by Vladislav on 17.09.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import VisualEffectView

extension UIView {
    
    /* The color of the shadow. Defaults to opaque black. Colors created
     * from patterns are currently NOT supported. Animatable. */
    @IBInspectable var shadowColor: UIColor? {
        set {
            layer.shadowColor = newValue!.cgColor
        }
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            else {
                return nil
            }
        }
    }
    
    
    @IBInspectable var borderColor: UIColor? {
        set {
            layer.borderColor = newValue!.cgColor
        }
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            else {
                return nil
            }
        }
    }
    
    /* The opacity of the shadow. Defaults to 0. Specifying a value outside the
     * [0,1] range will give undefined results. Animatable. */
    @IBInspectable var shadowOpacity: Float {
        set {
            layer.shadowOpacity = newValue
        }
        get {
            return layer.shadowOpacity
        }
    }
    
    /* The shadow offset. Defaults to (0, -3). Animatable. */
    @IBInspectable var shadowOffset: CGPoint {
        set {
            layer.shadowOffset = CGSize(width: newValue.x, height: newValue.y)
        }
        get {
            return CGPoint(x: layer.shadowOffset.width, y:layer.shadowOffset.height)
        }
    }
    
    /* The blur radius used to create the shadow. Defaults to 3. Animatable. */
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    func bottomBorder() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor(red: 188/255, green: 187/255, blue: 193/255, alpha: 1).cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.6)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
    
    /* The blur radius used to create the shadow. Defaults to 3. Animatable. */
    @IBInspectable var shadowRadius: CGFloat {
        set {
            layer.shadowRadius = newValue
        }
        get {
            return layer.shadowRadius
        }
    }
    
    func addBlur() {
        let visualEffectView = VisualEffectView(frame: self.bounds)
        
        // Configure the view with tint color, blur radius, etc
        visualEffectView.blurRadius = 5
        visualEffectView.scale = 1
        visualEffectView.colorTintAlpha = 0.1
        addSubview(visualEffectView)
    }
    func removeBlur() {
        self.subviews.last!.removeFromSuperview()
    }
    
    func setupDefaultShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 5.0)
        layer.shadowOpacity = 0.1
    }
    
    func initialAnimation() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.05) {
                self.transform = CGAffineTransform.identity
            }
        }
    }
    
    class func titleLabel(_ color:UIColor? = .white) -> UILabel {
        let label = UILabel()
        label.text = NSLocalizedString("Send", comment: "")
        label.textColor = color
        label.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
        return label
    }
    
    func rotate() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 3, options: [], animations: {
            self.transform = self.transform.rotated(by: .pi)
        })
    }
    
    func show() {
        UIView.animate(withDuration: 0.25, animations: {
            self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.25) {
            self.transform = CGAffineTransform(scaleX: 0, y: 0)
        }
    }
    
    func shimmerAnimation() {
        
        // gradient
        let lighColor = UIColor(white: 0, alpha: 0.2).cgColor
        let darkColor = UIColor.black.cgColor
        
        let width = bounds.size.width
        let height = bounds.size.height
        let frame = CGRect(x: -width, y: 0, width: 3*width, height: height)
        
        let gradient = CAGradientLayer()
        gradient.colors = [darkColor, lighColor, darkColor]
        gradient.frame = frame
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.525)
        gradient.locations = [0.4, 0.5, 0.6]
        
        layer.mask = gradient
        
        // animation
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0.0, 0.1, 0.2]
        animation.toValue = [0.8, 0.9, 1.0]
        animation.duration = 2
        animation.repeatCount = 1
        
        gradient.add(animation, forKey: "shimmer")
        
        // remove animation
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            gradient.removeFromSuperlayer()
        }
    }
}
