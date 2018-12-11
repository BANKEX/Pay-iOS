//
//  UIViewController+Extensions.swift
//  BankexWallet
//
//  Created by Vladislav on 19.07.2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import UIKit

extension UIViewController {
    public func showCreationAlert() {
        let alertViewController = UIAlertController(title: "Error", message: "Couldn't add key", preferredStyle: .alert)
        alertViewController.addCancel()
        self.present(alertViewController, animated: true)
    }
    
    public func addPopover(in view:UIView, rect:CGRect, _ direction:UIPopoverArrowDirection? = nil) {
        guard let popover = self.popoverPresentationController else { return }
        popover.sourceView = view
        popover.sourceRect = rect
        if let direct = direction { popover.permittedArrowDirections = [direct] } else { popover.permittedArrowDirections = [] }
    }
    
    func presentPopUp(_ vc:UIViewController, size:CGSize? = nil , shower:UIViewController? = nil) {
        let nv = UINavigationController(rootViewController: vc)
        if let size = size {
           nv.preferredContentSize = size
        }
        nv.modalPresentationStyle = .formSheet
        if let shower = shower {
            shower.present(nv, animated: true, completion: nil)
        }else { splitViewController?.present(nv, animated: true, completion: nil) }
    }
    
    func secondaryVC() -> UINavigationController? {
        return splitViewController?.viewControllers.last as? UINavigationController
    }
    func primaryVC() -> UIViewController? {
        return splitViewController?.viewControllers.first as? UINavigationController
    }
    
    
    func selectSection(_ section:Int) {
        guard let nav = splitViewController?.viewControllers[0] as? UINavigationController else { return }
        nav.popToRootViewController(animated: false)
        guard let vc = nav.topViewController as? ListSectionsViewController else { return }
        vc.selectRow(section)
    }
    
    public func customBackButton(title:String? = "  Back") -> UIButton {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named:"BackArrow"), for: .normal)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
        btn.setTitleColor(UIColor.mainColor, for: .normal)
        return btn
    }
    
    public func hideAddRightButton() {
        navigationItem.setRightBarButton(nil, animated: false)
    }
    
    public func navBarColor(_ color:UIColor) {
        navigationController?.navigationBar.barTintColor = color
    }
    
    public func statusBarColor(_ color:UIColor?) {
        UIApplication.shared.statusBarView?.backgroundColor = color
    }
    
    public func navBarTintColor(_ color:UIColor) {
        navigationController?.navigationBar.tintColor = color
    }
}
