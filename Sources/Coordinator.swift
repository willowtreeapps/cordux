//
//  Coordinator.swift
//  Cordux
//
//  Created by Ian Terrell on 6/30/17.
//  Copyright © 2017 WillowTree. All rights reserved.
//

import Foundation

@objc public protocol Coordinator {
    @objc optional func viewDidLoad()
    @objc optional func viewWillAppear(_ animated: Bool)
    @objc optional func viewDidAppear(_ animated: Bool)
    @objc optional func viewWillDisappear(_ animated: Bool)
    @objc optional func viewDidDisappear(_ animated: Bool)
    @objc optional func didMove(toParentViewController: UIViewController?)
    @objc optional func prepare(for segue: UIStoryboardSegue, sender: Any?)
}

public protocol AnyCoordinated {
    var _coordinator: Coordinator { get }
}

public protocol Coordinated: class, AnyCoordinated {
    associatedtype CustomCoordinator: Coordinator
    var coordinator: CustomCoordinator! { get set }
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
        UIViewController.cordux_swizzleMethod(#selector(UIViewController.didMove(toParentViewController:)),
                                              swizzled: #selector(UIViewController.cordux_didMoveToParentViewController(_:)))
        UIViewController.cordux_swizzleMethod(#selector(UIViewController.prepare(for:sender:)),
                                              swizzled: #selector(UIViewController.cordux_prepare(for:sender:)))
    }()

    public class func swizzleLifecycleDelegatingViewControllerMethods() {
        _ = swizzle
    }

    func cordux_viewDidLoad() {
        self.cordux_viewDidLoad()
        if let coordinated = self as? AnyCoordinated {
            coordinated._coordinator.viewDidLoad?()
        }
    }

    func cordux_viewWillAppear(_ animated: Bool) {
        self.cordux_viewWillAppear(animated)
        if let coordinated = self as? AnyCoordinated {
            coordinated._coordinator.viewWillAppear?(animated)
        }
    }

    func cordux_viewDidAppear(_ animated: Bool) {
        self.cordux_viewDidAppear(animated)
        if let coordinated = self as? AnyCoordinated {
            coordinated._coordinator.viewDidAppear?(animated)
        }
    }

    func cordux_viewWillDisappear(_ animated: Bool) {
        self.cordux_viewWillDisappear(animated)
        if let coordinated = self as? AnyCoordinated {
            coordinated._coordinator.viewWillDisappear?(animated)
        }
    }

    func cordux_viewDidDisappear(_ animated: Bool) {
        self.cordux_viewDidDisappear(animated)
        if let coordinated = self as? AnyCoordinated {
            coordinated._coordinator.viewDidDisappear?(animated)
        }
    }

    func cordux_didMoveToParentViewController(_ parentViewController: UIViewController?) {
        self.cordux_didMoveToParentViewController(parentViewController)
        if let coordinated = self as? AnyCoordinated {
            coordinated._coordinator.didMove?(toParentViewController: parentViewController)
        }
    }

    func cordux_prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.cordux_prepare(for: segue, sender: sender)
        if let coordinated = self as? AnyCoordinated {
            coordinated._coordinator.prepare?(for: segue, sender: sender)
        }
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
