//
//  CustomNetwork.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina on 3/11/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit
import BigInt
import web3swift

struct CustomNetwork {
    //It's just beautiful identifier for the user
    let networkName: String?
    let networkId: BigUInt
    let fullNetworkUrl: URL
    
    enum CodingKeys: String, CodingKey {
        case id = "networkId"
        case networkName
        case networkUrl
    }
    
    init(networkName: String? = nil,
         networkId: BigUInt,
         networkUrlString: String,
         accessToken: String? = nil) {
        self.networkName = networkName
        self.networkId = networkId
        let requestURLstring = networkUrlString + (accessToken ?? "")
        guard let urlString = URL(string: requestURLstring) else {
            //TODO: somehow we cannot convert to URL, what a maaaagic
            self.fullNetworkUrl = URL(string: "https://rinkeby.infura.io")!
            return
        }
        self.fullNetworkUrl = urlString
    }
}


extension CustomNetwork: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let networkName = self.networkName {
            try container.encode(networkName, forKey: .networkName)
        }
        try container.encode(networkId, forKey: .id)
        try container.encode(fullNetworkUrl, forKey: .networkUrl)
    }
}

extension CustomNetwork: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if values.contains(.networkName) {
            networkName = try values.decode(String.self, forKey: .networkName) as? String
        } else {
            networkName = nil
        }
        networkId = try values.decode(BigUInt.self, forKey: .id)
        fullNetworkUrl = try values.decode(URL.self, forKey: .networkUrl)
    }
}


extension CustomNetwork {
    static func convert(network: Networks) -> CustomNetwork {
        let adapter = Web3SwiftNetworksAdapter()
        let networkId = adapter.id(from: network)
        guard let networkName = adapter.name(from: network)
            else {
                //TODO: Should be smth else, but without name we cannot produce real url
                return convert(network: Networks.Rinkeby)
        }
        let networkUrlString = "https://" + networkName + ".infura.io/"
        return CustomNetwork(networkName: networkName,
                             networkId: networkId,
                             networkUrlString: networkUrlString,
                             accessToken: nil)
    }
    
    func convertToNetworks() -> Networks {
        return Networks.Custom(networkID: self.networkId)
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
        //TODO: DI! DI! DI! Or maybe delete this settings class
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
