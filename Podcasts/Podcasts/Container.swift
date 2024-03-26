//
//  Container.swift
//  Podcasts
//
//  Created by Anton on 08.09.2023.
//

import Foundation
import UIKit

protocol IResolvable: AnyObject {
    associatedtype Arguments
    init?(container: IContainer, args: Arguments)
}

protocol ISingleton: IResolvable {
    init(container: IContainer, args: Arguments)
}

protocol IPerRequest: IResolvable {}

/// StoryBoard
protocol IHaveStoryBoard: UIViewController & IResolvable where Arguments == (args: Args, coder: NSCoder) {
    associatedtype Args
}

protocol IHaveStoryBoardAndViewModel: UIViewController & IResolvable & IHaveViewModel where ViewModel: IPerRequest, Arguments == (args: Args, coder: NSCoder) {
    associatedtype Args
}

protocol IHaveXib: AnyObject, IResolvable {}
protocol IHaveXibAndViewModel: AnyObject, IResolvable, IHaveViewModel where ViewModel: IPerRequest {}

//MARK: - IContainer
protocol IContainer: AnyObject {
    func resolve<T: ISingleton>(args: T.Arguments) -> T
    func resolve<T: IPerRequest>(args: T.Arguments) -> T
    func resolve<T: IHaveXib>(args: T.Arguments) -> T
    func resolve<T: IHaveXibAndViewModel>(args: T.Arguments, argsVM: T.ViewModel.Arguments) -> T
    func resolve<T: IHaveStoryBoard>(args: T.Args) -> T
    func resolve<T: IHaveStoryBoardAndViewModel>(args: T.Args, argsVM: T.ViewModel.Arguments) -> T
}

extension IContainer {
    func resolve<T: ISingleton>() -> T where T.Arguments == Void {
        return resolve(args: ())
    }
}

//MARK: - Container
final class Container {
    private var singletons: [ObjectIdentifier: AnyObject] = [:]
    
    func makeInstance<T: IResolvable>(args: T.Arguments) -> T {
        return T(container: self, args: args)!
    }
}

extension Container: IContainer {
   
    func resolve<T: ISingleton>(args: T.Arguments) -> T {
        let key = ObjectIdentifier(T.self)
        if let cached = singletons[key], let instance = cached as? T {
            return instance
        } else {
            let instance: T = makeInstance(args: args)
            singletons[key] = instance
            return instance
        }
    }
    
    func resolve<T: IPerRequest>(args: T.Arguments) -> T {
        return makeInstance(args: args)
    }

    func resolve<T: IHaveXib>(args: T.Arguments) -> T {
        let instance: T = makeInstance(args: args)
        
        switch instance {
        case let view as UIView:
            view.loadFromXib()
        case _ as UIViewController:
            break
        default:
            break
        }
        
        guard !(instance is any IHaveViewModel) else { fatalError("use IHaveXibAndViewModel protocol ")  }
        return instance
    }
    
    func resolve<T: IHaveXibAndViewModel>(args: T.Arguments, argsVM: T.ViewModel.Arguments) -> T {
        let instance: T = makeInstance(args: args)
        switch instance {
        case let view as UIView:
            view.loadFromXib()
            instance.viewModel = makeInstance(args: argsVM)
            DispatchQueue.main.async {
                instance.configureUI()
                instance.updateUI()
            }
        case _ as UIViewController:
            instance.viewModel = makeInstance(args: argsVM)
        default:
            break
        }
        return instance
    }

    //MARK: IHaveStoryBoard
    func resolve<T: IHaveStoryBoard>(args: T.Args) -> T {
        let vc: T = T.create { [weak self] coder in
            guard let self = self else { fatalError() }
            
            let vc: T = makeInstance(args: (args: args, coder: coder))
            if let vc1 = vc as? any IHaveViewModel {
                guard vc1.anyViewModel != nil else { fatalError("Please use IHaveStoryBoardAndViewModel protocol for viewcontroller") }
            }
            
            return vc
        }
        return vc
    }
    
    func resolve<T: IHaveStoryBoardAndViewModel>(args: T.Args, argsVM: T.ViewModel.Arguments) -> T {
        return T.create { [weak self] coder in
            guard let self = self else { fatalError()}
            let vc: T = makeInstance(args: (args: args, coder: coder))
            vc.viewModel = makeInstance(args: argsVM)
//            DispatchQueue.main.async {
//                vc.configureUI()
//                vc.updateUI()
//            }
            
            return vc
        }
    }
}
