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
    
    lazy var topAnchorConst = view.frame.height / 2 - logoImageView.frame.height / 2
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        horizontalCenterConstraint.isActive = false
        
        heightConstraint = logoImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: topAnchorConst)
        heightConstraint?.isActive = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        heightConstraint?.constant = 120
  
        UIView.animate(withDuration: 0.5, animations: { self.view.layoutIfNeeded() }) { _ in
            let vc = RegistrationViewController.initVC
            self.present(vc, animated: false)
        }
    }
}
