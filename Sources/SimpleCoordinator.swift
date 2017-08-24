//
//  SimpleCoordinator.swift
//  Cordux
//
//  Created by Ian Terrell on 11/7/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

public protocol SimpleCoordinator: Coordinator {

}

public extension SimpleCoordinator {
    public func needsToPrepareForRoute(_ route: Route?) -> Bool {
        return false
    }

    public func prepareForRoute(_ route: Route?, completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    public func setRoute(_ route: Route?, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
