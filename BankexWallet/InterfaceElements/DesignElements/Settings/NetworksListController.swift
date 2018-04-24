//
//  NetworksListController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina (Agoda) on 4/24/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

class NetworksListController: UIViewController,
UITableViewDelegate,
UITableViewDataSource {
    
    let networksService: NetworksService = NetworksServiceImplementation()
    var mainNetworksList = [CustomNetwork]()
    var testNetworksList = [CustomNetwork]()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainNetworksList = networksService.currentNetworksList()
    }
    
    
    // MARK: Actions
    @IBAction func goBack(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addNetwork(sender: UIButton) {
        // TODO:
    }
    
    // MARK: TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? mainNetworksList.count : 1 + testNetworksList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NetworksSectionCell")
            return cell!
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "NetworksListCell")
        if let cell = cell as? NetworksListCell {
            let fullNumberInThisSection = indexPath.section == 0 ? mainNetworksList.count : 1 + testNetworksList.count
            let currentNetwork = indexPath.section == 0 ?  mainNetworksList[indexPath.row] : testNetworksList[indexPath.row]
            let isSelected = networksService.preferredNetwork().fullNetworkUrl == currentNetwork.fullNetworkUrl
            cell.configure(with: currentNetwork, isSelected: isSelected, isFirstCell: indexPath.row == 0,
                           isLastCell: indexPath.row == fullNumberInThisSection - 1)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let network = indexPath.section == 0 ? mainNetworksList[indexPath.row] : testNetworksList[indexPath.row - 1]
        networksService.updatePreferredNetwork(customNetwork: network)
//        keysService.updateSelected(address: keysList[indexPath.row].address)
        tableView.reloadData()
    }
}

class NetworksListCell: UITableViewCell {
    
    @IBOutlet weak var theOnlyBackgroundView: UIView!
    @IBOutlet weak var lastCellBackgroundView: UIView!
    @IBOutlet weak var firstCellBackgroundView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var checkmarkImage: UIImageView!
    @IBOutlet weak var separatorView: UIView!
    func configure(with network: CustomNetwork, isSelected: Bool, isFirstCell: Bool, isLastCell: Bool) {
        theOnlyBackgroundView.isHidden = !(isFirstCell && isLastCell)
        lastCellBackgroundView.isHidden = isFirstCell
        firstCellBackgroundView.isHidden = isLastCell
        separatorView.isHidden = isLastCell
        checkmarkImage.isHidden = !isSelected
        nameLabel.text = network.networkName ?? network.fullNetworkUrl.absoluteString
        
    }
}

