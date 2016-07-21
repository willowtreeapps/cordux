//
//  AuthenticationCoordinator.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/21/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

final class AuthenticationCoordinator: NSObject, Coordinator {
    let store: Store

    var currentRoute: Route = []

    let storyboard = UIStoryboard(name: "Authentication", bundle: nil)
    let navigationController: UINavigationController
    var rootViewController: UIViewController { return navigationController }

    let signInViewController: SignInViewController

    init(store: Store) {
        self.store = store

        signInViewController = storyboard.instantiateInitialViewController() as! SignInViewController
        navigationController = UINavigationController(rootViewController: signInViewController)
    }

    func start(route: Route) {
        self.currentRoute = route
        navigationController.delegate = self

        signInViewController.inject(handler: self, delegate: self)
        store.setRoute(.push(segment: ["signIn"]))
    }

    func route(route: Route) {
        if route.last == "fp" {
            let forgotPasswordViewController = storyboard.instantiateViewControllerWithIdentifier("ForgotPassword") as! ForgotPasswordViewController
            forgotPasswordViewController.inject(self)
            navigationController.pushViewController(forgotPasswordViewController, animated: true)
        }
        currentRoute = route
    }
}

//extension AuthenticationCoordinator {x
//    enum RouteSegment: String {
//        case signIn
//        case fp
//    }
//}

extension AuthenticationCoordinator: ViewControllerLifecycleDelegate {
    func viewDidLoad(viewController: UIViewController) {
        if viewController === signInViewController {
            store.subscribe(signInViewController, SignInViewModel.init)
        }
    }
}

extension AuthenticationCoordinator: SignInDelegate {
    
}

extension AuthenticationCoordinator: SignInHandler {
    func signIn() {
        store.dispatch(AuthenticationAction.signIn)
    }

    func forgotPassword() {
        store.route(.push(segment: ["fp"]))
    }
}

extension SignInViewController: Renderer {}

extension SignInViewModel {
    init(_ state: AppState) {
        name = state.name
    }
}

extension AuthenticationCoordinator: ForgotPasswordHandler {
    func emailPassword() {

    }
}

extension AuthenticationCoordinator: UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        if navigationController.viewControllers.count != currentRoute.count {
            store.setRoute(.pop(segment: ["fp"]))
        }
    }
}
