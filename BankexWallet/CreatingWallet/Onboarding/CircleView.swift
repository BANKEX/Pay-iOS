//
//  CircleView.swift
//  BankexWallet
//
//  Created by Георгий Фесенко on 16/07/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

//
//  CircleView.swift
//  BankexWallet
//
//  Created by Георгий Фесенко on 13/07/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

@IBDesignable
class CircleView: UIView {
    
    
    @IBInspectable var filled: Bool = true {
        didSet {
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var strokeWidth: CGFloat = 2.7
    @IBInspectable var strokeColor: UIColor = WalletColors.circleColor
    @IBInspectable var fillColor: UIColor = WalletColors.blackColor
    
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



