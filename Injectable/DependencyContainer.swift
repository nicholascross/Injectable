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
    private var customResolver: CustomerDependencyResolver!
    private var registeredResolvers: [String: (Container) -> Any] = [:]
    private var registeredCustomResolvers: [String: (Container, String) -> Any] = [:]

    public init() {
        basicResolver = .init(container: self)
        customResolver = .init(container: self)
    }

    public func resolve<Object: Injectable>(lifetime: Lifetime) -> Object {
        return basicResolver.resolve(lifetime: lifetime)
    }

    public func resolve<Object: CustomInjectable>(key: String, lifetime: Lifetime) -> Object {
        return customResolver.resolve(key: key, lifetime: lifetime)
    }

    public func register<Type: CustomInjectable>(type: Type.Type, key: String, _ provider: @escaping (Container) -> Type.ParameterType) {
        customResolver.register(type: type, key: key, provider)
    }

    public func register<Interface, Type: CustomInjectable>(interface: Interface.Type, type: Type.Type, key: String, _ provider: @escaping (Container) -> Type.ParameterType) {
        customResolver.register(type: type, key: key, provider)
        registeredCustomResolvers[String(describing: interface)] = { container, customKey -> Type in
            return container.resolve(key: customKey)
        }
    }

    public func resolveInterface<Interface>() -> Interface! {
        let key = String(describing: Interface.self)
        guard let resolver = registeredResolvers[key] else {
            return nil
        }

        return resolver(self) as? Interface
    }

    public func resolveInterface<Interface>(key customKey: String) -> Interface! {
        let key = String(describing: Interface.self)
        guard let resolver = registeredCustomResolvers[key] else {
            return nil
        }

        return resolver(self, customKey) as? Interface
    }

    public func register<Interface, Object: Injectable>(interface: Interface.Type, _ resolver: @escaping (Container) -> Object) {
        registeredResolvers[String(describing: interface)] = resolver
    }

    public func register<Interface, Object: Injectable>(interface: Interface.Type, implementation: Object.Type) {
        register(interface: interface) { container -> Object in
            return container.resolve()
        }
    }
}
