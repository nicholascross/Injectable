//
//  DependencyContainer.swift
//  Injectable
//
//  Created by Nicholas Cross on 19/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation

public class DependencyContainer: Container {

    private let transientObjects: NSMapTable<NSString, AnyObject> = .strongToWeakObjects()
    private let persistentObjects: NSMapTable<NSString, AnyObject> = .strongToStrongObjects()
    private let lock: NSRecursiveLock = .init()

    public static let shared: DependencyContainer = .init()

    public func create<Object: Injectable>(lifetime: Lifetime) -> Object {
        switch lifetime {
        case .ephemeral: return ephemeral()
        case .transient: return transient()
        case .persistent: return persistent()
        }
    }

    private func ephemeral<Object: Injectable>() -> Object {
        return Object(container: self)
    }

    private func transient<Object: Injectable>() -> Object {
        return referenced(table: transientObjects)
    }

    private func persistent<Object: Injectable>() -> Object {
        return referenced(table: persistentObjects)
    }

    private func referenced<Object: Injectable>(table: NSMapTable<NSString, AnyObject>) -> Object {
        lock.lock()
        defer { lock.unlock() }

        let key = String(describing: Object.self) as NSString

        if let object = table.object(forKey: key) as? Object {
            return object
        }

        let object = Object(container: self)
        table.setObject(object as AnyObject, forKey: key)
        object.didInject(container: self)
        return object
    }
}
