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

/// StateType describes the minimum requirements for state.
public protocol StateType {

    /// The current representation of the route for the app.
    ///
    /// This describes what the user is currently seeing and how they navigated there.
    var route: Route { get set }
}

public final class Store<State : StateType> {
    public private(set) var state: State
    public let reducer: AnyReducer
    public let middlewares: [AnyMiddleware]

    let routeQueue = DispatchQueue(label: "CorduxRouting", qos: .userInitiated)
    var routeAction: DispatchWorkItem?
    let routeLogger: RouteLogger?
    var lastRoute: Route?

    public weak var rootCoordinator: AnyCoordinator? {
        didSet {
            propagateRoute(state.route)
        }
    }

    typealias SubscriptionType = Subscription<State>
    var subscriptions: [SubscriptionType] = []

    public init(initialState: State, reducer: AnyReducer, middlewares: [AnyMiddleware] = [],
                routeLogger: RouteLogger? = ConsoleRouteLogger) {
        self.state = initialState
        self.reducer = reducer
        self.middlewares = middlewares
        self.routeLogger = routeLogger
    }

    public func subscribe<Subscriber: SubscriberType, SelectedState>(_ subscriber: Subscriber, _ transform: ((State) -> SelectedState)? = nil) where Subscriber.StoreSubscriberStateType == SelectedState {
        addSubscriber(subscriber, transform)
    }

    public func subscribe<Subscriber: Renderer, SelectedState>(_ subscriber: Subscriber, _ transform: ((State) -> SelectedState)? = nil) where Subscriber.ViewModel == SelectedState {
        addSubscriber(subscriber, transform)
    }

    private func addSubscriber(_ subscriber: AnyStoreSubscriber, _ transform: ((State) -> Any)? = nil) {
        guard isNewSubscriber(subscriber) else {
            return
        }

        let sub = Subscription(subscriber: subscriber, transform: transform)
        subscriptions.append(sub)
        sub.subscriber?._newState(sub.transform?(state) ?? state)
    }

    public func unsubscribe(_ subscriber: AnyStoreSubscriber) {
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
        state.route = state.route.reduce(action)
        routeLogger?(.store(state.route))
        dispatch(action)
    }

    public func setRoute<T>(_ action: RouteAction<T>) {
        state.route = state.route.reduce(action)
        lastRoute = state.route
        routeLogger?(.set(state.route))
    }

    public func dispatch(_ action: Action) {
        let originalRoute = state.route

        middlewares.forEach { $0._before(action: action, state: state) }
        state = reducer._handleAction(action, state: state) as! State

        #if swift(>=3)
            middlewares.reversed().forEach { $0._after(action: action, state: state) }
        #else
            middlewares.reverse().forEach { $0._after(action: action, state: state) }
        #endif
        
        if originalRoute != state.route {
            routeLogger?(.reducer(state.route))
        }

        subscriptions.forEach { $0.subscriber?._newState($0.transform?(state) ?? state) }
        propagateRoute(state.route)
    }

    /// Propagates the route through the app via the `rootCoordinator`.
    ///
    /// - Note: Does not re-propagate identical routes
    /// - Note: If a route is attempted to be propagated while another route is working, it is executed after the
    ///         original propagation completes. If multiple attempts occur, only the last one is queued and executed.
    /// - Note: All routing methods must call their completion handlers. This method times out after 3 seconds.
    ///
    /// - Parameter route: The route to propagate
    func propagateRoute(_ route: Route) {
        guard route != lastRoute else {
            return
        }
        let item = DispatchWorkItem {
            let group = DispatchGroup()
            group.enter()
            DispatchQueue.main.async {
                self.rootCoordinator?.prepareForRoute(route) {
                    DispatchQueue.main.async {
                        self.rootCoordinator?.setRoute(route) {
                            group.leave()
                        }
                    }
                }
            }
            let result = group.wait(timeout: .now() + kRouteTimeoutDuration)
            if case .timedOut = result {
                alertStuckRouter()
            }
        }
        routeQueue.async(execute: item)
        routeAction?.cancel()
        lastRoute = route
        routeAction = item
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

func alertStuckRouter() {
    print("[Cordux]: Router is stuck waiting for a completion handler to be called.")
    print("[Cordux]: Please make sure that you have called the completion handler in all routing methods (prepareForRoute, setRoute, updateRoute).")
    print("[Cordux]: Set a symbolic breakpoint for the `CorduxRouterStuck` symbol in order to halt the program when this happens.")
    CorduxRouterStuck()
}

func CorduxRouterStuck() {}
