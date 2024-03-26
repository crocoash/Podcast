//
//  File.swift
//  Podcasts
//
//  Created by Anton on 10.09.2023.
//

import UIKit

protocol IHaveViewModel: AnyObject {
    associatedtype ViewModel
    
    var viewModel: ViewModel { get set }
    @MainActor func viewModelChanged(_ viewModel: ViewModel)
    @MainActor func viewModelChanged()
    @MainActor func configureUI()
    @MainActor func updateUI()
}

extension IHaveViewModel where Self: UIViewController {
    func viewModelChanged(_ viewModel: ViewModel) {}
    func viewModelChanged() {}
}

private var viewModelKey: UInt8 = 0

extension IHaveViewModel {
    
    var anyViewModel: Any? {
        get {
            return objc_getAssociatedObject(self, &viewModelKey)
        }
        set {
            (anyViewModel as? INotifyOnChanged)?.changed.unsubscribe(self)
            let viewModel1 = newValue as? ViewModel
            
            objc_setAssociatedObject(self, &viewModelKey, viewModel1, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                viewModelChanged(viewModel)
            }
        
            if self is UIView || !(self is any IResolvable) {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    viewModelChanged()
                }
            }
            
            (newValue as? any INotifyOnChanged)?.changed.subscribe(self) { this, _ in
                DispatchQueue.main.async {
                    this.viewModelChanged()
                }
            }
        }
    }
    
    var viewModel: ViewModel {
        get {
            return anyViewModel as! ViewModel
        }
        set {
            anyViewModel = newValue
        }
    }
}

private var changedEventKey: UInt8 = 0

public protocol INotifyOnChanged: AnyObject {
    var changed: Event<Void> { get }
}

public extension INotifyOnChanged {
    var changed: Event<Void> {
        if let event = objc_getAssociatedObject(self, &changedEventKey) as? Event<Void> {
            return event
        } else {
            let event = Event<Void>()
            objc_setAssociatedObject(self, &changedEventKey, event, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return event
        }
    }
}


public final class Event<Args> {
    // Тут живут подписчики на событие и их обработчики этого события
    private var handlers: [Weak<AnyObject>: (Args) -> Void] = [:]
    
    public init() {}

    public func subscribe<Subscriber: AnyObject>( _ subscriber: Subscriber, handler: @escaping (Subscriber, Args) -> Void) {

        // Формируем ключ
        let key = Weak<AnyObject>(subscriber)
        // Почистим массив обработчиков от мёртвых объектов, чтобы не засорять память
        handlers = handlers.filter { $0.key.isAlive }
        // Создаём обработчик события
        handlers[key] = { [weak subscriber] args in
            // Захватывает подписчика слабой ссылкой и вызываем обработчик,
            // только если подписчик жив
            guard let subscriber = subscriber else { return }
            handler(subscriber, args)
        }
    }

    public func unsubscribe(_ subscriber: AnyObject) {
        // Отписываемся от события, удаляя соответствующий обработчик из словаря
        let key = Weak<AnyObject>(subscriber)
        handlers[key] = nil
    }
    
    public func raise(_ args: Args) {
        // Получаем список обработчиоков с живыми подписчиками
        let aliveHandlers = handlers.filter { $0.key.isAlive }
        // Для всех живых подписчиков выполняем код обработчиков событий
        aliveHandlers.forEach {
            $0.value(args)
        }
    }
}

public extension Event where Args == Void {
    
    func subscribe<Subscriber: AnyObject>( _ subscriber: Subscriber,  handler: @escaping (Subscriber) -> Void) {
        subscribe(subscriber) { this, _ in
            handler(this)
        }
    }

    func raise() {
        Task { @MainActor in
            raise(())
        }
    }
}

final class Weak<T: AnyObject> {
    
    private let id: ObjectIdentifier?
    public private(set) weak var value: T?
    
    public var isAlive: Bool {
        return value != nil
    }
    
    public init(_ value: T?) {
        self.value = value
        if let value = value {
            id = ObjectIdentifier(value)
        } else {
            id = nil
        }
    }
}

extension Weak: Hashable {
    public static func == (lhs: Weak<T>, rhs: Weak<T>) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        if let id = id {
            hasher.combine(id)
        }
    }
}
