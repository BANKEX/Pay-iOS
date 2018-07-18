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
    
    // Outlets
    @IBOutlet weak var afterCheckCollectionView: UICollectionView!
    @IBOutlet weak var beforeCheckCollectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.isEnabled = false
        nextButton.backgroundColor = WalletColors.disabledGreyButton.color()
        setupManagers()
        
//        let neededHeight = beforeCheckCollectionView.collectionViewLayout.collectionViewContentSize.height
//        let currentHeight = beforeCheckView.frame.size.height
//        if  currentHeight < neededHeight {
//            let multiplier = neededHeight / (sumHeight - neededHeight)
//            heightConstraing = heightConstraing.setMultiplier(multiplier: multiplier)
//        }
    }
    
    // Helpers
    func setupManagers() {
        
        wordsBeforeManager = CollectionViewBeforeManager(collectionView: beforeCheckCollectionView, words: wordsInCorrectOrder)
        wordsBeforeManager.delegate = self
        wordsAfterManager = CollectionViewAfterManager(collectionView: afterCheckCollectionView, wordsInCorrectOrder: wordsInCorrectOrder)
        wordsAfterManager.delegate = self
        
        wordsBefore = wordsInCorrectOrder
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





