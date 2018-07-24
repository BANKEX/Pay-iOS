//
//  TokenInfoController.swift
//  BankexWallet
//
//  Created by Антон Григорьев on 23.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class TokenInfoController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var walletName: UILabel!
    
    let keysService: SingleKeyService  = SingleKeyServiceImplementation()
    
    var interactor:Interactor?
    
    var token: ERC20TokenModel?
    var amount: String?
    
    @IBAction func close(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        let percentThreshold:CGFloat = 0.3
        
        let translation = sender.translation(in: view)
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        
        guard let interactor = interactor else { return }
        
        switch sender.state {
        case .began:
            interactor.hasStarted = true
            dismiss(animated: true, completion: nil)
        case .changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.cancel()
        case .ended:
            interactor.hasStarted = false
            interactor.shouldFinish ? interactor.finish() : interactor.cancel()
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        
        tableView.tableFooterView = UIView() //removing extra cells
        
        if token == nil {
            walletName.text = "Error in token"
        } else if keysService.selectedWallet()?.name == nil {
            walletName.text = "Error in wallet"
        } else {
            walletName.text = keysService.selectedWallet()?.name
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (token != nil) ? 3 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TokenInfoListCell") as! TokenInfoListCell
        guard token != nil else {return cell}
        switch indexPath.row {
        case TokenInfoRaws.address.rawValue :
            cell.configure(with: "Address", value: token?.address, measurment: nil)
        case TokenInfoRaws.currency.rawValue :
            cell.configure(with: "Currency", value:  (amount ?? "Error in amount of token"), measurment: (token?.name ?? ""))
        case TokenInfoRaws.decimals.rawValue :
            cell.configure(with: "Decimals", value: token?.decimals, measurment: nil)
        default:
            break
        }
        return cell
        
    }
    
}
