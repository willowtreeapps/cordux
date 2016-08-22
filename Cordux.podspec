Pod::Spec.new do |s|
  s.name         = "Cordux"
  s.version      = "0.1.7"
  s.summary      = "App Coordinators & Redux. A framework for UIKit development."
  s.description  = <<-DESC
                   Cordux combines app coordiantors with a redux-like architecture.

                   This allows rapid and powerful UI development with full support
                   for routing and deep linking.
                   DESC

  s.homepage     = "http://github.com/willowtreeapps/cordux"
  s.license      = "MIT"
  s.authors      = {
                      "Ian Terrell" => "ian.terrell@gmail.com",
                   }

  s.source       = {
                      :git => "https://github.com/willowtreeapps/cordux.git",
                      :tag => "v0.1.7"
                   }

  s.platform = :ios, :tvos
  s.ios.deployment_target = "9.0"
  s.tvos.deployment_target = "9.1"

  s.source_files = "Sources/*.swift"
end
