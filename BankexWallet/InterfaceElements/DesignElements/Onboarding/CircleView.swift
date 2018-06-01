//
//  CircleView.swift
//  BankexWallet
//
//  Created by Георгий Фесенко on 01/06/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

@IBDesignable
class CircleView: UIView {

    
    @IBInspectable var filled: Bool = true
    @IBInspectable var strokeWidth: CGFloat = 2.7
    @IBInspectable var strokeColor: UIColor = #colorLiteral(red: 0.7568627451, green: 0.7921568627, blue: 0.8235294118, alpha: 1)
    @IBInspectable var fillColor: UIColor = #colorLiteral(red: 0.6117647059, green: 0.6509803922, blue: 0.6862745098, alpha: 1)
    
    override func draw(_ rect: CGRect) {
        let bezierPath = UIBezierPath(circleIn: rect)
        
        bezierPath.lineWidth = strokeWidth
        
        if filled {
            self.fillColor.setStroke()
            self.fillColor.setFill()
            bezierPath.stroke()
            bezierPath.fill()
        } else {
            self.strokeColor.setStroke()
            bezierPath.stroke()
        }
        
    }

}

extension UIBezierPath {
    convenience init(circleIn rect: CGRect) {
        self.init()
        
        
        let radius = rect.size.width/2 - 2
        let center = CGPoint(x: rect.size.width/2, y: rect.size.height/2)
        
        self.addArc(withCenter: center, radius: radius, startAngle: CGFloat(0.0.degreesToRadians), endAngle: CGFloat(360.0.degreesToRadians), clockwise: true)
        
        self.close()
    }
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}
