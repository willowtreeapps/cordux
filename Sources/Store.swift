//
//  Store.swift
//  Cordux
//
//  Created by Ian Terrell on 7/28/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation

/// Action is a marker type that describes types that can modify state.
public protocol Action {}

/// StateType describes the minimum requirements for state.
public protocol StateType {

    /// The current representation of the route for the app.
    ///
    /// This describes what the user is currently seeing and how they navigated there.
    var route: Route { get set }
}

public final class Store<State : StateType> {
    public private(set) var state: State
    public private(set) var reducer: AnyReducer
    public weak var rootCoordinator: AnyCoordinator? {
        didSet {
            rootCoordinator?.route = state.route
        }
    }

    typealias SubscriptionType = Subscription<State>
    var subscriptions: [SubscriptionType] = []

    public init(initialState: State, reducer: AnyReducer) {
        self.state = initialState
        self.reducer = reducer
    }

    #if swift(>=3)
        public func subscribe<Subscriber : SubscriberType, SelectedState>(_ subscriber: Subscriber, _ transform: ((State) -> SelectedState)? = nil) where Subscriber.StoreSubscriberStateType == SelectedState {
            guard isNewSubscriber(subscriber) else {
                return
            }

            let sub = Subscription(subscriber: subscriber, transform: transform)
            subscriptions.append(sub)
            sub.subscriber?._newState(sub.transform?(state) ?? state)
        }
    #else
        public func subscribe<Subscriber : SubscriberType, SelectedState where Subscriber.StoreSubscriberStateType == SelectedState>(_ subscriber: Subscriber, _ transform: ((State) -> SelectedState)? = nil) {
            guard isNewSubscriber(subscriber) else {
                return
            }
            
            let sub = Subscription(subscriber: subscriber, transform: transform)
            subscriptions.append(sub)
            sub.subscriber?._newState(sub.transform?(state) ?? state)
        }
    #endif

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
        rootCoordinator?.route = state.route
    }

    func isNewSubscriber(_ subscriber: AnyStoreSubscriber) -> Bool {
        #if swift(>=3)
            guard !subscriptions.contains(where: { $0.subscriber === subscriber }) else {
                return false
            }
        #else
            guard !subscriptions.contains({ $0.subscriber === subscriber }) else {
                return false
            }
        #endif
        return true
    }
}
