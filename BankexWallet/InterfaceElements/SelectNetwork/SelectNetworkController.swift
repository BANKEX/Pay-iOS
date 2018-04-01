//
//  SelectNetworkController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina (Agoda) on 3/26/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

class SelectNetworkController: UIViewController,
UITableViewDataSource,
UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let networksService: NetworksService = NetworksServiceImplementation()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fullReload()
    }
    
    func fullReload() {
        currentNetworks = networksService.currentNetworksList()
        selectedNetwork = networksService.preferredNetwork()
        tableView.reloadData()
    }

    var currentNetworks: [CustomNetwork]?
    var selectedNetwork: CustomNetwork?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networksService.currentNetworksList().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "PublicKeyCell", for: indexPath) as! PublicKeyCell
        let networkAtIndex = (index < currentNetworks?.count ?? 0) ? currentNetworks?[indexPath.row] : nil
        cell.configure(withAddress: (networkAtIndex?.networkName ?? ""), isSelected: networkAtIndex?.fullNetworkUrl == selectedNetwork?.fullNetworkUrl)
        cell.qrCodeButton.isHidden = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let network = currentNetworks?[indexPath.row] else {
            return
        }
        networksService.updatePreferredNetwork(customNetwork: network)
        fullReload()
    }
}
