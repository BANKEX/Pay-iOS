//
//  AssetManagementBrowserViewController.swift
//  BankexWallet
//
//  Created by Oleg Kolomyitsev on 03/12/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import WebKit

class AssetManagementBrowserViewController: UIViewController {
    
    let webView = WKWebView()
    var link: URL?
    var showDismissButton = false
    
    private lazy var backButton: UIBarButtonItem  = {
        let backButtonView = BackButtonView.create { [weak self] (_) in
            self?.dismiss(animated: true, completion: nil)
        }
        
        return UIBarButtonItem(customView: backButtonView)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let url = link else { return }
        webView.frame = view.bounds
        webView.load(URLRequest(url: url))
        webView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        view.addSubview(webView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.leftBarButtonItem = showDismissButton ? backButton : nil
    }
    
}
