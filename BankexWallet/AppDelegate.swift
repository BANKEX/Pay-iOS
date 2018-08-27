//
//  AppDelegate.swift
//  BankexWallet
//
//  Created by Alexander Vlasov on 26.01.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import CoreData
import Fabric
import Crashlytics
import Amplitude_iOS
import Firebase
import PushKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static var isAlreadyLaunchedOnce = false // Used to avoid 2 FIRApp configure

    var window: UIWindow?
    var navigationVC:UINavigationController?
    var currentViewController:UIViewController?
    
    enum tabBarPage: Int {
        case main = 0
        case wallet = 1
        case settings = 2
    }
    
    static var initiatingTabBar: tabBarPage = .main


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if !AppDelegate.isAlreadyLaunchedOnce {
            FirebaseApp.configure()
            AppDelegate.isAlreadyLaunchedOnce = true
        }
        Amplitude.instance().initializeApiKey("27da55fc989fc196d40aa68b9a163e36")
        Crashlytics.start(withAPIKey: "5b2cfd1743e96d92261c59fb94482a93c8ec4e13")
        Fabric.with([Crashlytics.self])
        let initialRouter = InitialLogicRouter()
        let isOnboardingNeeded = UserDefaults.standard.value(forKey: "isOnboardingNeeded")
        if isOnboardingNeeded == nil  {
            showOnboarding()
        }
        guard let navigationController = window?.rootViewController as? UINavigationController else {
            return true
        }
        
        initialRouter.navigateToMainControllerIfNeeded(rootControler: navigationController)
        window?.backgroundColor = .white
        return true
    }
    
    func showInitialVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialNav = storyboard.instantiateInitialViewController() as? UINavigationController
        UIView.transition(with: window!, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.window?.rootViewController = initialNav
        })
        window?.makeKeyAndVisible()
    }
    
    func showOnboarding() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let onboarding = storyboard.instantiateViewController(withIdentifier: "OnboardingPage")
        window?.rootViewController = onboarding
    }
    
    func showTabBar() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBar = storyboard.instantiateViewController(withIdentifier: "MainTabController") as? UITabBarController
        UIView.transition(with: window!, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.window?.rootViewController = tabBar
        })
        window?.makeKeyAndVisible()
    }


    func applicationWillEnterForeground(_ application: UIApplication) {
        if UserDefaults.standard.value(forKey: Keys.multiSwitch.rawValue) == nil {
            UserDefaults.standard.set(true, forKey: Keys.multiSwitch.rawValue)
        }
        if UserDefaults.standard.bool(forKey: Keys.multiSwitch.rawValue) && UserDefaults.standard.bool(forKey: "isNotFirst")  {
            showPasscode()
        }
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if let incomingURL = userActivity.webpageURL {
            let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) {
                [weak self] (dynamicLink, error) in
                if let dynamicLink = dynamicLink, let _ = dynamicLink.url {
                    self?.handleIncomingDynamicLink(dynamicLink)
                }
            }
            return linkHandled
        } else {
            return false
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            print("I am handling a link through the openURL method (custom scheme instead of universal)")
            self.handleIncomingDynamicLink(dynamicLink)
            return true
        } else {
            return false
        }
    }
    
    func handleIncomingDynamicLink(_ dynamicLink: DynamicLink) {
        if dynamicLink.matchType == .weak {
            print("I think your incoming link parameter is \(dynamicLink.url!) but I'm not shure")
        } else {
            guard let pathComponents = dynamicLink.url?.pathComponents else {return}
            for nextPiece in pathComponents {
                if nextPiece == "helloworld" {
                    AppDelegate.initiatingTabBar = .settings
                }
                
                // parsing
            }
            print("Incoming link parameter is \(dynamicLink.url!)")
        }
        
    }

    // MARK: - Core Data stack

//    lazy var persistentContainer: NSPersistentContainer = {
//        /*
//         The persistent container for the application. This implementation
//         creates and returns a container, having loaded the store for the
//         application to it. This property is optional since there are legitimate
//         error conditions that could cause the creation of the store to fail.
//        */
//        let container = NSPersistentContainer(name: "BankexWallet")
//        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//            if let error = error as NSError? {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                 
//                /*
//                 Typical reasons for an error here include:
//                 * The parent directory does not exist, cannot be created, or disallows writing.
//                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
//                 * The device is out of space.
//                 * The store could not be migrated to the current model version.
//                 Check the error message to determine what the actual problem was.
//                 */
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        })
//        return container
//    }()

    // MARK: - Core Data Saving support

//    func saveContext () {
//        let context = persistentContainer.viewContext
//        if context.hasChanges {
//            do {
//                try context.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nserror = error as NSError
//                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//            }
//        }
//    }
    
    func showPasscode() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "passcodeEnterController") as? PasscodeEnterController {
            currentPasscodeViewController = vc
            window?.rootViewController?.present(vc, animated: true, completion: nil)
        }
    }
}

var currentPasscodeViewController: PasscodeEnterController?

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
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
}


