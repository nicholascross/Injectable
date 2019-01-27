//
//  DependencyResolver.swift
//  Injectable
//
//  Created by Nicholas Cross on 19/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation

class DependencyResolver {
    private let container: Container
    private let store: DependencyStore

    init(container: Container, store: DependencyStore) {
        self.container = container
        self.store = store
    }

    func resolve<Value: InjectableValue>() -> Value {
        return store.createValue(usingContainer: container)
    }

    func resolve<Object: InjectableObject>(lifetime: Lifetime) -> Object {
        switch lifetime {
        case .ephemeral: return Object(container: container)
        case .transient: return resolve(table: store.transientObjects)
        case .persistent: return resolve(table: store.persistentObjects)
        }
    }

    private func resolve<Object: InjectableObject>(table: NSMapTable<NSString, AnyObject>) -> Object {
        return store.lock.synchronized {
            let key = String(describing: Object.self)

            if let object = table.object(forKey: key as NSString) as? Object {
                return object
            }

            return store.createObject(usingContainer: container, storedWithKey: key, in: table)
        }
    }

}
