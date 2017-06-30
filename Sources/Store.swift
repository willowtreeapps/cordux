//
//  Store.swift
//  Cordux
//
//  Created by Ian Terrell on 7/28/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation

private let kRouteTimeoutDuration: TimeInterval = 3

/// Action is a marker type that describes types that can modify state.
public protocol Action {}

/// NavigationCommand is a marker type that describes actions that should result in app navigation.
public protocol NavigationCommand {}

/// StateType is a marker type that defines the state.
public protocol StateType {}

public final class Store<State : StateType> {
    public private(set) var state: State
    public let reducer: AnyReducer
    public let middlewares: [AnyMiddleware]

    typealias SubscriptionType = Subscription<State>
    var subscriptions: [SubscriptionType] = []

    var navigationSubscriptions: [NavigationSubscription] = []

    public init(initialState: State, reducer: AnyReducer, middlewares: [AnyMiddleware] = []) {
        self.state = initialState
        self.reducer = reducer
        self.middlewares = middlewares
    }

    // MARK: State Subscriptions

    public func subscribe<Subscriber: SubscriberType, SelectedState>(_ subscriber: Subscriber, _ transform: ((State) -> SelectedState)? = nil) where Subscriber.SubscriberStateType == SelectedState {
        addSubscriber(subscriber, transform)
    }

    public func subscribe<Subscriber: Renderer, SelectedState>(_ subscriber: Subscriber, _ transform: ((State) -> SelectedState)? = nil) where Subscriber.ViewModel == SelectedState {
        addSubscriber(subscriber, transform)
    }

    private func addSubscriber(_ subscriber: AnyStoreSubscriber, _ transform: ((State) -> Any)? = nil) {
        guard !subscriptions.contains(where: { $0.subscriber === subscriber }) else {
            return
        }

        let sub = Subscription(subscriber: subscriber, transform: transform)
        subscriptions.append(sub)
        sub.subscriber?._newState(sub.transform?(state) ?? state)
    }

    public func unsubscribe(_ subscriber: AnyStoreSubscriber) {
        if let index = subscriptions.index(where: { return $0.subscriber === subscriber }) {
            subscriptions.remove(at: index)
        }
    }

    // MARK: Navigation Subscriptions

    public func subscribe<Subscriber: NavigationSubscriberType>(_ subscriber: Subscriber) {
        guard !navigationSubscriptions.contains(where: { $0.subscriber === subscriber }) else {
            return
        }

        let sub = NavigationSubscription(subscriber: subscriber)
        navigationSubscriptions.append(sub)
    }

    // MARK: Dispatch

    public func dispatch(_ action: Action) {
        let state = self.state
        middlewares.forEach { $0._before(action: action, state: state) }
        let (newState, navigationCommand) = reducer._handleAction(action, state: state)
        let newTypedState = newState as! State
        self.state = newTypedState
        middlewares.reversed().forEach { $0._after(action: action, state: newState, navigationCommand: navigationCommand) }
        subscriptions = subscriptions.filter { $0.subscriber != nil }
        subscriptions.forEach { $0.subscriber?._newState($0.transform?(newTypedState) ?? newTypedState) }
        if let navigationCommand = navigationCommand {
            navigationSubscriptions.forEach { $0.subscriber?._navigate(navigationCommand) }
        }
    }
}
