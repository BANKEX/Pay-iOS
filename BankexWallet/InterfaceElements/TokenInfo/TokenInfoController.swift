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
    @IBOutlet weak var addingButton: UIButton!
    
    let keysService: SingleKeyService  = SingleKeyServiceImplementation()
    let tokensService: CustomERC20TokensService = CustomERC20TokensServiceImplementation()
    let conversionService = FiatServiceImplementation.service
    
    var interactor:Interactor?
    
    var token: ERC20TokenModel?
    var rate: Double? = nil
    
    var forAdding: Bool = false
    
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
        
        NotificationCenter.default.addObserver(forName: ReceiveRatesNotification.receivedAllRates.notificationName(), object: nil, queue: nil) { (_) in
            DispatchQueue.main.async {
                self.rate = self.conversionService.currentConversionRate(for: (self.token?.symbol.uppercased())!)
                self.tableView.reloadData()
            }
            
        }
        
        tableView.tableFooterView = UIView() //removing extra cells
        
        if token == nil {
            walletName.text = "Error in token"
        } else if keysService.selectedWallet()?.name == nil {
            walletName.text = "Error in wallet"
        } else {
            walletName.text = keysService.selectedWallet()?.name
            tokensService.getNewConversion(for: (token?.symbol.uppercased())!)
        }
        
        if !forAdding {
            addingButton.isHidden = true
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
            cell.configure(with: NSLocalizedString("Address", comment: ""), value: token?.address, measurment: nil)
        case TokenInfoRaws.currency.rawValue :
            if token != nil {
                let rate = "\(conversionService.currentConversionRate(for: (self.token?.symbol.uppercased())!))$"
                cell.configure(with: NSLocalizedString("Currency", comment: ""), value: rate, measurment: (token?.name ?? ""))
            } else {
                cell.configure(with: NSLocalizedString("Currency", comment: ""), value: "Error in token", measurment: (token?.name ?? ""))
            }
        case TokenInfoRaws.decimals.rawValue :
            cell.configure(with: NSLocalizedString("Decimals", comment: ""), value: token?.decimals, measurment: nil)
        default:
            break
        }
        return cell
        
    }
    
    @IBAction func addTokenAction(_ sender: UIButton) {
        guard let foundModel = token else {
            return
        }
        tokensService.addNewCustomToken(with: foundModel.address,
                                        name: foundModel.name,
                                        decimals: foundModel.decimals,
                                        symbol: foundModel.symbol)
        
    }
    
    
}
