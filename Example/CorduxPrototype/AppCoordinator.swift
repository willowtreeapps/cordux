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
    var scenePrefix: String?

    let store: Store
    let container: UIViewController

    var currentScene: AnyCoordinator?

    var rootViewController: UIViewController {
        return container
    }

    init(store: Store, container: UIViewController) {
        self.store = store
        self.container = container
    }

    func start(route: Route) {
        store.rootCoordinator = self
    }

    func changeScene(_ route: Route) {
        guard let segment = RouteSegment(rawValue: route.first ?? "") else {
            return
        }

        let old = currentScene?.rootViewController
        let coordinator: AnyCoordinator
        switch segment {
        case .auth:
            coordinator = AuthenticationCoordinator(store: store)
        case .catalog:
            coordinator = CatalogCoordinator(store: store)
        }

        coordinator.start(route: sceneRoute(route))
        currentScene = coordinator
        scenePrefix = segment.rawValue

        let container = self.container
        let new = coordinator.rootViewController

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
            new.didMove(toParentViewController: container)
        })
    }
}
