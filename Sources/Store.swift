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

public final class Store<State : StateType> {
    var state: State
    var reducer: AnyReducer

    typealias SubscriptionType = Subscription<State>
    var subscriptions: [SubscriptionType] = []

    public init(initialState: State, reducer: AnyReducer) {
        self.state = initialState
        self.reducer = reducer
    }

    public func subscribe<Subscriber : SubscriberType, SelectedState where Subscriber.StoreSubscriberStateType == SelectedState>(_ subscriber: Subscriber, _ transform: ((State) -> SelectedState)? = nil) {
        guard isNewSubscriber(subscriber) else {
            return
        }

        subscriptions.append(Subscription(subscriber: subscriber, transform: transform))
        subscriber._newState(transform?(state) as Any ?? state)
    }

    public func unsubscribe<Subscriber : AnyStoreSubscriber>(_ subscriber: Subscriber) {
        #if swift(>=3)
            if let index = subscriptions.index(where: { return $0.subscriber === subscriber }) {
            subscriptions.remove(at: index)
            }
        #else
            if let index = subscriptions.indexOf({ return $0.subscriber === subscriber }) {
                subscriptions.removeAtIndex(index)
            }
        #endif
    }

    public func route<T>(_ action: RouteAction<T>) {
        state.route = reduce(action, route: state.route)
        dispatch(action)
    }

    public func setRoute<T>(_ action: RouteAction<T>) {
        state.route = reduce(action, route: state.route)
    }

    public func dispatch(_ action: Action) {
        state = reducer._handleAction(action, state: state) as! State
        subscriptions.forEach { $0.subscriber?._newState($0.transform?(state) ?? state) }
    }

    func isNewSubscriber(_ subscriber: AnyStoreSubscriber) -> Bool {
        guard !subscriptions.contains({ $0.subscriber === subscriber }) else {
            return false
        }
        
        return true
    }
}