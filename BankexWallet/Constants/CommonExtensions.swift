//
//  Constants.swift
//  BankexWallet
//
//  Created by Alexander Vlasov on 26.01.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import UIKit

/*
 Закомментил пока лагает
 */
//@IBDesignable extension UIView {
//
//    /* The color of the shadow. Defaults to opaque black. Colors created
//     * from patterns are currently NOT supported. Animatable. */
//    @IBInspectable var shadowColor: UIColor? {
//        set {
//            layer.shadowColor = newValue!.cgColor
//        }
//        get {
//            if let color = layer.shadowColor {
//                return UIColor(cgColor: color)
//            }
//            else {
//                return nil
//            }
//        }
//    }
//
//    @IBInspectable var borderColor: UIColor? {
//        set {
//            layer.borderColor = newValue!.cgColor
//        }
//        get {
//            if let color = layer.borderColor {
//                return UIColor(cgColor: color)
//            }
//            else {
//                return nil
//            }
//        }
//    }
//
//    /* The opacity of the shadow. Defaults to 0. Specifying a value outside the
//     * [0,1] range will give undefined results. Animatable. */
//    @IBInspectable var shadowOpacity: Float {
//        set {
//            layer.shadowOpacity = newValue
//        }
//        get {
//            return layer.shadowOpacity
//        }
//    }
//
//    /* The shadow offset. Defaults to (0, -3). Animatable. */
//    @IBInspectable var shadowOffset: CGPoint {
//        set {
//            layer.shadowOffset = CGSize(width: newValue.x, height: newValue.y)
//        }
//        get {
//            return CGPoint(x: layer.shadowOffset.width, y:layer.shadowOffset.height)
//        }
//    }
//
//    /* The blur radius used to create the shadow. Defaults to 3. Animatable. */
//    @IBInspectable var borderWidth: CGFloat {
//        set {
//            layer.borderWidth = newValue
//        }
//        get {
//            return layer.borderWidth
//        }
//    }
//
//    /* The blur radius used to create the shadow. Defaults to 3. Animatable. */
//    @IBInspectable var shadowRadius: CGFloat {
//        set {
//            layer.shadowRadius = newValue
//        }
//        get {
//            return layer.shadowRadius
//        }
//    }
//}


extension Date {
    func isInSameWeek(date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .weekOfYear)
    }
    func isInSameMonth(date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .month)
    }
    func isInSameYear(date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .year)
    }
    func isInSameDay(date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .day)
    }
    var isInThisWeek: Bool {
        return isInSameWeek(date: Date())
    }
    var isInToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    var isInTheFuture: Bool {
        return Date() < self
    }
    var isInThePast: Bool {
        return self < Date()
    }
}

extension CGFloat {
    static var random: CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func randomDark() -> UIColor {
        let max: CGFloat = 170
        var red = CGFloat.random
        var green = CGFloat.random
        var blue = CGFloat.random
        red = red > max ? max : red
        green = green > max ? max : green
        blue = blue > max ? max : blue
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
    static func random() -> UIColor {
        return UIColor(red:   .random,
                       green: .random,
                       blue:  .random,
                       alpha: 1.0)
    }
}
