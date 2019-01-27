//
//  DependencyContainer.swift
//  Injectable
//
//  Created by Nicholas Cross on 19/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation

public class DependencyContainer: Container {
    public static let shared: DependencyContainer = .init()

    private var basicResolver: DependencyResolver!
    private var interfaceResolver: InterfaceResolver!
    private var customResolver: CustomerDependencyResolver!

    public init() {
        let dependencyStore = DependencyStore()
        basicResolver = .init(container: self, store: dependencyStore)
        customResolver = .init(container: self, store: dependencyStore)
        interfaceResolver = .init(container: self)
    }

    // MARK: Interface registration

    public func register<Interface, Object: InjectableValue>(interface: Interface.Type, implementation: Object.Type) {
        interfaceResolver.register(interface: interface, implementation: implementation)
    }

    public func register<Interface, Object: InjectableValue>(interface: Interface.Type, _ resolver: @escaping (Container) -> Object) {
        interfaceResolver.register(interface: interface, resolver)
    }

    public func register<Interface, Type: CustomInjectableValue>(interface: Interface.Type, type: Type.Type, key: String, _ provider: @escaping (Container) -> Type.ParameterType) {
        customResolver.register(type: type, key: key, provider)
        interfaceResolver.register(interface: interface, type: type, key: key, provider)
    }

    public func register<Interface, Object: InjectableObject>(interface: Interface.Type, implementation: Object.Type) {
        interfaceResolver.register(interface: interface, implementation: implementation)
    }

    public func register<Interface, Object: InjectableObject>(interface: Interface.Type, _ resolver: @escaping (Container) -> Object) {
        interfaceResolver.register(interface: interface, resolver)
    }

    public func register<Interface, Type: CustomInjectableObject>(interface: Interface.Type, type: Type.Type, key: String, _ provider: @escaping (Container) -> Type.ParameterType) {
        customResolver.register(type: type, key: key, provider)
        interfaceResolver.register(interface: interface, type: type, key: key, provider)
    }

    // MARK: Custom parameter registration

    public func register<Type: CustomInjectableValue>(type: Type.Type, key: String, _ provider: @escaping (Container) -> Type.ParameterType) {
        customResolver.register(type: type, key: key, provider)
    }

    public func register<Type: CustomInjectableObject>(type: Type.Type, key: String, _ provider: @escaping (Container) -> Type.ParameterType) {
        customResolver.register(type: type, key: key, provider)
    }

    // MARK: Basic resolvers

    public func resolve<Value: InjectableValue>() -> Value {
        return basicResolver.resolve()
    }

    public func resolve<Object: InjectableObject>(lifetime: Lifetime) -> Object {
        return basicResolver.resolve(lifetime: lifetime)
    }

    // MARK: Custom parameter resolvers

    public func resolve<Value: CustomInjectableValue>(key: String) -> Value {
        return customResolver.resolve(key: key)
    }

    public func resolve<Object: CustomInjectableObject>(key: String, lifetime: Lifetime) -> Object {
        return customResolver.resolve(key: key, lifetime: lifetime)
    }

    // MARK: Interface resolvers

    public func resolveInterface<Interface>() -> Interface! {
        return interfaceResolver.resolveInterface()
    }

    public func resolveInterface<Interface>(key: String) -> Interface! {
        return interfaceResolver.resolveInterface(key: key)
    }

}
