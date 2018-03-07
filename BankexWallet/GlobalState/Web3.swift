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

//TODO: Make it better afterwords
// TODO: of course, no adapter here
class Web3SwiftNetworksAdapter {
    func from(id: BigUInt) -> Networks {
        switch id {
        case BigUInt(1):
            return Networks.Mainnet
        case BigUInt(3):
            return Networks.Ropsten
        case BigUInt(4):
            return Networks.Rinkeby
        case BigUInt(42):
            return Networks.Kovan
        default:
            return Networks.Custom(networkID: id)
        }
    }
    
    func from(network: Networks) -> BigUInt {
        switch network {
        case .Mainnet:
            return BigUInt(1)
        case .Ropsten:
            return BigUInt(3)
        case .Rinkeby:
            return BigUInt(4)
        case .Kovan:
            return BigUInt(42)
        case .Custom(let networkID):
            return networkID
        }
    }
}

class NetworkSelectionSettings {
    
    let savingNetworkIdKey = "UserSelectedNetworkId"
    
    func preferredNetwork() -> Networks {
        guard let savedNetworkIdData = UserDefaults.standard.data(forKey: savingNetworkIdKey) else {
            return Networks.Rinkeby
        }
        let savedNetworkId = BigUInt(savedNetworkIdData)
        return Web3SwiftNetworksAdapter().from(id: savedNetworkId)
    }
    
    func updatePreferredNetwork(to network: Networks) {
        let networkId = Web3SwiftNetworksAdapter().from(network: network)
        let serializedData = networkId.serialize()
        UserDefaults.standard.set(serializedData, forKey: savingNetworkIdKey)
    }
}


// TODO: should start to support not only Infura networks, but fully support custom networks
// TODO: It's better to put this logic to Networks part
// TODO: Let's think about DI here
class WalletWeb3Factory {
    
    static let web3: web3 = {
        let infura = InfuraProvider(NetworkSelectionSettings().preferredNetwork(), accessToken: nil)!
        return web3swift.web3(provider: infura)
    }()
}
