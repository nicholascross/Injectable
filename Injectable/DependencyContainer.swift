//
//  DependencyContainer.swift
//  Injectable
//
//  Created by Nicholas Cross on 19/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation

public class DependencyContainer: Container {
    private var transientObjects: NSMapTable<NSString, AnyObject> = .strongToStrongObjects()
    private let persistentObjects: NSMapTable<NSString, AnyObject> = .strongToStrongObjects()
    private let lock: RecursiveLock = .init()
    private var registeredResolvers: [String: (Container) -> Any] = [:]

    public func resolve<Object: Injectable>(variant: String?) -> Object {
        switch Object.lifetime {
        case .transient: return resolve(table: transientObjects, variant: variant)
        case .persistent: return resolve(table: persistentObjects, variant: variant)
        case .ephemeral: return Object.createInjectable(inContainer: self, variant: variant)
        }
    }

    public func register<Interface, InjectableType: Injectable>(interface: Interface.Type, implementation: InjectableType.Type) {
        register(interface: interface, variant: nil) { container -> InjectableType in return container.resolve() }
    }

    public func register<Interface, InjectableType: Injectable>(interface: Interface.Type, implementation: InjectableType.Type, variant: String?) {
        register(interface: interface, variant: variant) { container -> InjectableType in return container.resolve() }
    }

    public func register<Interface, InjectableType: Injectable>(interface: Interface.Type, _ resolver: @escaping (Container) -> InjectableType) {
        register(interface: interface, variant: nil, resolver)
    }

    public func register<Interface, InjectableType: Injectable>(interface: Interface.Type, variant: String?, _ resolver: @escaping (Container) -> InjectableType) {
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
        case .transient: transientObjects.setObject(WeakBox.box(object: object as AnyObject), forKey: key as NSString)
        case .persistent: persistentObjects.setObject(object as AnyObject, forKey: key as NSString)
        case .ephemeral: return
        }
    }

    private func resolve<Object: Injectable>(table: NSMapTable<NSString, AnyObject>, variant: String?, boxed: Bool = false) -> Object {
        return lock.synchronized {
            let key = storageKey(for: Object.self, variant: variant)

            guard let object = WeakBox.unbox(object: table.object(forKey: key as NSString) ) as? Object else {
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

private class WeakBox {
    weak var item: AnyObject?

    init(item: AnyObject) {
        self.item = item
    }

    static func unbox(object: AnyObject?) -> AnyObject? {
        guard let box = object as? WeakBox else {
            return object
        }

        return box.item
    }

    static func box(object: AnyObject) -> AnyObject {
        return WeakBox(item: object)
    }
}
