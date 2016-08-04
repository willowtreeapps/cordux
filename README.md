# Cordux

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

<img alt="You got your Redux in my app coordinator" src="https://github.com/willowtreeapps/cordux/blob/develop/yougot.jpg?raw=true" width="400">

## Installation

CocoaPods:

```ruby
pod 'Cordux'
```

Carthage:

```ruby
github "willowtreeapps/cordux" >= 0.1
```

## Cordux combines app coordinators with Redux

Soroush Khanlou's [blog post](http://khanlou.com/2015/10/coordinators-redux/)
gives a great rationale for and explanation of app coordinators. This project
combines those ideas with a Redux-like architecture, which you can read about
on the [ReSwift](https://github.com/ReSwift/ReSwift) repository.

Combining the two natively leads to a lot of advantages:

* View controllers become even simpler
* Action creator methods clearly live in app coordinators
* Navigating via route becomes simpler
  * Normal navigation and routing share code paths
  * Deep linking becomes almost trivial

In this model, view controllers have exactly two responsibilities:

1. Render latest state
2. Convert UI interaction into user intents

For example...

```swift
struct ProductViewModel {
    let name: String
    let sku: String
    let price: Double
}

protocol ProductViewControllerHandler: class {
    func purchase(sku: String)
}

final class ProductViewController: UIViewController {
    @IBOutlet var nameLabel: UILabel!

    weak var handler: ProductViewControllerHandler!
    var viewModel: ProductViewModel!

    func inject(handler handler: ProductViewControllerHandler) {
        self.handler = handler
    }

    func render(viewModel: ProductViewModel) {
        self.viewModel = viewModel
        nameLabel.text = viewModel.name
    }

    @IBAction func purchaseButtonTapped(sender: AnyObject) {
        handler.purchase(viewModel.sku)
    }
}
```

## Usage

To use Cordux, you will need to create app coordinators for each main "scene" in
your app. For example coordinators, please see the included
[sample app](https://github.com/willowtreeapps/cordux/tree/develop/Example).

## Alternatives

The biggest win that Cordux provides is in routing. If your app does not need
to manage route via state, or navigate via route, it may make more sense to
implement your own app coordinators and use ReSwift for your state management.

## Goals & Non-Goals

*Goals*

The primary goal is to simplify app level code with robust framework code. The
following are the main areas of interest:

* Call point API
* Navigation code
* Routing code
* Subscriptions to the store
* View controller lifecycle needs

*Non-Goals*

* Time travel
* State restoration
* State and action serialization
* Supporting additional strategies for asynchronous work or side effects

## Roadmap

Production level apps at WillowTree are currently being developed with Cordux.
By the end of 2016 we hope to have the needs of this framework figured out.

If ReSwift adopts our routing needs, Cordux may become a ReSwift extension.

## Code of Conduct<a name="conduct"></a>

Please read our [code of conduct](https://github.com/willowtreeapps/cordux/blob/develop/CODE_OF_CONDUCT.md)
before participating. Please report any violations to
[open.source.conduct@willowtreeapps.com](mailto:open.source.conduct@willowtreeapps.com.).

## Contributing<a name="contributing"></a>

Please read our
[contributing guidelines](https://github.com/willowtreeapps/cordux/blob/develop/CONTRIBUTING.md)
before contributing. Included are directions for opening issues, coding
standards, and notes on development.

Beyond contributing to the main code base, documentation and unit tests are
always welcome contributions.
