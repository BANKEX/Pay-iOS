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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let url = link else { return }
        webView.frame = view.bounds
        webView.load(URLRequest(url: url))
        webView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        view.addSubview(webView)
    }
}
