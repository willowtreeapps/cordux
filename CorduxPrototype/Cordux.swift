//
//  Cordux.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/21/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

protocol StateType {
    var route: Route { get set }
}

protocol Action {}

protocol ReducerType {
    associatedtype State
    func handleAction(action: Action, state: State) -> State
}

protocol SubscriberType: AnyStoreSubscriber {
    associatedtype StoreSubscriberStateType
    func newState(subscription: StoreSubscriberStateType)
}

final class CorduxStore<State : StateType> {
    var state: State
    var reducer: AnyReducer

    typealias SubscriptionType = Subscription<State>
    var subscriptions: [SubscriptionType] = []
    var rendererSubscriptions = NSMapTable(keyOptions: .WeakMemory, valueOptions: .WeakMemory)


    init(initialState: State, reducer: AnyReducer) {
        self.state = initialState
        self.reducer = reducer
    }

    func subscribe<Subscriber : SubscriberType, SelectedState where Subscriber.StoreSubscriberStateType == SelectedState>(subscriber: Subscriber, _ transform: ((State) -> SelectedState)? = nil) {
        guard isNewSubscriber(subscriber) else {
            return
        }

        subscriptions.append(Subscription(subscriber: subscriber, transform: transform))
        subscriber._newState(transform?(state) ?? state)
    }

    func unsubscribe<Subscriber : AnyStoreSubscriber>(subscriber: Subscriber) {
        if let index = subscriptions.indexOf({ return $0.subscriber === subscriber }) {
            subscriptions.removeAtIndex(index)
        }
    }

    func route<T>(action: RouteAction<T>) {
        state.route = reduce(action, route: state.route)
        dispatch(action)
    }

    func setRoute<T>(action: RouteAction<T>) {
        state.route = reduce(action, route: state.route)
        print("Route: \(state.route.joinWithSeparator("/"))")
    }

    func dispatch(action: Action) {
        state = reducer._handleAction(action, state: state) as! State
        print("Route: \(state.route.joinWithSeparator("/"))")
        subscriptions.forEach { $0.subscriber?._newState($0.transform?(state) ?? state) }
    }

    func isNewSubscriber(subscriber: AnyStoreSubscriber) -> Bool {
        guard !subscriptions.contains({ $0.subscriber === subscriber }) else {
            return false
        }

        return true
    }
}

struct Subscription<State: StateType> {
    weak var subscriber: AnyStoreSubscriber?
    let transform: (State -> Any)?
}

public protocol AnyStoreSubscriber: class {
    func _newState(state: Any)
}

extension SubscriberType {
    func _newState(state: Any) {
        if let typedState = state as? StoreSubscriberStateType {
            newState(typedState)
        } else {
            preconditionFailure("newState does not accept right type")
        }
    }
}

protocol AnyReducer {
    func _handleAction(action: Action, state: StateType) -> StateType
}

protocol Reducer: AnyReducer {
    associatedtype ReducerStateType
    func handleAction(action: Action, state: ReducerStateType) -> ReducerStateType
}

extension Reducer {
    func _handleAction(action: Action, state: StateType) -> StateType {
        return withSpecificTypes(action, state: state, function: handleAction)
    }
}

func withSpecificTypes<SpecificStateType, Action>(action: Action, state genericStateType: StateType, @noescape function: (action: Action, state: SpecificStateType) -> SpecificStateType) -> StateType {
    guard let specificStateType = genericStateType as? SpecificStateType else {
        return genericStateType
    }

    return function(action: action, state: specificStateType) as! StateType
}

protocol Renderer: SubscriberType {
    associatedtype ViewModel
    func render(viewModel: ViewModel)
}

extension Renderer {
    func newState(state: Any) {
        if let viewModel = state as? ViewModel {
            render(viewModel)
        } else {
            preconditionFailure("render does not accept right type")
        }
    }
}

public protocol AnyRendererStoreSubscriber: class {
    func _newState(state: Any)
}

