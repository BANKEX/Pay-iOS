//
//  ProductViewCell.swift
//  BankexWallet
//
//  Created by Vladislav on 17/10/2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import UIKit

protocol ProductViewCellDelegate:class {
    func didSwitch()
}

class ProductViewCell: UICollectionViewCell {
    
    
    
    
    
    @IBOutlet weak var productImage:UIImageView?
    @IBOutlet weak var titleProduct:UILabel?
    @IBOutlet weak var productSwitch:SwitchButton?
    @IBOutlet weak var descriptionLabel:UILabel?
    @IBOutlet weak var getButton:UIButton?
    @IBOutlet weak var containerView:UIView!
    
    var isPicked = false
    var product:Product!
    var gesture:UITapGestureRecognizer!
    var size = CGSize.zero
    
    weak var delegate:ProductViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        getButton?.isHidden = true
        backgroundColor = .white
        layer.cornerRadius = 8
        setupDefaultShadow()
        gesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        gesture.cancelsTouchesInView = false
        if #available(iOS 9.2, *) {
            gesture.requiresExclusiveTouchType = false
        } else {
            // Fallback on earlier versions
        }
        addGestureRecognizer(gesture)
    }
    
    @objc func tap() {
        isPicked = !isPicked
        updateUI()
    }
    
    func updateUI() {
        backgroundColor = isPicked ? UIColor.mainColor : .white
        productImage?.image = isPicked ? product.selectedImage : product.image
        titleProduct?.textColor = isPicked ? .white : .black
        productSwitch?.layer.borderWidth = isPicked ? 0 : 1.5
        productSwitch?.rotate()
        getButton?.isHidden = isPicked ? false : true
        
    }
    
    func setData(_ index:Int) {
        product = Product(rawValue: index)!
        titleProduct?.text = product.title
        productImage?.image = product.image
        descriptionLabel?.text = product.description
        getButton?.setTitle(product.titleButton, for: .normal)
    }
    
    @IBAction func get() {
        guard UIApplication.shared.canOpenURL(product.url) else { return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(product.url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(product.url)
        }
        isPicked = !isPicked
        updateUI()
    }
    
    @IBAction func switchTap() {
        delegate?.didSwitch()
    }
    
    
    
    
    
    
    
    

}

extension ProductViewCell {
    enum Product:Int {
        case scan = 0,custody,trust
        
        var title:String {
            switch self {
            case .scan: return "BANKEX Scan"
            case .custody: return "BANKEX Crypto Custody"
            case .trust: return "BANKEX Trust"
            }
        }
        
        var image:UIImage {
            switch self {
            case .scan: return UIImage(named:"logo_scan")!
            case .custody: return UIImage(named:"logo_Custody")!
            case .trust: return UIImage(named:"logo_trust")!
            }
        }
        
        var selectedImage:UIImage {
            switch self {
            case .scan: return UIImage(named:"logo_scan_sel")!
            case .custody: return UIImage(named:"Custody logo_sel")!
            case .trust: return UIImage(named:"Trust Logo_sel")!
            }
        }
        
        var description:String {
            switch self {
            case .scan:
                return "BANKEX Scan is a service that lets users search for Ethereum transactions. Use BANKEX Scan to get a maximum of information about every transaction."
            case .custody:
                return "BANKEX Custody is a reliable service for storing cryptocurrency and tokenized assets. Custody keeps you safe from hackers and fraudsters, and allows you to restore access if you forget your password or experience a hardware failure."
            case .trust:
                return "BANKEX Trust is а secure and decentralized repository for agreements made on the blockchain. Use BANKEX Trust to confirm and preserve confirm the details of transactions, contracts,or other agreed-upon actions."
            }
        }
        
        var titleButton:String {
            if self == .scan {
                return "Get App"
            }else {
                return "Visit Product Page"
            }
        }
        
        var url:URL {
            switch self {
            case .scan: return URL(string:"itms-apps://itunes.apple.com/us/app/ethereum-exporer-bankex-scan/id1434820920")!
            case .custody: return URL(string:"https://custody.bankex.com")!
            case .trust: return URL(string:"https://trust.bankex.com")!
            }
        }
        
    }
}
