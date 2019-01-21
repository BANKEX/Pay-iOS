//
//  NetworksViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 21.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import Foundation

protocol CounableProtocol {
    static var count:Int { get }
}

protocol NetworkDelegate:class {
    func didTapped(with network:CustomNetwork)
}

class NetworksViewController: BaseViewController {
    
    @IBOutlet weak var tableView:UITableView!
    
    
    enum NetworksSections:Int,CaseIterable {
        case CurrentNetwork = 0,DefaultNetwork,CustomNetwork
    }
    override var navigationBarAppearance: NavigationBarAppearance? {
        get {
            return super.navigationBarAppearance ?? .whiteStyle
        }
        set {
            super.navigationBarAppearance = newValue
        }
    }
    weak var delegate:NetworkDelegate?
    
    var selectedNetwork:CustomNetwork {
        return networkService.preferredNetwork()
    }
    var isFromDeveloper = false
    let networkService = NetworksServiceImplementation()
    var listNetworks:[CustomNetwork]!
    var listCustomNetworks:[CustomNetwork] {
        return Array(listNetworks[4...])
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        self.listNetworks = self.networkService.currentNetworksList()
        tableView.tableFooterView = HeaderView()
        tableView.backgroundColor = UIColor.bgMainColor
        NotificationCenter.default.addObserver(forName: DataChangeNotifications.didChangeNetwork.notificationName(), object: nil, queue: nil) { (_) in
            self.tableView.reloadData()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func hideAddBtn() {
        navigationItem.rightBarButtonItem = nil
    }
    
    func configure() {
        tableView.dataSource = self
        tableView.delegate = self
        navigationItem.title = isFromDeveloper ? NSLocalizedString("CustomNetworks", comment: "") : NSLocalizedString("Network", comment: "")
        if !isFromDeveloper {
            hideAddBtn()
        }else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNetworkTapped(_:)))
        }
    }
    
    func presentPopOver(_ vc:CreateNetworkViewController) {
        let nv = UINavigationController(rootViewController: vc)
        nv.modalPresentationStyle = .popover
        if let popOver = nv.popoverPresentationController {
            popOver.permittedArrowDirections = .up
            popOver.sourceView = view
            popOver.sourceRect = CGRect(x: view.bounds.maxX - 45, y: view.bounds.minY - 600, width: 375, height: 600)
        }
        nv.preferredContentSize = CGSize(width: 375, height: splitViewController!.view.bounds.height * 0.55)
        self.present(nv, animated: true, completion: nil)
    }

    
    
    @objc func createNetworkTapped(_ sender:UIButton) {
        if UIDevice.isIpad {
            let addNetworkVC = UIStoryboard(name: "NetworkAdd", bundle: nil).instantiateInitialViewController() as! CreateNetworkViewController
            presentPopOver(addNetworkVC)
        }else {
            performSegue(withIdentifier: "createNetworkSegue", sender: self)
        }
    }
    
}


