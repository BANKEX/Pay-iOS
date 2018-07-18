//
//  CollectionViewAfterManager.swift
//  BankexWallet
//
//  Created by Георгий Фесенко on 18/07/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class CollectionViewAfterManager: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var collectionView: UICollectionView!
    weak var delegate: CollectionViewAfterDelegate?
    var words = [String]() {
        didSet {
            collectionView.reloadData()
        }
    }

    var wordsInCorrectOrder = [String]()
    init(collectionView: UICollectionView, wordsInCorrectOrder: [String]) {
        super.init()
        self.wordsInCorrectOrder = wordsInCorrectOrder
        self.collectionView = collectionView
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return words.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "justCell", for: indexPath) as? CollectionViewCell else { return UICollectionViewCell() }
        cell.configureCell(withText: words[indexPath.row])
        if words[indexPath.row] != wordsInCorrectOrder[indexPath.row] {
            cell.backgroundColor = #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 0.7)
            cell.layer.borderColor = #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1)
            cell.wordLabel.textColor = #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1)
        }
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didDiselectItem(at: indexPath)
    }
}

protocol CollectionViewAfterDelegate: class {
    func didDiselectItem(at indexPath: IndexPath)
}

