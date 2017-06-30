//
//  Command.swift
//  Cordux
//
//  Created by Ian Terrell on 6/30/17.
//  Copyright © 2017 WillowTree. All rights reserved.
//

import Foundation

/// Command is a marker type that describes commands that subscribers should execute.
public protocol Command {}

public struct CompositeCommand {
    let commands: [Command]

    init(_ commands: Command...) {
        self.commands = commands
    }
}

struct CommandSubscription {
    weak var subscriber: AnyCommandSubscriber?
}

public protocol AnyCommandSubscriber: class {
    func _execute(_ command: Command)
}

public protocol CommandSubscriberType: AnyCommandSubscriber {
    associatedtype SubscriberCommandType
    func execute(_ subscription: SubscriberCommandType)
}

extension CommandSubscriberType {
    public func _execute(_ command: Any) {
        if let typedCommand = command as? SubscriberCommandType {
            execute(typedCommand)
        }
    }
}
