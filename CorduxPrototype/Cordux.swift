//
//  Cordux.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/21/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

protocol Coordinator {
    func start(route: Route)
    func route(route: Route)
    var rootViewController: UIViewController { get }
}

protocol CorduxState {
    var route: Route { get set }
}

typealias Route = [String]
typealias RouteSegment = [String]

protocol Action {}

enum RouteAction: Action {
    case goto(route: Route)
    case push(segment: RouteSegment)
    case pop(segment: RouteSegment)
}

protocol ReducerType {
    associatedtype State
    func handleAction(action: Action, state: State) -> State
}

protocol SubscriptionType {
    associatedtype State
    init(state: State)
}

protocol SubscriberType: AnyStoreSubscriber {
    associatedtype Subscription: SubscriptionType
    func newState(subscription: Subscription)
}

final class CorduxStore<
    State : CorduxState,
    Reducer : ReducerType
    where
    Reducer.State == State
> {
    var state: State
    var reducer: Reducer

    typealias SubscriptionType = Subscription<State>
    var subscriptions: [SubscriptionType] = []


    init(initialState: State, reducer: Reducer) {
        self.state = initialState
        self.reducer = reducer
    }

    func subscribe<Subscriber : SubscriberType, SubscriptionValue where Subscriber.Subscription.State == State, SubscriptionValue == Subscriber.Subscription>(subscriber: Subscriber, _ transform: ((State) -> SubscriptionValue)? = nil) {
        guard isNewSubscriber(subscriber) else {
            return
        }

        if let transform = transform {
            subscriptions.append(Subscription(subscriber: subscriber, transform: transform))
        } else {
            subscriptions.append(Subscription(subscriber: subscriber) { Subscriber.Subscription(state: $0) })
        }

        subscriber._newState(Subscriber.Subscription(state: state) ?? state)
    }

    func unsubscribe<Subscriber : SubscriberType where Subscriber.Subscription.State == State>(subscriber: Subscriber) {
        if let index = subscriptions.indexOf({ return $0.subscriber === subscriber }) {
            subscriptions.removeAtIndex(index)
        }
    }

    func dispatch(action: Action) {
        dispatch(action, notify: true)
    }

    func route(action: RouteAction) {
        dispatch(action, notify: true)
    }

    func setRoute(action: RouteAction) {
        dispatch(action, notify: false)
    }

    private func dispatch(action: Action, notify: Bool) {
        state = reduce(action, state: state)
        if notify {
            subscriptions.forEach { $0.subscriber?._newState($0.transform(state) ?? state) }
        }
    }

    func reduce(action: Action, state: State) -> State {
        var state = state
        state.route = reduce(action, route: state.route)
        return reducer.handleAction(action, state: state)
    }

    func reduce(action: Action, route: Route) -> Route {
        guard let action = action as? RouteAction else {
            return route
        }

        switch action {
        case .goto(let route):
            return route
        case .push(let segment):
            return route + segment
        case .pop(let segment):
            let n = route.count
            let m = segment.count
            guard n >= m else {
                return route
            }
            let tail = Array(route[n-m..<n])
            guard tail == segment else {
                return route
            }
            return Array(route.dropLast(m))
        }
    }

    func isNewSubscriber(subscriber: AnyStoreSubscriber) -> Bool {
        guard !subscriptions.contains({ $0.subscriber === subscriber }) else {
            return false
        }

        return true
    }
}

struct Subscription<State: CorduxState> {
    weak var subscriber: AnyStoreSubscriber?
    let transform: (State -> Any)
}

public protocol AnyStoreSubscriber: class {
    func _newState(state: Any)
}

extension SubscriberType {
    func _newState(state: Any) {
        if let typedState = state as? Subscription {
            newState(typedState)
        }
    }
}
