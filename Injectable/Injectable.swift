//
//  InjectableValue.swift
//  Injectable
//
//  Created by Nicholas Cross on 27/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation

public protocol Injectable: InjectableObject where InjectedType == Self {

}

public extension Injectable {

    static var lifetime: Lifetime {
        guard let lifetimeInjector = Self.self as? LifetimeProviding.Type else {
            return .ephemeral
        }

        return lifetimeInjector.lifetime
    }

    static func createInjectable(inContainer container: DependencyContainer, variant: String?) -> Self {
        let injectable: Self = Self.create(inContainer: container, variant: variant)
        container.store(object: injectable, variant: variant)
        Self.didCreate(object: injectable, inContainer: container)
        return injectable
    }
}
