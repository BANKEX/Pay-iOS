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
    var controllersWithContent = [UIViewController]()
    
    //MARK: - LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedControl.tintColor = UIColor.mainColor
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
        if let viewController = segue.destination as? UIViewController {
            controllersWithContent.append(viewController)
        }
    }
    
    
    //MARK: - Methods

    
    func updateUI() {
        if segmentedControl.selectedSegmentIndex == 0 {
            privateKeyContainer.isHidden = false
            passphraseContainer.isHidden = true
        }else {
            privateKeyContainer.isHidden = true
            passphraseContainer.isHidden = false
        }
    }
    
    //MARK: - IBActions
    @IBAction func segmentedControlerTapped(_ sender:UISegmentedControl) {
        updateUI()
    }
    
    

}

