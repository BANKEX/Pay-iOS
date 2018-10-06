//
//  FiatService.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina on 5/5/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

protocol FiatService {

    func updateConversionRate(for tokenName: String,currency:Currencies, completion: @escaping (Double) -> Void)
    
    func currentConversionRate(for tokenName: String) -> Double
    
}

enum Currencies:String {
    case USD = "USD"
}


class FiatServiceImplementation: FiatService {
    
    static let service = FiatServiceImplementation()
    var conversionRates = [String: Double]()
    
    
    func updateConversionRate(for tokenName: String,currency:Currencies = .USD, completion: @escaping (Double) -> Void) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "min-api.cryptocompare.com"
        components.path = "/data/price"
        components.queryItems = [
            URLQueryItem(name: "fsym", value: tokenName),URLQueryItem(name: "tsyms", value: currency.rawValue)
        ]
        guard let url = components.url else {
            completion(0)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let data = data {
                do {
                    // Convert the data to JSON
                    let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                    
                    if let json = jsonSerialized {
                        
                        if let conversionRate = json["USD"] as? Double {
                            DispatchQueue.main.async {
                                self.conversionRates[tokenName] = conversionRate
                                completion(conversionRate)
                            }
                        } else {
                            print("Can't convert to Double")
                            DispatchQueue.main.async {
                                completion(0)
                            }
                        }
                    }
                }  catch let error as NSError {
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        completion(0)
                    }
                }
            } else if let error = error {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    completion(0)
                }
            }
        }
        
        task.resume()
    }
    
    func currentConversionRate(for tokenName: String) -> Double {
        return conversionRates[tokenName] ?? 0
    }
}
