//
//  ERC20StandartViewController.swift
//  BankexWallet
//
//  Created by Георгий Фесенко on 01/06/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var images = ["Favorites", "Custom network", "ERC20"]
    let texts = ["ERC20": ("ERC20 standart", "Support for any tokens within the Ether network."), "Custom network": ("Custom network", "Add your network and work with tokens right inside wallet."), "Favorites": ("Favorites", "Add your contacts in the Favorite list for quick access to them.")]
    
    @IBOutlet weak var circlesContainerCenterConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var circlesStack: UIStackView!
    @IBOutlet var circles: [CircleView]!
    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    override func viewDidLoad() {
        guard let imageName = images.popLast() else { return }
        imageView.image = UIImage(named: imageName)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? WalletCreationTypeController {
            destination.isBackButtonHidden = true
        }
    }
    
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        for circle in circles {
            circle.filled = false
            circle.layoutIfNeeded()
        }
        circles[circles.count - images.count].filled = true
        circles[circles.count - images.count].layoutIfNeeded()

        
        guard let imageName = images.popLast() else { return }
        
        if images.count == 0 {
            nextButton.isHidden = true
            skipButton.isHidden = true
            getStartedButton.alpha = 0.0
            UIView.animate(withDuration: 0.6) {
                self.getStartedButton.alpha = 1.0
                self.getStartedButton.isHidden = false
            }
            
            circlesContainerCenterConstraint.constant -= getStartedButton.bounds.height / 2
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.imageView.alpha = 0.0
            self.nameLabel.alpha = 0.0
            self.descriptionLabel.alpha = 0.0
        }) { _ in
            self.imageView.image = UIImage(named: imageName)
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
                self.imageView.alpha = 1.0
                self.nameLabel.alpha = 1.0
                self.descriptionLabel.alpha = 1.0
                self.nameLabel.text = self.texts[imageName]?.0
                self.descriptionLabel.text = self.texts[imageName]?.1
            }, completion: nil)
        }
        
        
    }
    
    @IBAction func skipButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "showWalletCreationScreen", sender: nil)
    }
    
    @IBAction func getStartedButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "showWalletCreationScreen", sender: nil)
        
    }
    
    
    
}
