//
//  InterfaceResolver.swift
//  Injectable
//
//  Created by Nicholas Cross on 26/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation

class InterfaceResolver {
    private var registeredResolvers: [String: (Container) -> Any] = [:]
    private var registeredCustomResolvers: [String: (Container, String) -> Any] = [:]

    private let container: Container

    init(container: Container) {
        self.container = container
    }

    func register<Interface, Object: Injectable>(interface: Interface.Type, _ resolver: @escaping (Container) -> Object) {
        registeredResolvers[String(describing: interface)] = resolver
    }

    func register<Interface, Type: CustomInjectable>(interface: Interface.Type, type: Type.Type, key: String, _ provider: @escaping (Container) -> Type.ParameterType) {
        registeredCustomResolvers[String(describing: interface)] = { container, customKey -> Type in
            return container.resolve(key: customKey)
        }
    }

    func resolveInterface<Interface>() -> Interface! {
        let key = String(describing: Interface.self)
        guard let resolver = registeredResolvers[key] else {
            return nil
        }

        return resolver(container) as? Interface
    }

    func resolveInterface<Interface>(key customKey: String) -> Interface! {
        let key = String(describing: Interface.self)
        guard let resolver = registeredCustomResolvers[key] else {
            return nil
        }

        return resolver(container, customKey) as? Interface
    }

}
