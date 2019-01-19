//
//  DependencyResolver.swift
//  Injectable
//
//  Created by Nicholas Cross on 19/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation

class DependencyResolver {
    private let container: Container & DependencyStore

    init(container: Container & DependencyStore) {
        self.container = container
    }

    func resolve<Object: Injectable>(lifetime: Lifetime) -> Object {
        switch lifetime {
        case .ephemeral: return Object(container: container)
        case .transient: return resolve(table: container.transientObjects)
        case .persistent: return resolve(table: container.persistentObjects)
        }
    }

    private func resolve<Object: Injectable>(table: NSMapTable<NSString, AnyObject>) -> Object {
        return container.lock.synchronized {
            let key = String(describing: Object.self)

            if let object = table.object(forKey: key as NSString) as? Object {
                return object
            }

            return container.createObject(storedWithKey: key, in: table)
        }
    }

}
