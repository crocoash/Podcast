//
//  PreLoaderViewController.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 06.03.2022.
//

import UIKit

class PreLoaderViewController: UIViewController {
    
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var horizontalCenterConstraint: NSLayoutConstraint!
    
    private var heightConstraint: NSLayoutConstraint?
    private var userViewModel = UserViewModel()
    
    lazy private var topAnchorConst = view.frame.height / 2 - logoImageView.frame.height / 2
    
    lazy private var tabBarVC: TabBarViewController = {
        $0.modalPresentationStyle = .custom
        $0.transitioningDelegate = self
        $0.setUserViewModel(userViewModel)
        return $0
    }(TabBarViewController.initVC)
    
    lazy private var registrationVC: RegistrationViewController =  {
        $0.configure(userViewModel: self.userViewModel)
        $0.modalPresentationStyle = .custom
        $0.transitioningDelegate = self
        return $0
    }(RegistrationViewController.initVC)
    
    //MARK: - ViewMethods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let window = UIApplication.shared.windows.first {
            window.overrideUserInterfaceStyle = userViewModel.userDocument.user.userInterfaceStyleIsDark ? .dark : .light
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        horizontalCenterConstraint.isActive = false
        heightConstraint = logoImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: topAnchorConst)
        heightConstraint?.isActive = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if userViewModel.userDocument.user.isAuthorization {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                self.present(self.tabBarVC, animated: true)
            }
            
        } else {
            heightConstraint?.constant = 120
            UIView.animate(withDuration: 0.5, animations: { self.view.layoutIfNeeded() }) { [weak self] _ in
                guard let self = self else { return }
                self.present(self.registrationVC, animated: false)
            }
        }
        NetworkMonitor.shared.starMonitor()
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension PreLoaderViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentTransition()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissTransition()
    }
}
