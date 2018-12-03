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
        
        navigationItem.leftBarButtonItem = showDismissButton
            ? UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissBrowser))
            : nil
    }
    
    @objc func dismissBrowser() {
        dismiss(animated: true, completion: nil)
    }
    
}
