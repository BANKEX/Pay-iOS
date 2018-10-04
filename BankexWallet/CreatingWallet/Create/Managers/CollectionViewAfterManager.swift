//
//  CollectionViewAfterManager.swift
//  BankexWallet
//
//  Created by Георгий Фесенко on 18/07/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class CollectionViewAfterManager: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var collectionView: UICollectionView!
    weak var delegate: CollectionViewAfterDelegate?
    var words = [String]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    //Just a label for further calculations in flow layout
    lazy var label: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont(name: "System", size: 16)
        return label
    }()

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
        cell.configureCell(withText: words[indexPath.row], isCellRed: words[indexPath.row] != wordsInCorrectOrder[indexPath.row])
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didDiselectItem(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        label.text = words[indexPath.row]
        let width: CGFloat = label.intrinsicContentSize.width + 12
        let height: CGFloat = 33
        return CGSize(width: width, height: height)
    }
    
}

protocol CollectionViewAfterDelegate: class {
    func didDiselectItem(at indexPath: IndexPath)
}

