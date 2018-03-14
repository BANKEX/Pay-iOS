//
//  AddressQRCodeController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina on 3/13/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

class AddressQRCodeController: UIViewController {

    var addressToGenerateQR: String? //{
//        didSet {
//            imageView?.image = generateQRCode(from: addressToGenerateQR)
//        }
//    }
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageView.image = generateQRCode(from: addressToGenerateQR)
    }
 
    
    func generateQRCode(from string: String?) -> UIImage? {
        guard let string = addressToGenerateQR else {
            return nil
        }
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
}
