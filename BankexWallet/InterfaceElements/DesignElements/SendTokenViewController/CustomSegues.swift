//
//  CustomSegues.swift
//  BankexWallet
//
//  Created by Георгий Фесенко on 28.05.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class ShowFavoritesSegue: UIStoryboardSegue {
    override func perform() {
        transition()
    }
    
    func transition() {
        let toViewController = self.destination as! FavoritesHelperViewController
        let fromViewController = self.source
        
        let screenWidth: CGFloat = UIScreen.main.bounds.size.width - 28 * 2
        let screenHeight: CGFloat = 224
        let xCenter: CGFloat = UIScreen.main.bounds.size.width / 2
        let yCenter: CGFloat = UIScreen.main.bounds.size.height / 2
        
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        backgroundView.backgroundColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
        backgroundView.alpha = 0
        toViewController.view.alpha = 0
        
        let gestureRecognizer = UITapGestureRecognizer(target: toViewController, action: #selector(toViewController.dismissView(_:)))
        
        backgroundView.addGestureRecognizer(gestureRecognizer)
       
        fromViewController.addChildViewController(toViewController)
        toViewController.view.frame = CGRect(x: xCenter - screenWidth/2, y: yCenter - screenHeight/2, width: screenWidth, height: screenHeight)
        toViewController.view.layer.cornerRadius = 15.0
        fromViewController.view.addSubview(toViewController.view)
        fromViewController.view.insertSubview(backgroundView, belowSubview: toViewController.view)
        toViewController.didMove(toParentViewController: fromViewController)

        UIView.animate(withDuration: 0.3, delay: 0, options: .beginFromCurrentState, animations: {
            toViewController.view.alpha = 1.0
            backgroundView.alpha = 1
        }) { (success) in
            
        }
    }
}

class UnwindFavoritesSegue: UIStoryboardSegue {
    override func perform() {
        transition()
    }
    
    func transition() {
        let toViewController = self.destination
        let fromViewController = self.source
        
        let backgroundView = toViewController.view.subviews[toViewController.view.subviews.count - 2]
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .beginFromCurrentState, animations: {
            toViewController.view.alpha = 1.0
            fromViewController.view.alpha = 0.0
            backgroundView.alpha = 0.0
        }) { (success) in
            fromViewController.willMove(toParentViewController: nil)
            fromViewController.view.removeFromSuperview()
            backgroundView.removeFromSuperview()
            fromViewController.removeFromParentViewController()
        }
    }
}
