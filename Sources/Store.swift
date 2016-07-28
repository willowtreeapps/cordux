//
//  Store.swift
//  Cordux
//
//  Created by Ian Terrell on 7/28/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation

public protocol Action {}

public protocol StateType {
    var route: Route { get set }
}

public protocol StoreType {
    func route<T>(action: RouteAction<T>)
    func setRoute<T>(action: RouteAction<T>)
    func dispatch(action: Action)
}

public final class Store<State : StateType>: StoreType {
    var state: State
    var reducer: AnyReducer

    typealias SubscriptionType = Subscription<State>
    var subscriptions: [SubscriptionType] = []
    var rendererSubscriptions = NSMapTable(keyOptions: .WeakMemory, valueOptions: .WeakMemory)

    public init(initialState: State, reducer: AnyReducer) {
        self.state = initialState
        self.reducer = reducer
    }

    public func subscribe<Subscriber : SubscriberType, SelectedState where Subscriber.StoreSubscriberStateType == SelectedState>(subscriber: Subscriber, _ transform: ((State) -> SelectedState)? = nil) {
        guard isNewSubscriber(subscriber) else {
            return
        }

        subscriptions.append(Subscription(subscriber: subscriber, transform: transform))
        subscriber._newState(transform?(state) ?? state)
    }

    public func unsubscribe<Subscriber : AnyStoreSubscriber>(subscriber: Subscriber) {
        if let index = subscriptions.indexOf({ return $0.subscriber === subscriber }) {
            subscriptions.removeAtIndex(index)
        }
    }

    public func route<T>(action: RouteAction<T>) {
        state.route = reduce(action, route: state.route)
        dispatch(action)
    }

    public func setRoute<T>(action: RouteAction<T>) {
        state.route = reduce(action, route: state.route)
    }

    public func dispatch(action: Action) {
        state = reducer._handleAction(action, state: state) as! State
        subscriptions.forEach { $0.subscriber?._newState($0.transform?(state) ?? state) }
    }

    func isNewSubscriber(subscriber: AnyStoreSubscriber) -> Bool {
        guard !subscriptions.contains({ $0.subscriber === subscriber }) else {
            return false
        }
        
        return true
    }
}
