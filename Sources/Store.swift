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

    /// Isolation queue to protect routingCount
    private let routeStatusQueue = DispatchQueue(label: "CorduxRoutingStatus")
    /// The number of routing actions currently in progress
    private var routingCount = 0
    /// Serial queue to order routing actions
    private let routeQueue = DispatchQueue(label: "CorduxRouting", qos: .userInitiated)
    /// Logger to log routing events
    private let routeLogger: RouteLogger?
    /// The last route that has been propagated
    private var lastRoute: Route?

    /// The root coordinator for the app; used for routing.
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
        let state = self.state
        middlewares.forEach { $0._before(action: action, state: state) }
        let newState = reducer._handleAction(action, state: state) as! State
        self.state = newState

        #if swift(>=3)
            middlewares.reversed().forEach { $0._after(action: action, state: newState) }
        #else
            middlewares.reverse().forEach { $0._after(action: action, state: newState) }
        #endif

        if state.route != newState.route {
            routeLogger?(.reducer(newState.route))
        }

        propagateRoute(newState.route)

        subscriptions = subscriptions.filter { $0.subscriber != nil }
        subscriptions.forEach { $0.subscriber?._newState($0.transform?(newState) ?? newState) }
    }

    /// Propagates the route through the app via the `rootCoordinator`.
    ///
    /// This method will execute the routing action synchronously if no other routing actions are already in progress.
    /// If a routing action is already occurring, the route will be performed asynchronously. All actions occur on
    /// the main thread.
    ///
    /// - Note: Does not re-propagate identical routes
    /// - Note: If a route is attempted to be propagated while another route is working, it is executed after the
    ///         original propagation completes. Multiple routes are propagated asynchronously in order.
    /// - Note: All routing methods must call their completion handlers on the main thread. 
    ///         This method times out after 3 seconds.
    ///
    /// - Parameter route: The route to propagate
    private func propagateRoute(_ route: Route) {
        guard route != lastRoute, let rootCoordinator = rootCoordinator else {
            return
        }
        lastRoute = route

        func waitForRoutingCompletion(_ group: DispatchGroup) {
            let result = group.wait(timeout: .now() + kRouteTimeoutDuration)
            if case .timedOut = result {
                alertStuckRouter()
            }
            self.decrementRoutingCount()
        }

        func _setRoute(_ group: DispatchGroup) {
            rootCoordinator.setRoute(route) {
                group.leave()
            }
        }

        func setRoute(_ group: DispatchGroup) {
            guard rootCoordinator.needsToPrepareForRoute(route) else {
                _setRoute(group)
                return
            }
            rootCoordinator.prepareForRoute(route) {
                _setRoute(group)
            }
        }

        let shouldRouteAsynchronously = isRouting
        self.incrementRoutingCount()

        if shouldRouteAsynchronously {
            routeQueue.async {
                let group = DispatchGroup()
                group.enter()
                DispatchQueue.main.async {
                    setRoute(group)
                }
                waitForRoutingCompletion(group)
            }
        } else {
            let group = DispatchGroup()
            group.enter()
            routeQueue.async {
                waitForRoutingCompletion(group)
            }
            setRoute(group)
        }
    }

    private var isRouting: Bool { return routeStatusQueue.sync { self.routingCount > 0 } }
    private func incrementRoutingCount() { routeStatusQueue.async { self.routingCount += 1 } }
    private func decrementRoutingCount() { routeStatusQueue.async { self.routingCount -= 1 } }

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
