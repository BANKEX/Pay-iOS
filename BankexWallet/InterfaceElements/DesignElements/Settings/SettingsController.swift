//
//  SettingsController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 4/24/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit


class SettingsController: UIViewController, UITableViewDelegate, UITableViewDataSource {

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
}


class SettingsCellWithParameter: UITableViewCell {
    @IBOutlet weak var parameterLabel: UILabel!
    
    func configureCell(with text: String) {
        parameterLabel.text = text
    }
}
