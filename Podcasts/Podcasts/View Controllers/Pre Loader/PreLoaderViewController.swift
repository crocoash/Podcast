//
//  PreLoaderViewController.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 06.03.2022.
//

import UIKit

class PreLoaderViewController: UIViewController {
    
    private let userViewModel: UserViewModel
    private let likeManager: LikeManagerInput
    private let favouriteManager: FavouriteManagerInput
    private let firestorageDatabase: FirestorageDatabaseInput
    private let player: PlayerInput
    private let downloadService: DownloadServiceInput
    private let firebaseDataBase: FirebaseDatabaseInput
    private let apiService: ApiServiceInput
    private let dataStoreManager: DataStoreManagerInput
    private let listeningManager: ListeningManagerInput
    
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var horizontalCenterConstraint: NSLayoutConstraint!
    
    private var heightConstraint: NSLayoutConstraint?
    
    lazy private var topAnchorConst = view.frame.height / 2 - logoImageView.frame.height / 2
    
    lazy private var tabBarVC: TabBarViewController = TabBarViewController.create { [weak self] coder in
        
        guard let self = self else { fatalError() }
        
        let tabBarViewController = TabBarViewController(coder: coder,
                                                        userViewModel: userViewModel,
                                                        firestorageDatabase: firestorageDatabase,
                                                        player: player,
                                                        downloadService: downloadService,
                                                        favouriteManager: favouriteManager,
                                                        likeManager: likeManager,
                                                        firebaseDataBase: firebaseDataBase,
                                                        apiService: apiService,
                                                        dataStoreManager: dataStoreManager,
                                                        listeningManager: listeningManager)
        
        guard let tabBarViewController = tabBarViewController else { fatalError() }
        tabBarViewController.modalPresentationStyle = .custom
        tabBarViewController.transitioningDelegate = self
        return tabBarViewController
        
    }
    
    lazy private var registrationVC = RegistrationViewController.storyboard.instantiateViewController(identifier: RegistrationViewController.identifier) { [weak self] coder in
        guard let self = self else { fatalError() }
        
        let registrationVC = RegistrationViewController(coder: coder,
                                                        userViewModel: userViewModel,
                                                        favouriteManager: favouriteManager,
                                                        likeManager: likeManager,
                                                        player: player,
                                                        firebaseDataBase: firebaseDataBase,
                                                        apiService: apiService,
                                                        downloadService: downloadService,
                                                        dataStoreManager: dataStoreManager,
                                                        listeningManager: listeningManager)
        
        guard let registrationVC = registrationVC else { fatalError() }
        
        registrationVC.modalPresentationStyle = .custom
        registrationVC.transitioningDelegate = self
        return registrationVC
    }
        
    init?(coder: NSCoder,
          userViewModel: UserViewModel,
          likeManager: LikeManagerInput,
          favouriteManager: FavouriteManagerInput,
          firestorageDatabase: FirestorageDatabaseInput,
          player: PlayerInput,
          downloadService: DownloadServiceInput,
          firebaseDataBase: FirebaseDatabaseInput,
          apiService: ApiServiceInput,
          dataStoreManager: DataStoreManagerInput,
          listeningManager: ListeningManagerInput) {
        
        self.favouriteManager = favouriteManager
        self.likeManager = likeManager
        self.userViewModel = userViewModel
        self.player = player
        self.downloadService = downloadService
        self.firestorageDatabase = firestorageDatabase
        self.firebaseDataBase = firebaseDataBase
        self.apiService = apiService
        self.dataStoreManager = dataStoreManager
        self.listeningManager = listeningManager
        
        super.init(coder: coder)
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
