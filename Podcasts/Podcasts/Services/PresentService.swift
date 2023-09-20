//
//  PresentService.swift
//  Podcasts
//
//  Created by Anton on 11.09.2023.
//

import UIKit

public class PresenterService: ISingleton {
    
    private unowned let container: IContainer
    
    private var topViewController: UIViewController? {
        let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
        return findTopViewController(in: keyWindow?.rootViewController)
    }
    
    required init(container: IContainer, args: Void) {
        self.container = container
    }
    
    func present<VC: UIViewController & IHaveViewModel>( _ viewController: VC.Type,  args: VC.ViewModel.Arguments) where VC.ViewModel: IResolvable {
        
        let vc = VC.create { coder in
            VC(coder: coder)
        }
        vc.viewModel = container.resolve(args: args)
        
        topViewController?.present(vc, animated: true)
    }
    
    func present<VC: UIViewController>( _ viewController: VC.Type) {
        
        let vc = VC()
        topViewController?.present(vc, animated: true)
    }
    
    public func dismiss() {
        topViewController?.dismiss(animated: true, completion: nil)
    }

    private func findTopViewController(in controller: UIViewController?) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return findTopViewController(in: navigationController.topViewController)
        } else if let tabController = controller as? UITabBarController,
            let selected = tabController.selectedViewController {
            return findTopViewController(in: selected)
        } else if let presented = controller?.presentedViewController {
            return findTopViewController(in: presented)
        }
        return controller
    }
}

public extension PresenterService {
//    func present<VC: UIViewController & IHaveViewModel>(
//        _ viewController: VC.Type) where VC.ViewModel: IResolvable, VC.ViewModel.Arguments == Void {
//        
//        present(viewController, args: ())
//    }
}
