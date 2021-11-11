//
//  SplashScreenViewController.swift
//  Podcasts
//
//  Created by student on 11.11.2021.
//

import UIKit

class SplashScreenViewController: UIViewController {


    @IBOutlet weak var nixWelcome: UIImageView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        guard let registationViewController = storyboard?.instantiateViewController(identifier: RegistrationViewController.identifier) as? RegistrationViewController else{
            fatalError("Unable to instantiate view controller with Identifier RegistationViewController")
        }
        registationViewController.modalPresentationStyle = .custom

        
        UIView.animate(withDuration: 3.0, delay: 0.2, options: .beginFromCurrentState, animations: {
            var frame : CGRect = self.nixWelcome.frame
            frame
            self.nixWelcome.frame = frame
        },
        completion: {_ in
            self.present(registationViewController,animated: false)
        })
    }
}

extension SplashScreenViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentTransition()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissTransition()
    }
}
