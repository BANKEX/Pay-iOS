//
//  ProductsViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 17/10/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class ProductsViewController: BaseViewController {
    
    
    @IBOutlet weak var collectionView:UICollectionView!
    
    
    
    let cellIdentifer = "ProductViewCell"
    let viewIdentifer = "ProductDetailView"
    let heightCell:CGFloat = 70
    let inset:CGFloat = 15
    override var navigationBarAppearance: NavigationBarAppearance? {
        return .whiteStyle
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "BANKEX Products"
        setupCollectionView()
    }
    
    func setupCollectionView() {
        collectionView.register(UINib(nibName: cellIdentifer, bundle: nil), forCellWithReuseIdentifier: cellIdentifer)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.bgMainColor
        collectionView.allowsMultipleSelection = true
        collectionView.alwaysBounceVertical = true
    }

}

extension ProductsViewController:UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let productCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifer, for: indexPath) as! ProductViewCell
        productCell.setData(indexPath.row)
        return productCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = CGSize(width: collectionView.bounds.width - 2 * inset, height: heightCell)
        if let cell = collectionView.cellForItem(at: indexPath) as? ProductViewCell {
            cell.delegate = self
            if cell.isPicked {
                size.height += cell.descriptionLabel!.bounds.height + 8 + cell.getButton!.bounds.height + 20
            }
        }
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let topInset:CGFloat = UIDevice.isIpad ? 54 : 32
        return UIEdgeInsets(top: topInset, left: 15, bottom: 0, right: 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        collectionView.moveItem(at: indexPath, to: indexPath)
        return false
    }
    

    
    
}

extension ProductsViewController:ProductViewCellDelegate {
    func didSwitch() {
        collectionView.moveItem(at: IndexPath(item: 0, section: 0), to: IndexPath(item: 0, section: 0))
    }
}

