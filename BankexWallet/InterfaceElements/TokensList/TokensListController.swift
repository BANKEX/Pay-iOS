//
//  TokensListController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 3/15/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

protocol TokenSelectionsProtocol {
    func didSelectToken(_ token: ERC20TokenModel)
}

class TokensListController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    let service: CustomERC20TokensService = CustomERC20TokensServiceImplementation()
    var tokens: [ERC20TokenModel]?
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tokens = service.availableTokensList()
        tableView.reloadData()
    }
    
    @objc func dismissView(_ sender: UIGestureRecognizer) {
        navigationController?.navigationBar.isHidden = false
        self.performSegue(withIdentifier: "unwindToSend", sender: nil)
    }

    // MARK:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (tokens?.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TokensListCell", for: indexPath) as! TokensListCell
        let token = tokens![indexPath.row]
        let isSelected = token.address == service.selectedERC20Token().address
        cell.configure(with: token, isSelected: isSelected, isFirstCell: indexPath.row == 0, isLastCell: indexPath.row == (tokens?.count ?? 0) - 1)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let token = tokens?[indexPath.row] else {
            return
        }
        let address = token.address
        service.updateSelectedToken(to: address)
        tokens = service.availableTokensList()
        tableView.reloadData()
        if self.canPerformSegue(id: "unwindToSend") {
            navigationController?.navigationBar.isHidden = false
            self.performSegue(withIdentifier: "unwindToSend", sender: nil)
            
        }
        
    }
}


extension UIViewController {
    func canPerformSegue(id: String) -> Bool {
        let segues = self.value(forKey: "storyboardSegueTemplates") as? [NSObject]
        let filtered = segues?.filter({ $0.value(forKey: "identifier") as? String == id })
        return ((filtered?.count)! > 0) 
    }
}
