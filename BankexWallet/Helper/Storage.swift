//
//  Storage.swift
//  BankexWallet
//
//  Created by Vladislav on 13/10/2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import Foundation

class Storage {
    
    fileprivate init() { }
    
    static func retrieve<T: Decodable>(_ fileName: String, as type: T.Type) -> T {
        let fileManager = FileManager.default
        let url = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.PayWidget")!.appendingPathComponent(fileName, isDirectory: false)
        
        if !fileManager.fileExists(atPath: url.path) {
            fatalError("File at path \(url.path) does not exist!")
        }
        
        if let data = FileManager.default.contents(atPath: url.path) {
            let decoder = JSONDecoder()
            do {
                let model = try decoder.decode(type, from: data)
                return model
            } catch {
                fatalError(error.localizedDescription)
            }
        } else {
            fatalError("No data at \(url.path)!")
        }
    }
    //Clear entire directory
    static func clear() {
        let fileManager = FileManager.default
        let url = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.PayWidget")!
        do {
            let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            try contents.forEach {
                try fileManager.removeItem(at: $0)
            }
        }catch {
            fatalError(error.localizedDescription)
        }
    }
    

    
    static func store<T: Encodable>(_ object: T, as fileName: String) {
        let fileManager = FileManager.default
        let url = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.PayWidget")!.appendingPathComponent(fileName, isDirectory: false)
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            if fileManager.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    
    static func isExist(fileName:String) -> Bool {
        let fileManager = FileManager.default
        let url = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.PayWidget")!
        let destURL = url.appendingPathComponent(fileName, isDirectory: false)
        return fileManager.fileExists(atPath: destURL.path)
    }
    
    
}
