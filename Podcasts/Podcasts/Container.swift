//
//  Container.swift
//  Podcasts
//
//  Created by Anton on 08.09.2023.
//

import Foundation

enum InstanceScope {
    case perRequest
    case singleton
}

protocol ISingleton: IResolvable where Arguments == Void { }
extension ISingleton {
    static var instanceScope: InstanceScope {
        return .singleton
    }
}


protocol IPerRequest: IResolvable { }
extension IPerRequest {
    static var instanceScope: InstanceScope {
        return .perRequest
    }
}


protocol IContainer: AnyObject {
    func resolve<T: IResolvable>(args: T.Arguments) -> T
}
extension IContainer {
    func resolve<T: IResolvable>() -> T where T.Arguments == Void {
        return resolve(args: ())
    }
}


protocol IResolvable: AnyObject {
    associatedtype Arguments
   
    static var instanceScope: InstanceScope { get }
    init(container: IContainer, args: Arguments)
}

final class Container {
    private var singletons: [ObjectIdentifier: AnyObject] = [:]
    
    func makeInstance<T: IResolvable>(args: T.Arguments) -> T {
        return T(container: self, args: args)
    }
}

extension Container: IContainer {
    public func resolve<T: IResolvable>(args: T.Arguments) -> T {
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
        }
    }
}
