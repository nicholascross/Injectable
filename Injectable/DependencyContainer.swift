//
//  DependencyContainer.swift
//  Injectable
//
//  Created by Nicholas Cross on 19/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation

public class DependencyContainer: Container {
    private var transientObjects: [String: AnyObject]
    private var persistentObjects: [String: AnyObject]
    private let lock: RecursiveLock
    private var registeredResolvers: [String: (Container) -> Any]

    public convenience init() {
        self.init(transientObjects: [:], persistentObjects: [:], lock: .init(), registeredResolvers: [:])
    }

    init(transientObjects: [String: AnyObject], persistentObjects: [String: AnyObject], lock: RecursiveLock, registeredResolvers: [String: (Container) -> Any]) {
        self.transientObjects = transientObjects
        self.persistentObjects = persistentObjects
        self.lock = lock
        self.registeredResolvers = registeredResolvers
    }

    public func resolve<Object: Injectable>(variant: String?) -> Object {
        switch Object.lifetime {
        case .transient: return resolve(storage: transientObjects, variant: variant)
        case .persistent: return resolve(storage: persistentObjects, variant: variant)
        case .ephemeral: return Object.createInjectable(inContainer: self, variant: variant)
        }
    }

    public func register<Interface, InjectableType: Injectable>(interface: Interface.Type, implementation: InjectableType.Type) {
        register(interface: interface, implementation: implementation, variant: nil)
    }

    public func register<Interface, InjectableType: Injectable>(interface: Interface.Type, implementation _: InjectableType.Type, variant: String?) {
        register(interface: interface, variant: variant) { container -> InjectableType in container.resolve(variant: variant) }
    }

    public func register<Interface, InjectableType: Injectable>(interface: Interface.Type, _ resolver: @escaping (Container) -> InjectableType) {
        register(interface: interface, variant: nil, resolver)
    }

    public func register<Interface, InjectableType: Injectable>(interface _: Interface.Type, variant: String?, _ resolver: @escaping (Container) -> InjectableType) {
        let key = storageKey(for: Interface.self, variant: variant)
        registeredResolvers[key] = resolver
    }

    public func resolveInterface<Interface>(variant: String?) -> Interface! {
        let key = storageKey(for: Interface.self, variant: variant)
        guard let resolver = registeredResolvers[key] else {
            return nil
        }

        return resolver(self) as? Interface
    }

    func store<Object: Injectable>(object: Object, variant: String?) {
        let key = storageKey(for: Object.self, variant: variant)

        switch Object.lifetime {
        case .transient: transientObjects[key] = WeakBox.box(object: object as AnyObject)
        case .persistent: persistentObjects[key] = object as AnyObject
        case .ephemeral: return
        }
    }

    private func resolve<Object: Injectable, StoredType: AnyObject>(storage: [String: StoredType], variant: String?) -> Object {
        return lock.synchronized {
            let key = storageKey(for: Object.self, variant: variant)

            guard let object = WeakBox.unbox(object: storage[key]) as? Object else {
                return Object.createInjectable(inContainer: self, variant: variant)
            }

            return object
        }
    }

    private func storageKey<ObjectType>(for object: ObjectType, variant: String?) -> String {
        guard let variant = variant else {
            return "\(String(describing: object))"
        }
        return "\(String(describing: object))-\(variant)"
    }
}
