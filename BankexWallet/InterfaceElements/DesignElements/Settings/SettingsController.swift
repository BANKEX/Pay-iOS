//
//  SettingsController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 4/24/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit
import MessageUI
import StoreKit


class SettingsController: UIViewController, UITableViewDelegate,
UITableViewDataSource,
MFMailComposeViewControllerDelegate {
    @IBAction func unwind(segue:UIStoryboardSegue) { }

    let settingsToShow = ["WalletsListCell",
                          "NetworksListCell",
                          "EmptySpaceCell",
                          "CommunitySectionCell",
                          "TwitterCell",
                          "FacebookCell",
                          "TelegramCell",
                          "EmptySpaceCell",
                          "SupportSectionCell",
                          "RateUsCell",
                          "WriteUsCell",
                          "EmptySpaceCell"]
    
    @IBOutlet weak var tableView: UITableView!
    var settingsParameters = [String]()
    let networksService: NetworksService = NetworksServiceImplementation()
    let walletsService: GlobalWalletsService = SingleKeyServiceImplementation()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadData()
        NotificationCenter.default.addObserver(forName: DataChangeNotifications.didChangeNetwork.notificationName(), object: nil, queue: nil) { (_) in
            self.reloadData()
        }
        NotificationCenter.default.addObserver(forName: DataChangeNotifications.didChangeWallet.notificationName(), object: nil, queue: nil) { (_) in
            self.reloadData()
        }
        
    }
    
    func reloadData() {
        settingsParameters = [walletsService.selectedWallet()?.name ?? walletsService.selectedWallet()?.address ?? "",
                              networksService.preferredNetwork().networkName ?? networksService.preferredNetwork().fullNetworkUrl.absoluteString]
        tableView.reloadData()
    }

    // MARK: Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsToShow.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: settingsToShow[indexPath.row], for: indexPath)
        if let cell = cell as? SettingsCellWithParameter,
            settingsParameters.count > indexPath.row {
            let parameter = settingsParameters[indexPath.row]
            cell.configureCell(with: parameter)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let settingToShow = settingsToShow[indexPath.row]
        if settingToShow == "WriteUsCell" {
            guard (MFMailComposeViewController.canSendMail()) else {
                return
            }
            let toRecipents = ["wallet@bankexfoundation.org"]
            let mc: MFMailComposeViewController = MFMailComposeViewController()
            mc.mailComposeDelegate = self
            mc.setToRecipients(toRecipents)
            present(mc, animated: true, completion: nil)
        }
        
        else if settingToShow == "RateUsCell" {
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            } else {
                // TODO: Don't Forget App Id
                rateApp(appId: "")
            }
        }
        else if settingToShow == "TwitterCell" {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: "https://twitter.com/BankExProtocol")!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(URL(string: "https://twitter.com/BankExProtocol")!)
            }
        }
        else if settingToShow == "FacebookCell" {
            if #available(iOS 10.0, *) {
                
                UIApplication.shared.open(URL(string: "https://www.facebook.com/BankExchange/")!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(URL(string: "https://www.facebook.com/BankExchange/")!)
            }
        }
        else if settingToShow == "TelegramCell" {
            if #available(iOS 10.0, *) {
                
                UIApplication.shared.open(URL(string: "https://t.me/bankex")!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(URL(string: "https://t.me/bankex")!)
            }
        }
    }
    
    // MARK: Rate us
    fileprivate func rateApp(appId: String) {
        openUrl("itms-apps://itunes.apple.com/app/" + appId)
    }
    fileprivate func openUrl(_ urlString:String) {
        let url = URL(string: urlString)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}


class SettingsCellWithParameter: UITableViewCell {
    @IBOutlet weak var parameterLabel: UILabel!
    
    func configureCell(with text: String) {
        parameterLabel.text = text
        accessibilityIdentifier = "WalletsListCell"
        isAccessibilityElement = true
    }
}
