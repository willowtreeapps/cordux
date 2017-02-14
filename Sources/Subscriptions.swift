//
//  Cordux.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/21/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation

struct Subscription<State: StateType> {
    weak var subscriber: AnyStoreSubscriber?
    let transform: ((State) -> Any)?
}

public protocol AnyStoreSubscriber: class {
    func _newState(_ state: Any)
}

public protocol SubscriberType: AnyStoreSubscriber {
    associatedtype StoreSubscriberStateType
    func newState(_ subscription: StoreSubscriberStateType)
}

extension SubscriberType {
    public func _newState(_ state: Any) {
        if let typedState = state as? StoreSubscriberStateType {
            newState(typedState)
        } else {
            #if swift(>=3)
                preconditionFailure("Expected \(StoreSubscriberStateType.self) but received \(type(of:state))")
            #else
                preconditionFailure("Expected \(StoreSubscriberStateType.self) but received \(state.dynamicType))")
            #endif
        }
    }
}

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
            #if swift(>=3)
                preconditionFailure("Expected \(ViewModel.self) but received \(type(of:state))")
            #else
                preconditionFailure("Expected \(ViewModel.self) but received \(state.dynamicType))")
            #endif
        }
    }
}
