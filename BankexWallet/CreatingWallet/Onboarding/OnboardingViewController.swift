//
//  OnboardingViewController.swift
//  BankexWallet
//
//  Created by Георгий Фесенко on 16/07/2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import UIKit

class OnboardingViewController: BaseViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBOutlet weak var arrowNext: UIImageView!
    @IBOutlet weak var circlesStack: UIStackView!
    @IBOutlet var circles: [CircleView]!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    weak var delegate: OnboardingDelegate?
    
    var images = ["Favorites", "ERC20", "Custom network"]
    let texts = ["ERC20": (NSLocalizedString("ERC20 Standard", comment: ""), NSLocalizedString("Support for any token within the Ether network.", comment: "")), "Custom network": (NSLocalizedString("Custom Network", comment: ""), NSLocalizedString("Add your network and work with tokens right inside your wallet.", comment: "")), "Favorites": (NSLocalizedString("Favorites", comment: ""), NSLocalizedString("Add your contacts to Favorites to access them quickly.", comment: ""))]
    
    var image: UIImage?
    var name: String?
    var descr: String?
    var circleSelected: Int?
    var buttonText: String?
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageView.image = image
        nameLabel.text = name
        descriptionLabel.text = descr
        nextButton.setTitle(buttonText, for: .normal)
        arrowNext.isHidden = circleSelected == 2
        for circle in circles {
            circle.filled = false
            circle.layoutIfNeeded()
        }
        guard let circleSelected = circleSelected else { return }
        circles[circleSelected].filled = true
        circles[circleSelected].layoutIfNeeded()
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        if circleSelected == 2 {
            self.performSegue(withIdentifier: "toNavigation", sender: nil)
            UserDefaults.standard.setValue(false, forKey: "isOnboardingNeeded")
        } else {
            delegate?.nextButtonTapped()
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = segue.destination
    }
    func configure(with image: String, andCircleSelected circleSelected: Int) {
        self.image = UIImage(named: image)
        name = texts[image]?.0
        descr = texts[image]?.1
        self.circleSelected = circleSelected
        buttonText = circleSelected == 2 ? NSLocalizedString("GET STARTED", comment: "") : NSLocalizedString("NEXT", comment: "")
    }
    
}


protocol OnboardingDelegate: class {
    func nextButtonTapped()
}
