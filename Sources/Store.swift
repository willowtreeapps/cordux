//
//  Store.swift
//  Cordux
//
//  Created by Ian Terrell on 7/28/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation

public final class Store<State : StateType> {
    public private(set) var state: State
    public let reducer: AnyReducer
    public let middlewares: [AnyMiddleware]

    var stateSubscriptions: [StateSubscription<State>] = []
    var commandSubscriptions: [CommandSubscription] = []

    public init(initialState: State, reducer: AnyReducer, middlewares: [AnyMiddleware] = []) {
        self.state = initialState
        self.reducer = reducer
        self.middlewares = middlewares
    }

    // MARK: State Subscriptions

    public func subscribe<Subscriber: StateSubscriberType, SelectedState>(_ subscriber: Subscriber, _ transform: ((State) -> SelectedState)? = nil) where Subscriber.SubscriberStateType == SelectedState {
        addSubscriber(subscriber, transform)
    }

    public func subscribe<Subscriber: Renderer, SelectedState>(_ subscriber: Subscriber, _ transform: ((State) -> SelectedState)? = nil) where Subscriber.ViewModel == SelectedState {
        addSubscriber(subscriber, transform)
    }

    private func addSubscriber(_ subscriber: AnyStateSubscriber, _ transform: ((State) -> Any)? = nil) {
        guard !stateSubscriptions.contains(where: { $0.subscriber === subscriber }) else {
            return
        }

        let sub = StateSubscription(subscriber: subscriber, transform: transform)
        stateSubscriptions.append(sub)
        sub.subscriber?._newState(sub.transform?(state) ?? state)
    }

    public func unsubscribe(_ subscriber: AnyStateSubscriber) {
        if let index = stateSubscriptions.index(where: { return $0.subscriber === subscriber }) {
            stateSubscriptions.remove(at: index)
        }
    }

    // MARK: Command Subscriptions

    public func subscribe<Subscriber: CommandSubscriberType>(_ subscriber: Subscriber) {
        guard !commandSubscriptions.contains(where: { $0.subscriber === subscriber }) else {
            return
        }

        let sub = CommandSubscription(subscriber: subscriber)
        commandSubscriptions.append(sub)
    }

    // MARK: Dispatch

    public func dispatch(_ action: Action) {
        let state = self.state
        middlewares.forEach { $0._before(action: action, state: state) }
        let command = reducer._handleAction(action, state: state)
        let commands = (command as? CompositeCommand)?.commands ?? [command]

        // if a command updates state, find it
        var newState: State?
        commands.forEach { command in
            if let state = command as? State {
                newState = state
            }
        }

        // if state is updating, notify middleware and state subscribers
        if let newState = newState {
            self.state = newState
            middlewares.reversed().forEach { $0._after(action: action, state: newState) }
            stateSubscriptions = stateSubscriptions.filter { $0.subscriber != nil }
            stateSubscriptions.forEach { $0.subscriber?._newState($0.transform?(newState) ?? newState) }
        }

        // notify middleware and command subscribers
        commandSubscriptions = commandSubscriptions.filter { $0.subscriber != nil }
        commands.forEach { command in
            middlewares.reversed().forEach { $0._after(action: action, command: command) }
            commandSubscriptions.forEach { $0.subscriber?._execute(command) }
        }
    }
}
