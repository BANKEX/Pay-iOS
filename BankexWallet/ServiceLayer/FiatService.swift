//
//  FiatService.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina on 5/5/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

protocol FiatService {

    func updateConversionRate(for tokenName: String,completion: @escaping (Float) -> Void)
    
    func currentConversionRate(for tokenName: String) -> Float
    
}


class FiatServiceImplementation: FiatService {
    
    var conversionRates = [String: Float]()
    let urlFormat = "https://min-api.cryptocompare.com/data/price?fsym=%@&tsyms=USD,ETH"//"https://api.coinmarketcap.com/v1/ticker/%@/?convert=USD"
    
    func updateConversionRate(for tokenName: String, completion: @escaping (Float) -> Void) {
        let codedTokenName = tokenName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let fullURLString = String(format: urlFormat, codedTokenName ?? "")
        guard let url = URL(string: fullURLString) else {
            completion(0)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let data = data {
                do {
                    // Convert the data to JSON
                    let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                    
                    if let json = jsonSerialized, let conversionRate = json["USD"] as? Float {

                        self.conversionRates[tokenName] = conversionRate
                        DispatchQueue.main.async {
                            completion(conversionRate)
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
    
    func currentConversionRate(for tokenName: String) -> Float {
        return conversionRates[tokenName] ?? 0
    }
    

    
    
    static let service = FiatServiceImplementation()

}
