//
//  SettingsWalletsListController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 4/24/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

class SettingsWalletsListController: UIViewController,
UITableViewDataSource, UITableViewDelegate {

    
    let keysService: GlobalWalletsService = HDWalletServiceImplementation()
    var keysList = [HDKey]()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keysList = (keysService.fullHDKeysList() ?? [HDKey]()) + (keysService.fullListOfSingleEthereumAddresses() ?? [HDKey]())
        NotificationCenter.default.addObserver(forName: DataChangeNotifications.didChangeWallet.notificationName(), object: nil, queue: nil) { (_) in
            self.tableView.reloadData()
        }
    }

    @IBAction func unwind(segue:UIStoryboardSegue) { }

    // MARK: Actions
    @IBAction func goBack(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func addWallet(sender: UIButton) {
        // TODO:
    }
    
    // MARK: TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keysList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WalletsListCell")
        if let cell = cell as? WalletsListCell {
            let currentKey = keysList[indexPath.row]
            let isSelected = keysService.selectedKey()?.address == currentKey.address
            cell.configure(with: currentKey, isSelected: isSelected, isFirstCell: indexPath.row == 0,
                           isLastCell: indexPath.row == keysList.count - 1)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        keysService.updateSelected(address: keysList[indexPath.row].address)
        tableView.reloadData()
    }
}

class WalletsListCell: UITableViewCell {
    
    @IBOutlet weak var theOnlyBackgroundView: UIView!
    @IBOutlet weak var lastCellBackgroundView: UIView!
    @IBOutlet weak var firstCellBackgroundView: UIView!
    @IBOutlet weak var keyNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var checkmarkImage: UIImageView!
    @IBOutlet weak var separatorView: UIView!
    func configure(with key: HDKey, isSelected: Bool, isFirstCell: Bool, isLastCell: Bool) {
        theOnlyBackgroundView.isHidden = !(isFirstCell && isLastCell)
        lastCellBackgroundView.isHidden = isFirstCell
        firstCellBackgroundView.isHidden = isLastCell
        separatorView.isHidden = isLastCell
        checkmarkImage.isHidden = !isSelected
        keyNameLabel.text = key.name ?? "..."
        addressLabel.text = key.address
    }
}
