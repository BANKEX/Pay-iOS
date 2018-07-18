//
//  CollectionViewBeforeManager.swift
//  BankexWallet
//
//  Created by Георгий Фесенко on 18/07/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class CollectionViewBeforeManager: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var collectionView: UICollectionView!
    weak var delegate: CollectionViewBeforeDelegate?
    var words = [String]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    init(collectionView: UICollectionView, words: [String]) {
        super.init()
        self.words = words
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
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectItem(at: indexPath)
    }
    
}


protocol CollectionViewBeforeDelegate: class {
    func didSelectItem(at indexPath: IndexPath)
}
