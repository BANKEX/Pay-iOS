//
//  CreateNetworkViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 23.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class CreateNetworkViewController: UITableViewController {
    
    @IBOutlet weak var networkURLTextField:UITextField!
    @IBOutlet weak var networkNameTextField:UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "New Network"
        tableView.separatorStyle = .none
        networkURLTextField.becomeFirstResponder()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(back))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Join", style: .done, target: self, action: #selector(joinToConnection))
    }
    
    @objc func textFromBuffer() {
        if let text = UIPasteboard.general.string {
            networkURLTextField.text = text
        }
    }
    
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func joinToConnection() {
        //TODO
    }

    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let view = UIView()
            view.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: tableView.sectionHeaderHeight)
            let button = UIButton(frame: CGRect(x: 16.0, y: 0, width: 140.0, height: 28.0))
            button.addTarget(self, action: #selector(textFromBuffer), for:.touchUpInside)
            button.setImage(#imageLiteral(resourceName: "Paste button"), for: .normal)
            view.addSubview(button)
            return view
        }else {
            return nil
        }
    }
}
