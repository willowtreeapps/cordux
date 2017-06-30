//
//  Cordux.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/21/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation

/// StateType is a marker type that defines the state.
///
/// As a convenience, it is also a command that means "Update the store's state to this value."
public protocol StateType: Command {}

struct StateSubscription<State: StateType> {
    weak var subscriber: AnyStateSubscriber?
    let transform: ((State) -> Any)?
}

public protocol AnyStateSubscriber: class {
    func _newState(_ state: Any)
}

public protocol StateSubscriberType: AnyStateSubscriber {
    associatedtype SubscriberStateType
    func newState(_ subscription: SubscriberStateType)
}

extension StateSubscriberType {
    public func _newState(_ state: Any) {
        if let typedState = state as? SubscriberStateType {
            newState(typedState)
        } else {
            preconditionFailure("Expected \(SubscriberStateType.self) but received \(type(of:state))")
        }
    }
}

/// Renderer is a special subscriber that has semantics that match what we expect
/// in a view controller.
public protocol Renderer: AnyStateSubscriber {
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
