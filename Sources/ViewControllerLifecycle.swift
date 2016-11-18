//
//  ViewControllerLifecycle.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/22/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

@objc public protocol ViewControllerLifecycleDelegate {
    @objc optional func viewDidLoad(viewController: UIViewController)
    @objc optional func viewWillAppear(_ animated: Bool, viewController: UIViewController)
    @objc optional func viewDidAppear(_ animated: Bool, viewController: UIViewController)
    @objc optional func viewWillDisappear(_ animated: Bool, viewController: UIViewController)
    @objc optional func viewDidDisappear(_ animated: Bool, viewController: UIViewController)
    @objc optional func didMove(toParentViewController: UIViewController?, viewController: UIViewController)
}

final class LifecycleDelegateCollection {
    var delegates: [_wrapper] = []

    func append(_ delegate: ViewControllerLifecycleDelegate?) {
        guard let delegate = delegate else {
            return
        }
        delegates.append(_wrapper(delegate))
    }

    struct _wrapper {
        weak var delegate: ViewControllerLifecycleDelegate?
        init(_ delegate: ViewControllerLifecycleDelegate) {
            self.delegate = delegate
        }
    }
}

extension LifecycleDelegateCollection {
    func forEach(_ body: (ViewControllerLifecycleDelegate?) -> Void) {
        delegates.forEach { body($0.delegate) }
    }

    func viewDidLoad(viewController: UIViewController) {
        forEach { $0?.viewDidLoad?(viewController: viewController) }
    }

    func viewWillAppear(_ animated: Bool, viewController: UIViewController) {
        forEach { $0?.viewWillAppear?(animated, viewController: viewController) }
    }

    func viewDidAppear(_ animated: Bool, viewController: UIViewController) {
        forEach { $0?.viewDidAppear?(animated, viewController: viewController) }
    }

    func viewWillDisappear(_ animated: Bool, viewController: UIViewController) {
        forEach { $0?.viewWillDisappear?(animated, viewController: viewController) }
    }

    func viewDidDisappear(_ animated: Bool, viewController: UIViewController) {
        forEach { $0?.viewDidDisappear?(animated, viewController: viewController) }
    }

    func didMove(toParentViewController parent: UIViewController?, viewController: UIViewController) {
        forEach { $0?.didMove?(toParentViewController: parent, viewController: viewController) }
    }
}

extension UIViewController {
    static let swizzle: Void = {
        UIViewController.cordux_swizzleMethod(#selector(UIViewController.viewDidLoad),
                                              swizzled: #selector(UIViewController.cordux_viewDidLoad))

        UIViewController.cordux_swizzleMethod(#selector(UIViewController.viewWillAppear),
                                              swizzled: #selector(UIViewController.cordux_viewWillAppear))
        UIViewController.cordux_swizzleMethod(#selector(UIViewController.viewDidAppear),
                                              swizzled: #selector(UIViewController.cordux_viewDidAppear))
        UIViewController.cordux_swizzleMethod(#selector(UIViewController.viewWillDisappear),
                                              swizzled: #selector(UIViewController.cordux_viewWillDisappear))
        UIViewController.cordux_swizzleMethod(#selector(UIViewController.viewDidDisappear),
                                              swizzled: #selector(UIViewController.cordux_viewDidDisappear))

        #if swift(>=3)
            UIViewController.cordux_swizzleMethod(#selector(UIViewController.didMove(toParentViewController:)),
                                                  swizzled: #selector(UIViewController.cordux_didMoveToParentViewController(_:)))
        #else
            UIViewController.cordux_swizzleMethod(#selector(UIViewController.didMoveToParentViewController(_:)),
                                                  swizzled: #selector(UIViewController.cordux_didMoveToParentViewController(_:)))
        #endif
    }()

    public class func swizzleLifecycleDelegatingViewControllerMethods() {
        _ = swizzle
    }

    func cordux_viewDidLoad() {
        self.cordux_viewDidLoad()
        #if swift(>=3)
            self.corduxContext?.lifecycleDelegate.viewDidLoad(viewController: self)
        #else
            self.corduxContext?.lifecycleDelegate.viewDidLoad(self)
        #endif
    }

    func cordux_viewWillAppear(_ animated: Bool) {
        self.cordux_viewWillAppear(animated)
        self.corduxContext?.lifecycleDelegate.viewWillAppear(animated, viewController: self)
    }

    func cordux_viewDidAppear(_ animated: Bool) {
        self.cordux_viewDidAppear(animated)
        self.corduxContext?.lifecycleDelegate.viewDidAppear(animated, viewController: self)
    }

    func cordux_viewWillDisappear(_ animated: Bool) {
        self.cordux_viewWillDisappear(animated)
        self.corduxContext?.lifecycleDelegate.viewWillDisappear(animated, viewController: self)
    }

    func cordux_viewDidDisappear(_ animated: Bool) {
        self.cordux_viewDidDisappear(animated)
        self.corduxContext?.lifecycleDelegate.viewDidDisappear(animated, viewController: self)
    }

    func cordux_didMoveToParentViewController(_ parentViewController: UIViewController?) {
        self.cordux_didMoveToParentViewController(parentViewController)

        #if swift(>=3)
            self.corduxContext?.lifecycleDelegate.didMove(toParentViewController: parentViewController, viewController: self)
        #else
            self.corduxContext?.lifecycleDelegate.didMove(parentViewController, viewController: self)
        #endif
    }

    static func cordux_swizzleMethod(_ original: Selector, swizzled: Selector) {
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
