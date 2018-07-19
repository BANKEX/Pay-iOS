//
//  RepeatPassphraseViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 17.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class RepeatPassphraseViewController: UIViewController {
    
    var passphrase: String?
    var service: HDWalletService!
    
    // Managers of collection views
    var wordsAfterManager: CollectionViewAfterManager!
    var wordsBeforeManager: CollectionViewBeforeManager!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var heightConstraing: NSLayoutConstraint!
    @IBOutlet weak var afterCheckView: UIView!
    @IBOutlet weak var beforeCheckView: UIView!
    @IBOutlet weak var afterCheckCollectionView: UICollectionView!
    @IBOutlet weak var beforeCheckCollectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    // Data sources for collection views
    var wordsAfter = [String]() {
        didSet {
            
            self.wordsAfterManager.words = wordsAfter
            errorLabel.isHidden = wordsAfter == Array(wordsInCorrectOrder.prefix(wordsAfter.count))
            let neededHeight = afterCheckCollectionView.collectionViewLayout.collectionViewContentSize.height
            if neededHeight != 0.0 {
                let multiplier = (sumHeight - neededHeight) / neededHeight
                heightConstraing = heightConstraing.setMultiplier(multiplier: multiplier)
            }
            
            if wordsAfter == wordsInCorrectOrder {
                UIView.animate(withDuration: 0.5) {
                    self.nextButton.backgroundColor = WalletColors.blueText.color()
                    self.nextButton.isEnabled = true
                }
            } else {
                self.nextButton.backgroundColor = WalletColors.disabledGreyButton.color()
                self.nextButton.isEnabled = false
            }
        }
    }
    
    var wordsBefore = [String]() {
        didSet {
            self.wordsBeforeManager.words = wordsBefore
        }
    }
    
    lazy var wordsInCorrectOrder: [String] = {
        guard let passphrase = passphrase else { return []}
        return passphrase.split(separator: " ").map{ String($0) }
    }()
    
    lazy var sumHeight = {
        return afterCheckView.frame.size.height + beforeCheckView.frame.height
    }()
    
    lazy var spinner: UIActivityIndicatorView = {
        let s = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        s.frame = CGRect(x: UIScreen.main.bounds.width / 2, y: nextButton.frame.origin.y - 40, width: s.frame.width, height: s.frame.height)
        return s
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Creating Wallet"

        nextButton.isEnabled = false
        nextButton.backgroundColor = WalletColors.disabledGreyButton.color()
        setupManagers()
        
    }
    
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        guard let passphrase = passphrase else { return }
        sender.isEnabled = false
        spinner.startAnimating()
        view.addSubview(spinner)
        DispatchQueue.global(qos: .userInitiated).async {
            self.service.createNewHDWallet(with: "ETH Wallet Name", mnemonics: passphrase, mnemonicsPassword: "", walletPassword: "") { _, error in
                self.spinner.stopAnimating()
                self.spinner.removeFromSuperview()
                sender.isEnabled = true
                error == nil ? self.performSegue(withIdentifier: "toWalletCreated", sender: nil) :
                    self.showWalletCreationAllert()
            }
        }
        
    }
    
    
    
    // Helpers
    func setupManagers() {
        
        wordsBeforeManager = CollectionViewBeforeManager(collectionView: beforeCheckCollectionView, words: wordsInCorrectOrder)
        wordsBeforeManager.delegate = self
        wordsAfterManager = CollectionViewAfterManager(collectionView: afterCheckCollectionView, wordsInCorrectOrder: wordsInCorrectOrder)
        wordsAfterManager.delegate = self
        
        wordsBefore = wordsInCorrectOrder.shuffled()
    }
    
    
    func showWalletCreationAllert() {
        let alert = UIAlertController(title: "Error", message: "Couldn't add key", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let address = service.selectedAddress() else { return }
        if let vc = segue.destination as? WalletCreatedViewController {
            vc.address = address
            vc.service = service
        }
    }
    

}

extension RepeatPassphraseViewController: CollectionViewAfterDelegate {
    func didDiselectItem(at indexPath: IndexPath) {
        wordsBefore.append(wordsAfter[indexPath.row])
        wordsAfter.remove(at: indexPath.row)
        
    }
}

extension RepeatPassphraseViewController: CollectionViewBeforeDelegate {
    func didSelectItem(at indexPath: IndexPath) {
        wordsAfter.append(wordsBefore[indexPath.row])
        wordsBefore.remove(at: indexPath.row)
    }
}





