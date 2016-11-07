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
    public func prepareForRoute(_: Route?, completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    public func setRoute(_: Route?, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
