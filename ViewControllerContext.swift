//
//  ViewControllerContext.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/22/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

protocol CorduxViewController: class {
    var corduxContext: Context? { get }
}

class Context: NSObject {
    let routeSegment: RouteSegment
    weak var lifecycleDelegate: ViewControllerLifecycleDelegate?

    init(routeSegment: RouteSegment, lifecycleDelegate: ViewControllerLifecycleDelegate?) {
        self.routeSegment = routeSegment
        self.lifecycleDelegate = lifecycleDelegate
    }
}

extension UIViewController {
    private struct CorduxViewControllerKeys {
        static var corduxContext = "cordux_corduxContext"
    }
    
    var corduxContext: Context? {
        get {
            return objc_getAssociatedObject(self, &CorduxViewControllerKeys.corduxContext) as? Context
        }

        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &CorduxViewControllerKeys.corduxContext,
                    newValue as Context?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
}