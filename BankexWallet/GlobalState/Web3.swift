//
//  Web3.swift
//  BankexWallet
//
//  Created by Alexander Vlasov on 29.01.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import web3swift
import BigInt


// TODO: should start to support not only Infura networks, but fully support custom networks
// TODO: It's better to put this logic to Networks part
// TODO: Let's think about DI here
class WalletWeb3Factory {
    
    static let web3: web3 = {
        let infura = InfuraProvider(NetworkSelectionSettings().preferredNetwork(), accessToken: nil)!
        return web3swift.web3(provider: infura)
    }()
}
