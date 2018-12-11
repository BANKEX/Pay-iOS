//
//  Web3.swift
//  BankexWallet
//
//  Created by BANKEX Foundation on 29.01.2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import Foundation
import web3swift
import BigInt

class WalletWeb3Factory {
    
     static  func web3() -> web3 {
        let networksService = NetworksServiceImplementation()
        let preferredNetwork = networksService.preferredNetwork()
        let net = preferredNetwork.convertToNetworks()
        
        guard let provider = Web3HttpProvider(preferredNetwork.fullNetworkUrl, network: net, keystoreManager: nil) else {
            //TODO: Let's trust our library, and pray it creates provider at least for default net
            return web3swift.web3(provider: InfuraProvider(Networks.Rinkeby)!)
        }
        return web3swift.web3(provider: provider)
    }
}
