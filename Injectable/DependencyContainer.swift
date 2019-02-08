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

    public func resolve<Object: Injectable>(variant: String) -> Object {
        switch Object.lifetime {
        case .transient: return resolve(table: transientObjects, variant: variant)
        case .persistent: return resolve(table: persistentObjects, variant: variant)
        case .ephemeral: return Object.createInjectable(inContainer: self, variant: variant)
        }
    }

    public func register<Interface, InjectableType: Injectable>(interface: Interface.Type, implementation: InjectableType.Type) {
        register(interface: interface, variant: "_") { container -> InjectableType in return container.resolve() }
    }

    public func register<Interface, InjectableType: Injectable>(interface: Interface.Type, implementation: InjectableType.Type, variant: String) {
        register(interface: interface, variant: variant) { container -> InjectableType in return container.resolve() }
    }

    public func register<Interface, InjectableType: Injectable>(interface: Interface.Type, variant: String, _ resolver: @escaping (Container) -> InjectableType) {
        let key = "\(String(describing: Interface.self))-\(variant)"
        registeredResolvers[key] = resolver
    }

    public func resolveInterface<Interface>(variant: String) -> Interface! {
        let key = "\(String(describing: Interface.self))-\(variant)"
        guard let resolver = registeredResolvers[key] else {
            return nil
        }

        return resolver(self) as? Interface
    }

    func store<Object: Injectable>(object: Object, variant: String) {
        let key = "\(String(describing: Object.self))-\(variant)"
        switch Object.lifetime {
        case .transient: transientObjects.setObject(WeakBox.box(object: object as AnyObject), forKey: key as NSString)
        case .persistent: persistentObjects.setObject(object as AnyObject, forKey: key as NSString)
        case .ephemeral: return
        }
    }

    private func resolve<Object: Injectable>(table: NSMapTable<NSString, AnyObject>, variant: String, boxed: Bool = false) -> Object {
        return lock.synchronized {
            let key = "\(String(describing: Object.self))-\(variant)"

            guard let existingObject = table.object(forKey: key as NSString) else {
                //trigger purge
                return Object.createInjectable(inContainer: self, variant: variant)
            }

            guard let object = WeakBox.unbox(object: existingObject) as? Object else {
                return Object.createInjectable(inContainer: self, variant: variant)
            }

            return object
        }
    }

}

private class WeakBox {
    weak var item: AnyObject?

    init(item: AnyObject) {
        self.item = item
    }

    static func unbox(object: AnyObject) -> AnyObject? {
        guard let box = object as? WeakBox else {
            return object
        }

        return box.item
    }

    static func box(object: AnyObject) -> AnyObject {
        return WeakBox(item: object)
    }
}
