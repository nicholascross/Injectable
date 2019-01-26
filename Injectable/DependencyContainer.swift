//
//  DependencyContainer.swift
//  Injectable
//
//  Created by Nicholas Cross on 19/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation

public class DependencyContainer: Container, DependencyStore {
    public static let shared: DependencyContainer = .init()

    let transientObjects: NSMapTable<NSString, AnyObject> = .strongToWeakObjects()
    let persistentObjects: NSMapTable<NSString, AnyObject> = .strongToStrongObjects()
    let lock: RecursiveLock = .init()

    private var basicResolver: DependencyResolver!
    private var interfaceResolver: InterfaceResolver!
    private var customResolver: CustomerDependencyResolver!

    public init() {
        basicResolver = .init(container: self)
        customResolver = .init(container: self)
        interfaceResolver = .init(container: self)
    }

    public func register<Interface, Object: Injectable>(interface: Interface.Type, implementation: Object.Type) {
        interfaceResolver.register(interface: interface, implementation: implementation)
    }

    public func register<Interface, Object: Injectable>(interface: Interface.Type, _ resolver: @escaping (Container) -> Object) {
        interfaceResolver.register(interface: interface, resolver)
    }

    public func register<Interface, Type: CustomInjectable>(interface: Interface.Type, type: Type.Type, key: String, _ provider: @escaping (Container) -> Type.ParameterType) {
        customResolver.register(type: type, key: key, provider)
        interfaceResolver.register(interface: interface, type: type, key: key, provider)
    }

    public func register<Type: CustomInjectable>(type: Type.Type, key: String, _ provider: @escaping (Container) -> Type.ParameterType) {
        customResolver.register(type: type, key: key, provider)
    }

    public func resolve<Object: Injectable>(lifetime: Lifetime) -> Object {
        return basicResolver.resolve(lifetime: lifetime)
    }

    public func resolveInterface<Interface>() -> Interface! {
        return interfaceResolver.resolveInterface()
    }

    public func resolveInterface<Interface>(key: String) -> Interface! {
        return interfaceResolver.resolveInterface(key: key)
    }

    public func resolve<Object: CustomInjectable>(key: String, lifetime: Lifetime) -> Object {
        return customResolver.resolve(key: key, lifetime: lifetime)
    }

}
