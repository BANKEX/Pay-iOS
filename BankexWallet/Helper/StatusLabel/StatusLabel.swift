//
//  StatusLabel.swift
//  Scan
//
//  Created by Andrew Kozlov on 16/08/2018.
//  Copyright © 2018 BANKEX. All rights reserved.
//

import UIKit

class StatusLabel: UILabel {
    
    enum Status {
        case success
        case pending
        case failed
    }
    
    var status: Status? {
        didSet {
            stylize()
        }
    }
    
    private let pointSize: CGFloat = 8
    private let textInset: CGFloat = 8
    private let roundedCornersAlignmentFactor: CGFloat = 0.05
    private let pointLayer = CALayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        prepare()
    }
    
    private func prepare() {
        layer.masksToBounds = true
        
        layer.addSublayer(pointLayer)
        pointLayer.frame.size = CGSize(width: pointSize, height: pointSize)
        pointLayer.cornerRadius = pointSize / 2
        
        stylize()
    }
    
}

extension StatusLabel {
    
    private func textLeftInset(for height: CGFloat) -> CGFloat {
        return height - alignmentRectInsets.left
    }
    
    private func textRightInset(for height: CGFloat) -> CGFloat {
        return height / 2
    }

    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.height += textInset + textInset
        size.width += textLeftInset(for: size.height) + textRightInset(for: size.height)
        
        return size
    }
    
    override var alignmentRectInsets: UIEdgeInsets {
        let delta = bounds.size.height * roundedCornersAlignmentFactor
        
        return UIEdgeInsets(top: 0, left: delta, bottom: 0, right: delta)
    }
    
    override func drawText(in rect: CGRect) {
        var rect = rect
        rect.origin.x = textLeftInset(for: rect.size.height)
        
        super.drawText(in: rect)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.size.height / 2
        pointLayer.position = CGPoint(x: bounds.size.height / 2, y: bounds.size.height / 2)
    }
    
}

extension StatusLabel {
    
    private func backgroundColor(for status: Status?) -> UIColor? {
        return pointColor(for: status)?.withAlphaComponent(0.2)
    }
    
    private func pointColor(for status: Status?) -> UIColor? {
        switch status {
        case .success?: return UIColor.Status.success
        case .pending?: return UIColor.Status.pending
        case .failed?: return UIColor.Status.failed
        default: return nil
        }
    }
    
    fileprivate func stylize() {
        backgroundColor = backgroundColor(for: status)
        pointLayer.backgroundColor = pointColor(for: status)?.cgColor
    }
    
}
