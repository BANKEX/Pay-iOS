//
//  VIew+Routines.swift
//  BankexWallet
//
//  Created by Vladislav on 14/10/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import UIKit

func CreateVC(byName controllerName: String, probablyStoryboard: UIStoryboard? = nil) -> UIViewController? {
    var result: UIViewController?
    
    if probablyStoryboard != nil {
        result = TryLoadVC(withName: controllerName, fromStoryboard: probablyStoryboard!)
    }
    
    if result == nil {
        let loadedStoryboard = UIStoryboard(name: "Main", bundle: nil)
        result = TryLoadVC(withName: controllerName, fromStoryboard: loadedStoryboard)
    }
    
    return result
}


func TryLoadVC(withName controllerName: String, fromStoryboard storyboard: UIStoryboard) -> UIViewController? {
    var result: UIViewController?
    
    do {
        result = storyboard.instantiateViewController(withIdentifier: controllerName)
    }
    return result
}
