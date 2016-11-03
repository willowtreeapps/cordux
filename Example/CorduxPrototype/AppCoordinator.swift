//
//  AppCoordinator.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/21/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit
import Cordux

final class AppCoordinator: SceneCoordinator {
    enum RouteSegment: String, RouteConvertible {
        case auth
        case catalog
    }

    let store: Store
    let container: UIViewController

    var currentScene: Scene?

    var rootViewController: UIViewController {
        return container
    }

    init(store: Store, container: UIViewController) {
        self.store = store
        self.container = container
    }

    func start(route: Route?) {
        store.rootCoordinator = self
    }

    public func coordinatorForTag(_ tag: String) -> AnyCoordinator? {
        guard let segment = RouteSegment(rawValue: tag) else {
            return nil
        }

        switch segment {
        case .auth:
            return AuthenticationCoordinator(store: store)
        case .catalog:
            return CatalogContainerCoordinator(store: store, rootCoordinator: CatalogCoordinator(store: store))
        }
    }

    public func presentCoordinator(_ coordinator: AnyCoordinator?, completionHandler: @escaping () -> Void) {
        let old = container.childViewControllers.first
        guard let new = coordinator?.rootViewController else {
            completionHandler()
            return
        }

        old?.willMove(toParentViewController: nil)
        container.addChildViewController(new)
        container.view.addSubview(new.view)

        var constraints: [NSLayoutConstraint] = []
        constraints.append(new.view.leftAnchor.constraint(equalTo: container.view.leftAnchor))
        constraints.append(new.view.rightAnchor.constraint(equalTo: container.view.rightAnchor))
        constraints.append(new.view.topAnchor.constraint(equalTo: container.view.topAnchor))
        constraints.append(new.view.bottomAnchor.constraint(equalTo: container.view.bottomAnchor))
        NSLayoutConstraint.activate(constraints)

        new.view.alpha = 0
        UIView.animate(withDuration: 0.3, animations: { 
            old?.view.alpha = 0
            new.view.alpha = 1
        }, completion: { _ in
            old?.view.removeFromSuperview()
            old?.removeFromParentViewController()
            new.didMove(toParentViewController: self.container)
            completionHandler()
        })
    }
}
