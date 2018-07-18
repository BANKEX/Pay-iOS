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
    
    // Data sources for collection views
    var wordsAfter = [String]() {
        didSet {
            self.wordsAfterManager.words = wordsAfter
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
    
    // Outlets
    @IBOutlet weak var afterCheckCollectionView: UICollectionView!
    @IBOutlet weak var beforeCheckCollectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.isEnabled = false
        nextButton.backgroundColor = WalletColors.disabledGreyButton.color()
        setupManagers()
        
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




