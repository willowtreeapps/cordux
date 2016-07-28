//
//  ViewControllerLifecycle.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/22/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

@objc public protocol ViewControllerLifecycleDelegate {
    optional func viewDidLoad(viewController viewController: UIViewController)
    optional func didMoveToParentViewController(parentViewController: UIViewController?, viewController: UIViewController)
}

extension UIViewController {
    public class func swizzleLifecycleDelegatingViewControllerMethods() {
        struct Static {
            static var token: dispatch_once_t = 0
        }

        dispatch_once(&Static.token) {
            cordux_swizzleMethod(#selector(viewDidLoad), swizzled: #selector(cordux_viewDidLoad))
            cordux_swizzleMethod(#selector(didMoveToParentViewController(_:)), swizzled: #selector(cordux_didMoveToParentViewController(_:)))
        }
    }

    func cordux_viewDidLoad() {
        self.cordux_viewDidLoad()
        self.corduxContext?.lifecycleDelegate?.viewDidLoad?(viewController: self)
    }

    func cordux_didMoveToParentViewController(parentViewController: UIViewController?) {
        self.cordux_didMoveToParentViewController(parentViewController)
        self.corduxContext?.lifecycleDelegate?.didMoveToParentViewController?(parentViewController, viewController: self)
    }

    class func cordux_swizzleMethod(original: Selector, swizzled: Selector) {
        let originalMethod = class_getInstanceMethod(self, original)
        let swizzledMethod = class_getInstanceMethod(self, swizzled)

        let didAddMethod = class_addMethod(self, original, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))

        if didAddMethod {
            class_replaceMethod(self, swizzled, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
}
