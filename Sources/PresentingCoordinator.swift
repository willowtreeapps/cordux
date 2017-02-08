//
//  PresentingCoordinator.swift
//  Cordux
//
//  Created by Ian Terrell on 11/2/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

public protocol AnyPresentingCoordinator {
    var hasStoredPresentable: Bool { get }
    func presentStoredPresentable(completionHandler: @escaping () -> Void)
}

public protocol PresentingCoordinator: Coordinator, AnyPresentingCoordinator {
    var rootCoordinator: AnyCoordinator { get }
    var presented: Scene? { get set }

    var presentables: [GeneratingScene] { get }
    func parsePresentableRoute(_ route: Route) -> (rootRoute: Route, presentable: (route: Route, scene: GeneratingScene)?)

    func present(scene: GeneratingScene, route: Route, completionHandler: @escaping () -> Void)
    func dismiss(completionHandler: @escaping () -> Void)
}

public extension PresentingCoordinator  {
    public var rootViewController: UIViewController {
        return rootCoordinator.rootViewController
    }

    public var route: Route {
        var route: Route = []
        #if swift(>=3)
            route.append(contentsOf: rootCoordinator.route)
        #else
            route.appendContentsOf(rootCoordinator.route)
        #endif
        if let presented = presented, isPresentedViewControllerUpToDate {
            #if swift(>=3)
                route.append(contentsOf: presented.route())
            #else
                route.appendContentsOf(presented.route())
            #endif
        }
        return route
    }

    public func prepareForRoute(_ newValue: Route?, completionHandler: @escaping () -> Void) {
        pruneOutOfDatePresented()

        guard let route = newValue else {
            dismiss(completionHandler: completionHandler)
            return
        }

        withGroup(completionHandler) { group in
            let (rootRoute, presentable) = parsePresentableRoute(route)

            group.enter()
            rootCoordinator.prepareForRoute(rootRoute) {
                group.leave()
            }

            if let presented = presented {
                group.enter()
                if let presentedRoute = presentable?.route {
                    presented.coordinator.prepareForRoute(presentedRoute) {
                        group.leave()
                    }
                } else {
                    dismiss() {
                        group.leave()
                    }
                }

            }
        }
    }

    public func setRoute(_ newValue: Route?, completionHandler: @escaping () -> Void) {
        guard let newValue = newValue else {
            dismiss(completionHandler: completionHandler)
            return
        }

        guard newValue != route else {
            completionHandler()
            return
        }

        withGroup(completionHandler) { group in
            let (rootRoute, presentable) = parsePresentableRoute(newValue)

            group.enter()
            rootCoordinator.setRoute(rootRoute) {
                group.leave()
            }

            group.enter()
            if let presentable = presentable {
                present(scene: presentable.scene, route: presentable.route) {
                    group.leave()
                }
            } else {
                dismiss() {
                    group.leave()
                }
            }
        }
    }

    func start(route: Route?) {
        guard let route = route else {
            rootCoordinator.start(route: nil)
            return
        }

        let (rootRoute, presentable) = parsePresentableRoute(route)
        rootCoordinator.start(route: rootRoute)

        if let presentable = presentable {
            rootCoordinator.rootViewController.corduxToPresent = ToPresentBox(route: presentable.route, scene: presentable.scene)
        }
    }

    /// Checks whether the presented coordinator's view controller is still presented (or nil if none).
    ///
    /// A dead presented coordinator can occur if the presented view controller has already been dismissed outside of
    /// normal routing, e.g. from a button press on a UIAlertController.
    var isPresentedViewControllerUpToDate: Bool {
        return rootViewController.presentedViewController == presented?.coordinator.rootViewController
    }

    /// Prunes the current presented coordinator if not up to date
    func pruneOutOfDatePresented() {
        if !isPresentedViewControllerUpToDate {
            self.presented = nil
        }
    }

    public var hasStoredPresentable: Bool {
        return rootCoordinator.rootViewController.corduxToPresent != nil
    }

    public func presentStoredPresentable(completionHandler: @escaping () -> Void) {
        guard let toPresent = rootCoordinator.rootViewController.corduxToPresent else {
            completionHandler()
            return
        }

        rootCoordinator.rootViewController.corduxToPresent = nil
        present(scene: toPresent.scene, route: toPresent.route, completionHandler: completionHandler)
    }

    func parsePresentableRoute(_ route: Route) -> (rootRoute: Route, presentable: (route: Route, scene: GeneratingScene)?) {
        for presentable in presentables {
            let parts = route.components.split(separator: presentable.tag,
                                               maxSplits: 2,
                                               omittingEmptySubsequences: false)
            if parts.count == 2 {
                return (Route(parts[0]), (Route(parts[1]), presentable))
            }
        }
        return (route, nil)
    }

    /// Presents the presentable coordinator.
    /// If it is already presented, this method merely adjusts the route.
    /// If a different presentable is currently presented, this method dismisses it first.
    func present(scene: GeneratingScene, route: Route, completionHandler: @escaping () -> Void) {
        if let presented = presented {
            if scene.tag != presented.tag {
                dismiss() {
                    DispatchQueue.main.async {
                        self.present(scene: scene, route: route, completionHandler: completionHandler)
                    }
                }
            } else {
                presented.coordinator.setRoute(route, completionHandler: completionHandler)
            }
            return
        }

        let coordinator = scene.buildCoordinator()
        coordinator.start(route: route)
        rootViewController.present(coordinator.rootViewController, animated: true) {
            self.presented = Scene(tag: scene.tag, coordinator: coordinator)
            completionHandler()
        }
    }

    /// Dismisses the currently presented coordinator if present. Noop if there isn't one.
    func dismiss(completionHandler: @escaping () -> Void) {
        guard let presented = presented else {
            completionHandler()
            return
        }

        presented.coordinator.prepareForRoute(nil) {
            presented.coordinator.rootViewController.dismiss(animated: true) {
                self.presented = nil
                completionHandler()
            }
        }
    }

    /// Helper method for synchronizing activities with a DispatchGroup
    ///
    /// - Parameter perform: Callback to do work with the group, executed on the main queue
    func withGroup(_ completionHandler: @escaping () -> Void, perform: (DispatchGroup) -> Void) {
        let group = DispatchGroup()
        perform(group)
        let queue = DispatchQueue(label: "PresentingCoordinatorSync")
        queue.async {
            group.wait()
            DispatchQueue.main.async(execute: completionHandler)
        }
    }
}

// MARK: - Storage Helpers

fileprivate final class ToPresentBox: NSObject {
    let route: Route
    let scene: GeneratingScene

    init(route: Route, scene: GeneratingScene) {
        self.route = route
        self.scene = scene
    }
}

extension UIViewController {
    private struct CorduxPresentingCoordinatorKeys {
        static var ToPresent = "cordux_to_present"
    }

    fileprivate var corduxToPresent: ToPresentBox? {
        get {
            return objc_getAssociatedObject(self, &CorduxPresentingCoordinatorKeys.ToPresent) as? ToPresentBox
        }

        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &CorduxPresentingCoordinatorKeys.ToPresent,
                    newValue as ToPresentBox?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
}
