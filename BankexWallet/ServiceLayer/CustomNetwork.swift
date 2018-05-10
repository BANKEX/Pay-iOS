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

enum NetworksServiceError: Error {
    case networkDuplication
    case noNetworkWithId
}

protocol NetworksService {
    func addCustomNetwork(name: String?,
                          networkId: BigUInt,
                          networkUrlString: String,
                          accessToken: String?) throws
    func currentNetworksList() -> [CustomNetwork]
    func deleteNetwork(with networkId: BigUInt) throws
    func preferredNetwork() -> CustomNetwork
    func updatePreferredNetwork(customNetwork: CustomNetwork)
}

class NetworksServiceImplementation: NetworksService {
    
    let fullPathToTheFile: String

    init(with pathToNetworksStorage: String = "/Networks") {
        let fileManager = FileManager.default
        let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        let fullPath = userDir! + pathToNetworksStorage
        var isDir : ObjCBool = false
        var exists = fileManager.fileExists(atPath: fullPath, isDirectory: &isDir)
        self.fullPathToTheFile = fullPath + "/networksList"

        if (!exists){
            try? fileManager.createDirectory(atPath: fullPath, withIntermediateDirectories: true, attributes: nil)
            exists = fileManager.fileExists(atPath: fullPath, isDirectory: &isDir)
            FileManager.default.createFile(atPath: self.fullPathToTheFile, contents: nil, attributes: nil)
        }
    }
    
    var networksList = [CustomNetwork]()
    func currentNetworksList() -> [CustomNetwork] {
        if !networksList.isEmpty {
            return networksList
        }
        
        if let data = FileManager.default.contents(atPath: fullPathToTheFile) {
            let decoder = JSONDecoder()
            do {
                let model = try decoder.decode([CustomNetwork].self, from: data)
                self.networksList = model
            } catch {
                self.networksList = [CustomNetwork]()
            }
        } else {
            self.networksList = [CustomNetwork]()
        }
        
        return defaultNetworks() + networksList
    }
    
    func addCustomNetwork(name: String? = nil,
                          networkId: BigUInt,
                          networkUrlString: String,
                          accessToken: String? = nil) throws {
        
        let possibleNetworkToSave = CustomNetwork(networkName: name,
                                                  networkId: networkId,
                                                  networkUrlString: networkUrlString,
                                                  accessToken: accessToken)
        
        let duplicate = networksList.first(where: { (customNetwork) -> Bool in
            return customNetwork.fullNetworkUrl == possibleNetworkToSave.fullNetworkUrl ||
                    customNetwork.networkId == possibleNetworkToSave.networkId
        })
        
        if duplicate != nil {
            throw NetworksServiceError.networkDuplication
        }
        networksList.append(possibleNetworkToSave)
        storeNetworksListToDisk()
    }
    
    func deleteNetwork(with networkId: BigUInt) throws {
        
        let duplicateIndex = networksList.index(where: { (customNetwork) -> Bool in
            return customNetwork.networkId == networkId
        })
        
        guard let duplicatedIndex = duplicateIndex else {
            throw NetworksServiceError.noNetworkWithId
        }
        
        networksList.remove(at: duplicatedIndex)
        storeNetworksListToDisk()
    }
    
    
    private func storeNetworksListToDisk() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(networksList)
            if FileManager.default.fileExists(atPath: fullPathToTheFile) {
                try FileManager.default.removeItem(at: URL(fileURLWithPath: fullPathToTheFile))
            }
            FileManager.default.createFile(atPath: fullPathToTheFile, contents: data, attributes: nil)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func updatePreferredNetwork(customNetwork: CustomNetwork) {
        guard customNetwork.networkId == 1 ||
            customNetwork.networkId == 3 ||
            customNetwork.networkId == 4 ||
            customNetwork.networkId == 42 else {
            return
        }
        let network = Web3SwiftNetworksAdapter().network(from: customNetwork.networkId)
        let networkSelectionSetting = NetworkSelectionSettings()
        networkSelectionSetting.updatePreferredNetwork(to: network)
    }

    
    func preferredNetwork() -> CustomNetwork {
        //TODO: DI! DI! DI! Or maybe delete this settings class
        let networkSelectionSetting = NetworkSelectionSettings()
        return CustomNetwork.convert(network: networkSelectionSetting.preferredNetwork())
    }
    
    private func defaultNetworks() -> [CustomNetwork] {
        return [Networks.Mainnet, Networks.Rinkeby, Networks.Kovan, Networks.Ropsten].map { (network) -> CustomNetwork in
            return CustomNetwork.convert(network: network)
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
        return Web3SwiftNetworksAdapter().network(from: savedNetworkId)
    }
    
    func updatePreferredNetwork(to network: Networks) {
        let networkId = Web3SwiftNetworksAdapter().id(from: network)
        let serializedData = networkId.serialize()
        UserDefaults.standard.set(serializedData, forKey: savingNetworkIdKey)
        NotificationCenter.default.post(name: DataChangeNotifications.didChangeNetwork.notificationName(), object: self, userInfo: ["network": network])
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
