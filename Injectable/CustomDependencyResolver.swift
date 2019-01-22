//
//  CustomDependencyResolver.swift
//  Injectable
//
//  Created by Nicholas Cross on 19/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation

class CustomerDependencyResolver {
    private let container: Container & DependencyStore
    private var customParameters: [String: (Container) -> Any] = [:]

    init(container: Container & DependencyStore) {
        self.container = container
    }

    func register<Type: CustomInjectable>(type: Type.Type, key: String, _ provider: @escaping (Container) -> Type.ParameterType) {
        let customKey = "\(String(describing: type))-\(key)"
        self.customParameters[customKey] = provider
    }

    func resolve<Object: CustomInjectable>(key: String, lifetime: Lifetime) -> Object {
        let customKey = "\(String(describing: Object.self))-\(key)"

        switch lifetime {
        case .ephemeral: return createCustom(key: customKey)
        case .transient: return resolveCustom(key: customKey, table: container.transientObjects)
        case .persistent: return resolveCustom(key: customKey, table: container.persistentObjects)
        }
    }

    private func resolveCustom<Object: CustomInjectable>(key: String, table: NSMapTable<NSString, AnyObject>) -> Object {
        return container.lock.synchronized {
            if let object = table.object(forKey: key as NSString) as? Object {
                return object
            }

            guard let parameters = customParameters[key]?(self.container) as? Object.ParameterType else {
                return self.container.createObject(storedWithKey: key, in: table)
            }

            return self.container.createCustomObject(storedWithKey: key, parameters: parameters, in: table)
        }
    }

    private func createCustom<Object: CustomInjectable>(key: String) -> Object {
        guard let parameters = customParameters[key]?(self.container) as? Object.ParameterType else {
            return Object(container: self.container)
        }

        return Object(container: self.container, parameter: parameters)
    }

}
