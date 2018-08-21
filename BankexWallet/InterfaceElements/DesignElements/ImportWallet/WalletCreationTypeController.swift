//
//  WalletCreationTypeController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 4/3/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit
import Firebase

class WalletCreationTypeController: UIViewController {
    
    @IBOutlet weak var importBtn:UIButton!
    var isFromInitial = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRemoteConfigDefaults()
        updateViewWithRCValues()
        fetchRemoteConfig()
    }
    
    func updateViewWithRCValues() {
        DispatchQueue.main.async { [unowned self] in
            let rc = RemoteConfig.remoteConfig()
            let bt = rc.configValue(forKey: "importButtonText").stringValue ?? ""
            self.importBtn.setTitle(bt, for: .normal)
        }
    }
    
    func setupRemoteConfigDefaults() {
        let defaultValues = [
            "importButtonText" : "Import wallet" as NSObject
        ]
        RemoteConfig.remoteConfig().setDefaults(defaultValues)
        RemoteConfig.remoteConfig().activateFetched()
    }
    
    func fetchRemoteConfig() {
        DispatchQueue.global(qos: .background).async {
            // UNCOMMENT FOR DEVELOPER MODE ONLY
            //        let debugSettings = RemoteConfigSettings(developerModeEnabled: true)
            //        RemoteConfig.remoteConfig().configSettings = debugSettings
            //        RemoteConfig.remoteConfig().fetch(withExpirationDuration: 0) { (status, error) in
            //            guard error == nil else {
            //                print(error?.localizedDescription)
            //                return
            //            }
            //            print("Success retrieving")
            //            RemoteConfig.remoteConfig().activateFetched()
            //        }
            // UNCOMMENT FOR RELEASE
            let debugSettings = RemoteConfigSettings(developerModeEnabled: false)
            RemoteConfig.remoteConfig().configSettings = debugSettings
            RemoteConfig.remoteConfig().fetch { (status, error) in
                guard error == nil else {
                    print(error?.localizedDescription)
                    return
                }
                print("Success retrieving")
                RemoteConfig.remoteConfig().activateFetched()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = isFromInitial
    }
    
    @IBAction func buttonTouchedDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.05,
                       animations: {
                        sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)},
                       completion: nil)
    }
    
    @IBAction func touchDragInside(_ sender: UIButton) {
        UIView.animate(withDuration: 0.05,
                       animations: {
                        sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)},
                       completion: nil)
    }
    @IBAction func buttonTouchedUpInside(_ sender: UIButton) {
        UIView.animate(withDuration: 0.05) {
            sender.transform = CGAffineTransform.identity
        }
    }
    @IBAction func touchAborted(_ sender: UIButton) {
        UIView.animate(withDuration: 0.05) {
            sender.transform = CGAffineTransform.identity
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationController?.navigationBar.isHidden = false
    }
 
    
    
    @IBAction func unwind(segue:UIStoryboardSegue) { }

}
