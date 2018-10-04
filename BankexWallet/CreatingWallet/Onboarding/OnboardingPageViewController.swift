//
//  OnboardingPageViewController.swift
//  BankexWallet
//
//  Created by Георгий Фесенко on 17/07/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class OnboardingPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.getViewController(withImage: "Favorites", andCircleSelected: 0),
                self.getViewController(withImage: "ERC20", andCircleSelected: 1),
                self.getViewController(withImage: "Custom network", andCircleSelected: 2)]
    }()
    
    var currentIndex: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
    }
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        currentIndex = viewControllerIndex
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        currentIndex = viewControllerIndex
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    private func getViewController(withImage image: String, andCircleSelected circleSecelted: Int) -> UIViewController {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Onboarding") as! OnboardingViewController
        viewController.delegate = self
        viewController.configure(with: image, andCircleSelected: circleSecelted)
        return viewController
    }
    
    
}

extension OnboardingPageViewController: OnboardingDelegate {
    func nextButtonTapped() {
        guard currentIndex != orderedViewControllers.count - 1 else { return }
        self.currentIndex = currentIndex + 1
        let viewController = orderedViewControllers[currentIndex]
        setViewControllers([viewController],
                           direction: .forward,
                           animated: true,
                           completion: nil)
    }
}
