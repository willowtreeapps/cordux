//
//  Cordux.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/21/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation

// MARK: Subscriber

struct Subscription<State: StateType> {
    weak var subscriber: AnyStoreSubscriber?
    let transform: ((State) -> Any)?
}

public protocol AnyStoreSubscriber: class {
    func _newState(_ state: Any)
}

public protocol SubscriberType: AnyStoreSubscriber {
    associatedtype SubscriberStateType
    func newState(_ subscription: SubscriberStateType)
}

extension SubscriberType {
    public func _newState(_ state: Any) {
        if let typedState = state as? SubscriberStateType {
            newState(typedState)
        } else {
            preconditionFailure("Expected \(SubscriberStateType.self) but received \(type(of:state))")
        }
    }
}

// MARK: Renderer

/// Renderer is a special subscriber that has semantics that match what we expect
/// in a view controller.
public protocol Renderer: AnyStoreSubscriber {
    associatedtype ViewModel
    func render(_ viewModel: ViewModel)
}

extension Renderer {
    public func _newState(_ state: Any) {
        if let viewModel = state as? ViewModel {
            render(viewModel)
        } else {
            preconditionFailure("Expected \(ViewModel.self) but received \(type(of:state))")
        }
    }
}

// MARK: Navigation Subscriber

struct NavigationSubscription {
    weak var subscriber: AnyNavigationSubscriber?
}

public protocol AnyNavigationSubscriber: class {
    func _navigate(_ command: NavigationCommand)
}

public protocol NavigationSubscriberType: AnyNavigationSubscriber {
    associatedtype SubscriberCommandType
    func navigate(_ subscription: SubscriberCommandType)
}

extension NavigationSubscriberType {
    public func _navigate(_ command: Any) {
        if let typedCommand = command as? SubscriberCommandType {
            navigate(typedCommand)
        }
    }
}
