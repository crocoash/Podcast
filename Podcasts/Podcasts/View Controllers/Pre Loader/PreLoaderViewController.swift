//
//  PreLoaderViewController.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 06.03.2022.
//

import UIKit

class PreLoaderViewController: UIViewController, IHaveStoryBoard {
    
    typealias Args = Void
    
    private let userViewModel: UserViewModel
    private let container: IContainer
    
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var horizontalCenterConstraint: NSLayoutConstraint!
    
    private var heightConstraint: NSLayoutConstraint?
    
    lazy private var topAnchorConst = view.frame.height / 2 - logoImageView.frame.height / 2
    
    lazy private var tabBarVC: TabBarViewController = {
        let tabBarViewController: TabBarViewController = container.resolve()
        tabBarViewController.modalPresentationStyle = .custom
        tabBarViewController.transitioningDelegate = self
        return tabBarViewController
    }()
    
    lazy private var registrationVC: RegistrationViewController = {
        let registrationVC: RegistrationViewController = container.resolve()
        registrationVC.modalPresentationStyle = .custom
        registrationVC.transitioningDelegate = self
        return registrationVC
    }()
    
    //MARK: init
    required init?(container: IContainer, args: (args: Args, coder: NSCoder)) {

        self.userViewModel = container.resolve()
        self.container = container

        super.init(coder: args.coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        horizontalCenterConstraint.isActive = false
        heightConstraint = logoImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: topAnchorConst)
        heightConstraint?.isActive = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if userViewModel.userIsLogin {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
                guard let self = self else { return }
                present(tabBarVC, animated: true)
                view.isHidden = true
            }
            
        } else {
            heightConstraint?.constant = 120
            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                guard let self = self else { return }
                view.layoutIfNeeded()
            }) { [weak self] _ in
                guard let self = self else { return }
                present(registrationVC, animated: false)
                view.isHidden = true
            }
        }
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
