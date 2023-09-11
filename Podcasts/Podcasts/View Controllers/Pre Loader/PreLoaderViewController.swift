//
//  PreLoaderViewController.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 06.03.2022.
//

import UIKit

class PreLoaderViewController: UIViewController, IPerRequest {
    
    
    typealias Arguments = Void
    
    private let userViewModel: UserViewModel
    private let likeManager: LikeManager
    private let favouriteManager: FavouriteManager
    private let firestorageDatabase: FirestorageDatabase
    private let player: Player
    private let downloadService: DownloadService
    private let firebaseDataBase: FirebaseDatabase
    private let apiService: ApiService
    private let dataStoreManager: DataStoreManager
    private let listeningManager: ListeningManager
    private let container: IContainer
    
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var horizontalCenterConstraint: NSLayoutConstraint!
    
    private var heightConstraint: NSLayoutConstraint?
    
    lazy private var topAnchorConst = view.frame.height / 2 - logoImageView.frame.height / 2
    
    lazy private var tabBarVC: TabBarViewController = TabBarViewController.create { [weak self] coder in
        
        guard let self = self else { fatalError() }
        
        let tabBarViewController: TabBarViewController = container.resolve()
        tabBarViewController.modalPresentationStyle = .custom
        tabBarViewController.transitioningDelegate = self
        return tabBarViewController
        
    }
    
    lazy private var registrationVC = RegistrationViewController.storyboard.instantiateViewController(identifier: RegistrationViewController.identifier) { [weak self] coder in
        guard let self = self else { fatalError() }
        
        let registrationVC: RegistrationViewController = container.resolve()
        registrationVC.modalPresentationStyle = .custom
        registrationVC.transitioningDelegate = self
        return registrationVC
    }
    
    required init(container: IContainer, args: Void) {
        
        self.favouriteManager = container.resolve()
        self.likeManager = container.resolve()
        self.userViewModel = container.resolve()
        self.player = container.resolve()
        self.downloadService = container.resolve()
        self.firestorageDatabase = container.resolve()
        self.firebaseDataBase = container.resolve()
        self.apiService = container.resolve()
        self.dataStoreManager = container.resolve()
        self.listeningManager = container.resolve()
        self.container = container
        
        super.init(nibName: Self.identifier, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        horizontalCenterConstraint.isActive = false
        heightConstraint = logoImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: topAnchorConst)
        heightConstraint?.isActive = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if userViewModel.userIsLogin {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                self.present(self.tabBarVC, animated: true)
                self.view.isHidden = true
            }
            
        } else {
            heightConstraint?.constant = 120
            UIView.animate(withDuration: 0.5, animations: { self.view.layoutIfNeeded() }) { [weak self] _ in
                guard let self = self else { return }
                self.present(self.registrationVC, animated: false)
                self.view.isHidden = true
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
