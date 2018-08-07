//
//  GenericWalletCreationContainer.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina on 4/6/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

class GenericWalletCreationContainer: UIViewController {

    var walletCreationMode = WalletKeysMode.createKey

    // MARK: Outlets:
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var passphraseButton: UIButton!
    @IBOutlet weak var privateKeyButton: UIButton!
    
    @IBOutlet weak var importPrivateKeyContainer: UIView!
    @IBOutlet weak var importPassphraseContainer: UIView!
    
    @IBOutlet weak var privateKeyLabel: UILabel!
    
    @IBOutlet weak var passphraseLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        //titleLabel.text = walletCreationMode.title()
        privateKeyLabel.borderWidth = 3
        passphraseLabel.borderWidth = 3
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        privateKeyTapped(self)
    }
    
    @IBAction func passphraseButtonTapped(_ sender: Any) {
        guard !passphraseButton.isSelected else {
            return
        }
        privateKeyButton.isSelected = false
        passphraseButton.isSelected = true
        privateKeyLabel.borderColor = UIColor.clear
        privateKeyLabel.textColor = WalletColors.defaultGreyText.color()
        passphraseLabel.borderColor = WalletColors.defaultDarkBlueButton.color()
        passphraseLabel.textColor = WalletColors.blueText.color()
        importPrivateKeyContainer.isHidden = true
        importPassphraseContainer.isHidden = false
        controllersWithInputs.forEach{ $0.clearTextfields() }
    }
    
    @IBAction func privateKeyTapped(_ sender: Any) {
        guard !privateKeyButton.isSelected else {
            return
        }
        privateKeyButton.isSelected = true
        passphraseButton.isSelected = false
        passphraseLabel.borderColor = UIColor.clear
        passphraseLabel.textColor = WalletColors.defaultGreyText.color()
        privateKeyLabel.borderColor = WalletColors.defaultDarkBlueButton.color()
        privateKeyLabel.textColor = WalletColors.blueText.color()
        importPrivateKeyContainer.isHidden = false
        importPassphraseContainer.isHidden = true
        controllersWithInputs.forEach{ $0.clearTextfields() }
    }
    
    // Here I'll do some bad magic
    // But it's very fast bad magic and I cannot decide how to make it better
    // Maybe in future should create segue for switching and then I can do it inside prepare for segue
    // Instead of keeping reference to controllers
    var controllersWithInputs = [ScreenWithInputs]()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let singleKeyController = segue.destination as? WalletSingleKeyController {
            singleKeyController.mode = walletCreationMode
        }
        else if let hdKeyController = segue.destination as? WalletBIP32KeyController {
            hdKeyController.mode = walletCreationMode
        }
        if let controller = segue.destination as? ScreenWithInputs {
            controllersWithInputs.append(controller)
        }
    }
}
