//
//  CustomDependencyResolver.swift
//  Injectable
//
//  Created by Nicholas Cross on 19/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation

class CustomerDependencyResolver {
    private let container: Container
    private let store: DependencyStore
    private var customParameters: [String: (Container) -> Any] = [:]

    init(container: Container, store: DependencyStore) {
        self.container = container
        self.store = store
    }

    func register<Type: CustomInjectableObject>(type: Type.Type, key: String, _ provider: @escaping (Container) -> Type.ParameterType) {
        let customKey = "\(String(describing: type))-\(key)"
        self.customParameters[customKey] = provider
    }

    func register<Type: CustomInjectableValue>(type: Type.Type, key: String, _ provider: @escaping (Container) -> Type.ParameterType) {
        let customKey = "\(String(describing: type))-\(key)"
        self.customParameters[customKey] = provider
    }

    func resolve<Value: CustomInjectableValue>(key: String) -> Value {
        let customKey = "\(String(describing: Value.self))-\(key)"

        guard let parameters = customParameters[customKey]?(self.container) as? Value.ParameterType else {
            return store.createValue(usingContainer: container)
        }

        return store.createCustomValue(usingContainer: container, parameters: parameters)
    }

    func resolve<Object: CustomInjectableObject>(key: String, lifetime: Lifetime) -> Object {
        let customKey = "\(String(describing: Object.self))-\(key)"

        switch lifetime {
        case .ephemeral: return createCustom(key: customKey)
        case .transient: return resolveCustom(key: customKey, table: store.transientObjects)
        case .persistent: return resolveCustom(key: customKey, table: store.persistentObjects)
        }
    }

    private func resolveCustom<Object: CustomInjectableObject>(key: String, table: NSMapTable<NSString, AnyObject>) -> Object {
        return store.lock.synchronized {
            if let object = table.object(forKey: key as NSString) as? Object {
                return object
            }

            guard let parameters = customParameters[key]?(self.container) as? Object.ParameterType else {
                return store.createObject(usingContainer: container, storedWithKey: key, in: table)
            }

            return store.createCustomObject(usingContainer: container, storedWithKey: key, parameters: parameters, in: table)
        }
    }

    private func createCustom<Object: CustomInjectableObject>(key: String) -> Object {
        guard let parameters = customParameters[key]?(self.container) as? Object.ParameterType else {
            return Object(container: self.container)
        }

        return Object(container: self.container, parameter: parameters)
    }

}
