//
//  GenericImportViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 17.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class GenericImportViewController: BaseViewController {

    
    //MARK: - IBOutlets
    @IBOutlet weak var segmentedControl:UISegmentedControl! //I dont know how to name
    @IBOutlet weak var privateKeyContainer:UIView!
    @IBOutlet weak var passphraseContainer:UIView!
    
    
    //MARK: - Properties
    var controllersWithContent = [ScreenWithContentProtocol]()
    
    //MARK: - LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedControl.tintColor = WalletColors.mainColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()
        updateUI()
    }
    
    func setupNavBar() {
        title = NSLocalizedString("Importing Wallet", comment: "")
        navigationController?.navigationBar.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? ScreenWithContentProtocol {
            controllersWithContent.append(viewController)
        }
    }
    
    
    //MARK: - Methods

    
    func updateUI() {
        if segmentedControl.selectedSegmentIndex == 0 {
            privateKeyContainer.isHidden = false
            passphraseContainer.isHidden = true
            controllersWithContent.forEach { $0.clearTextFields() }
        }else {
            privateKeyContainer.isHidden = true
            passphraseContainer.isHidden = false
            controllersWithContent.forEach { $0.clearTextFields() }
        }
    }
    
    //MARK: - IBActions
    @IBAction func segmentedControlerTapped(_ sender:UISegmentedControl) {
        updateUI()
    }
    
    

}

