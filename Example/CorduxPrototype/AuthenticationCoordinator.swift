//
//  AuthenticationCoordinator.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/21/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit
import Cordux

final class AuthenticationCoordinator: NavigationControllerCoordinator {
    enum RouteSegment: String, RouteConvertible {
        case signIn
        case fp
    }

    var store: Store

    let storyboard = UIStoryboard(name: "Authentication", bundle: nil)
    let navigationController: UINavigationController

    let signInViewController: SignInViewController

    init(store: Store) {
        self.store = store

        signInViewController = storyboard.instantiateInitialViewController() as! SignInViewController
        navigationController = UINavigationController(rootViewController: signInViewController)
    }

    func start(route: Route?) {
        signInViewController.inject(handler: self)
        signInViewController.corduxContext = Context(routeSegment: RouteSegment.signIn, lifecycleDelegate: self)

        let segments = parse(route: route)
        guard !segments.isEmpty else {
            store.setRoute(.push(RouteSegment.signIn))
            return
        }

        if segments.last == .fp {
            navigationController.pushViewController(createForgotPasswordViewController(), animated: false)
        }
    }

    public func updateRoute(_ route: Route, completionHandler: @escaping () -> Void) {
        guard parse(route: route).last == .fp else {
            completionHandler()
            return
        }

        navigationController.pushViewController(createForgotPasswordViewController(), animated: true, completion: completionHandler)
    }
    func updateRoute(_ route: Route) {
        if parse(route: route).last == .fp {
            navigationController.pushViewController(createForgotPasswordViewController(), animated: true)
        }
    }

    func parse(route: Route?) -> [RouteSegment] {
        return route?.flatMap({ RouteSegment.init(rawValue: $0) }) ?? []
    }

    func createForgotPasswordViewController() -> ForgotPasswordViewController {
        let forgotPasswordViewController = storyboard.instantiateViewController(withIdentifier: "ForgotPassword") as! ForgotPasswordViewController
        forgotPasswordViewController.inject(self)
        forgotPasswordViewController.corduxContext = Context(routeSegment: RouteSegment.fp, lifecycleDelegate: self)
        return forgotPasswordViewController
    }
}

extension AuthenticationCoordinator: ViewControllerLifecycleDelegate {
    @objc func viewDidLoad(viewController: UIViewController) {
        if viewController === signInViewController {
            store.subscribe(signInViewController, SignInViewModel.init)
        }
    }

    @objc func didMove(toParentViewController parentViewController: UIViewController?, viewController: UIViewController) {
        guard parentViewController == nil else {
            return
        }

        popRoute(viewController)
    }
}

extension AuthenticationCoordinator: SignInHandler {
    func signIn() {
        store.dispatch(AuthenticationAction.signIn)
    }

    func forgotPassword() {
        store.route(.push(RouteSegment.fp))
    }
}

extension SignInViewController: Renderer {}

extension SignInViewModel {
    init?(_ state: AppState) {
        return nil
        //name = state.name
    }
}

extension AuthenticationCoordinator: ForgotPasswordHandler {
    func emailPassword() {

    }
}

