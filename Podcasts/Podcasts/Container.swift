//
//  Container.swift
//  Podcasts
//
//  Created by Anton on 08.09.2023.
//

import Foundation
import UIKit

enum InstanceScope {
    case perRequest
    case singleton
    case storyBoard
    case xib
}

protocol ISingleton: IResolvable where Arguments == Void {
    init(container: IContainer, args: Arguments)
}
extension ISingleton {
    static var instanceScope: InstanceScope {
        return .singleton
    }
}

protocol IPerRequest: IResolvable {}
extension IPerRequest {
    static var instanceScope: InstanceScope {
        return .perRequest
    }
}

protocol IHaveStoryBoard: UIViewController & IResolvable where Arguments == (args: Args, coder: NSCoder) {
    associatedtype Args
}
extension IHaveStoryBoard {
    static var instanceScope: InstanceScope {
        return .storyBoard
    }
}

protocol IHaveXib: IResolvable {}
extension IHaveXib {
    static var instanceScope: InstanceScope {
        return .xib
    }
}


//MARK: - IContainer
protocol IContainer: AnyObject {
    
    func resolve<T: IResolvable>(args: T.Arguments) -> T
    func resolve<T: IHaveStoryBoard>(args: T.Args) -> T
}

extension IContainer {
    
    func resolve<T: IResolvable>() -> T where T.Arguments == Void {
        return resolve(args: ())
    }
    
    ///IHaveStoryBoard
    func resolve<T: IHaveStoryBoard>() -> T where T.Args == Void {
        return resolve(args: ())
    }
    
//    func resolveWithModel<T: IHaveStoryBoard & IHaveViewModel>(args: T.Args, argsVM: T.ViewModel.Arguments) -> T where T.ViewModel: IResolvable {
//        let vc: T = resolve(args: args)
//        vc.viewModel = resolve(args: argsVM)
//        return vc
//    }
//    
//    func resolveWithModel<T: IHaveStoryBoard & IHaveViewModel>(argsVM: T.ViewModel.Arguments) -> T where T.ViewModel: IResolvable, T.Args == Void {
//        let vc: T = resolve(args: ())
//        vc.viewModel = resolve(args: argsVM)
//        return vc
//    }
//    
//    func resolveWithModel<T: IHaveStoryBoard & IHaveViewModel>(args: T.Args) -> T where T.ViewModel: IResolvable, T.ViewModel.Arguments == Void {
//        let vc: T = resolve(args: args)
//        vc.viewModel = resolve(args: ())
//        return vc
//    }
    
    ///xib
    func resolve<T: IHaveXib>() -> T where T.Arguments == Void {
        return resolve(args: ())
    }
    
//    func resolveWithModel<T: IHaveXib & IHaveViewModel>(args: T.Arguments, argsVM: T.ViewModel.Arguments) -> T where T.ViewModel: IResolvable {
//        let view: T = resolve(args: args)
//        view.viewModel = resolve(args: argsVM)
//        return view
//    }
//    
//    func resolveWithModel<T: IHaveXib & IHaveViewModel>(args: T.Arguments) -> T where T.ViewModel: IResolvable, T.ViewModel.Arguments == Void {
//        let view: T = resolve(args: args)
//        view.viewModel = resolve(args: ())
//        return view
//    }
}

protocol IResolvable: AnyObject {
    associatedtype Arguments
    init?(container: IContainer, args: Arguments)
    static var instanceScope: InstanceScope { get }
}

//MARK: - Container
final class Container {
    private var singletons: [ObjectIdentifier: AnyObject] = [:]
    
    func makeInstance<T: IResolvable>(args: T.Arguments) -> T {
        return T(container: self, args: args)!
    }
}

extension Container: IContainer {
    
     func resolve<T: IResolvable>(args: T.Arguments) -> T {
        switch T.instanceScope {
        case .perRequest:
            return makeInstance(args: args)
        case .singleton:
            let key = ObjectIdentifier(T.self)
            if let cached = singletons[key], let instance = cached as? T {
                return instance
            } else {
                let instance: T = makeInstance(args: args)
                singletons[key] = instance
                return instance
            }
        case .xib:
            let ui: T = makeInstance(args: args)
            if let ui = ui as? any IHaveXib {
                if let view = ui as? UIView {
                     view.loadFromXib()
                } else if let vc = ui as? UIViewController {
                    
                }
            }
            return ui
        case .storyBoard:
            fatalError("user another resolve")
        }
    }

    //MARK: IHaveStoryBoard
    func resolve<T: IHaveStoryBoard>(args: T.Args) -> T {
        let vc: T = T.create { [weak self] coder in
            guard let self = self,
                  let vc: T = T(container: self, args: (args: args, coder: coder)) else { fatalError() }
            return vc
        }
        return vc
    }
}
