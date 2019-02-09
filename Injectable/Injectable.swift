//
//  InjectableValue.swift
//  Injectable
//
//  Created by Nicholas Cross on 27/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation

public protocol Injectable: InjectableObject, Injector where InjectorType == Self, InjectedType == Self {

}

public extension Injectable {

    static var lifetime: Lifetime {
        guard let lifetimeInjector = Self.injector as? LifetimeProviding.Type else {
            return .ephemeral
        }

        return lifetimeInjector.lifetime
    }

    static func createInjectable(inContainer container: DependencyContainer, variant: String?) -> Self {
        let injectable: Self = createVariant(inContainer: container, variant: variant)
        container.store(object: injectable, variant: variant)
        Self.injector.didCreate(object: injectable, inContainer: container)
        return injectable

    }

    private static func createVariant(inContainer container: Container, variant: String?) -> Self {
        guard let variant = variant else {
            return Self.injector.create(inContainer: container)
        }

        return Self.injector.create(inContainer: container, variant: variant)
    }

    public static var injector: InjectorType.Type {
        return self
    }
}
