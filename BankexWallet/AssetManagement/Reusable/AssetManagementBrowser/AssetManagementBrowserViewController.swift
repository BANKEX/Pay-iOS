//
//  AssetManagementBrowserViewController.swift
//  BankexWallet
//
//  Created by Oleg Kolomyitsev on 03/12/2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import UIKit
import WebKit

class AssetManagementBrowserViewController: UIViewController {
    
    let webView = WKWebView()
    var link: URL?
    var showDismissButton = false
    
    private lazy var backButton: UIBarButtonItem  = {
        return UIBarButtonItem(customView: BackButtonView.create(self, action: #selector(dismissBrowser)))
    }()
    
    @objc func dismissBrowser() {
        dismiss(animated: true, completion: nil)
    }
    
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
