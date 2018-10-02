//
//  UIViewController+Extensions.swift
//  BankexWallet
//
//  Created by Vladislav on 17.09.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import UIKit

private var handle = 0

public class ClosureSelector<Parameter> {
    public let selector: Selector
    private let closure: (Parameter)->()
    
    init(closure: @escaping (Parameter)->()){
        self.selector = #selector(ClosureSelector.target)
        self.closure = closure
    }
    
    @objc func target( param: AnyObject) {
        closure(param as! Parameter)
    }
}
public class EmptyClosureSelector {
    public let selector: Selector
    private let closure: ()->()
    
    init(closure: @escaping ()->()) {
        self.selector = #selector(EmptyClosureSelector.target)
        self.closure = closure
    }
    
    @objc func target() {
        closure()
    }
}

public extension UIButton {
    func onTouch(_ action: @escaping ()->()) {
        add(on: .touchUpInside, action: action)
    }
    func add(on controlEvents: UIControlEvents, action: @escaping ()->()) {
        let closureSelector = EmptyClosureSelector(closure: action)
        objc_setAssociatedObject(self, &handle, closureSelector, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        self.addTarget(closureSelector, action: closureSelector.selector, for: controlEvents)
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    public func addBackButton(title:String,image:UIImage, action:(()->())?) {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.titleLabel?.textColor = WalletColors.mainColor
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
        button.setImage(image, for: .normal)
        if let action = action {
            button.onTouch(action)
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
    

    
    @objc func touch() {
       
    }
    
    func setupViewResizerOnKeyboardShown() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(UIViewController.keyboardWillShowForResizing),
                                               name: Notification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(UIViewController.keyboardWillHideForResizing),
                                               name: Notification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
    
    @objc func keyboardWillShowForResizing(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let window = self.view.window?.frame {
            // We're not just minusing the kb height from the view height because
            // the view could already have been resized for the keyboard before
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width,
                                     height: window.origin.y + window.height - keyboardSize.height)
            print(keyboardSize.height)
        } else {
            debugPrint("We're showing the keyboard and either the keyboard size or window is nil: panic widely.")
        }
    }
    
    @objc func keyboardWillHideForResizing(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let viewHeight = self.view.frame.height
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width,
                                     height: viewHeight + keyboardSize.height)
        } else {
            debugPrint("We're about to hide the keyboard and the keyboard size is nil. Now is the rapture.")
        }
    }
    
    func showAnimation(with contraint:NSLayoutConstraint) {
        if #available(iOS 11.0, *) {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let bottomInset = appDelegate.window?.safeAreaInsets.bottom
            contraint.constant = bottomInset!
        }else {
            contraint.constant = 0
        }
        self.view.layoutIfNeeded()
    }
    
    func hideAnimation(with contraint:NSLayoutConstraint) {
        contraint.constant = -58.0
        self.view.layoutIfNeeded()
    }
    
}
