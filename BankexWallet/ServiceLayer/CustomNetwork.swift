//
//  CustomNetwork.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina (Agoda) on 3/11/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit
import BigInt
import web3swift

struct CustomNetwork {
    //It's just beautiful identifier for the user
    let networkName: String?
    let networkId: BigUInt
    let networkUrlString: URL
    
    //TODO: think if it can be stored like this
    let accessToken: String?
}

extension CustomNetwork {
    static func convert(network: Networks) -> CustomNetwork {
        let adapter = Web3SwiftNetworksAdapter()
        let networkId = adapter.id(from: network)
        guard let networkName = adapter.name(from: network),
            let networkUrl = URL(string: "https://" + networkName + ".infura.io/")
            else {
                //TODO: Should be smth else, but without name we cannot produce real url
                return convert(network: Networks.Rinkeby)
        }
        
        return CustomNetwork(networkName: networkName, networkId: networkId, networkUrlString: networkUrl, accessToken: nil)
    }
}

protocol NetworksService {
    func addCustomNetwork(name: String?,
                          networkId: BigUInt,
                          networkUrlString: String,
                          accessToken: String?) -> Error?
    func currentNetworksList() -> [CustomNetwork]?
    func deleteNetwork(with networkId: BigUInt) -> Error?
    func preferredNetwork() -> CustomNetwork
}

class NetworksServiceImplementation: NetworksService {
    
    func currentNetworksList() -> [CustomNetwork]? {
        return nil
    }
    
    func addCustomNetwork(name: String? = nil,
                          networkId: BigUInt,
                          networkUrlString: String,
                          accessToken: String? = nil) -> Error? {
        //TODO: check, if there would be conflicts because of networkId/URL
        return nil
    }
    
    func deleteNetwork(with networkId: BigUInt) -> Error? {
        return nil
    }
    
    func preferredNetwork() -> CustomNetwork {
        //TODO: What is this? Should it be like that?
        let networkSelectionSetting = NetworkSelectionSettings()
        return CustomNetwork.convert(network: networkSelectionSetting.preferredNetwork())
    }
}

class NetworkSelectionSettings {
    
    let savingNetworkIdKey = "UserSelectedNetworkId"
    
    func preferredNetwork() -> Networks {
        guard let savedNetworkIdData = UserDefaults.standard.data(forKey: savingNetworkIdKey) else {
            return Networks.Rinkeby
        }
        let savedNetworkId = BigUInt(savedNetworkIdData)
        return Web3SwiftNetworksAdapter().network(from: savedNetworkId)
    }
    
    func updatePreferredNetwork(to network: Networks) {
        let networkId = Web3SwiftNetworksAdapter().id(from: network)
        let serializedData = networkId.serialize()
        UserDefaults.standard.set(serializedData, forKey: savingNetworkIdKey)
    }
}



//TODO: Make it better afterwords
// TODO: of course, no adapter here
class Web3SwiftNetworksAdapter {
    func network(from id: BigUInt) -> Networks {
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
    
    func name(from network: Networks) -> String? {
        switch network {
        case .Rinkeby: return "rinkeby"
        case .Ropsten: return "ropsten"
        case .Mainnet: return "mainnet"
        case .Kovan: return "kovan"
        case .Custom: return nil
        }
    }
    
    func id(from network: Networks) -> BigUInt {
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
