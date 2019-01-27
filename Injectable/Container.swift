//
//  Container.swift
//  Injectable
//
//  Created by Nicholas Cross on 19/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation

public protocol Container {
    //Resolve any concrete type conforming to InjectableValue
    //Useful for creating objects with out any registration
    func resolve<Value: InjectableValue>() -> Value

    //Resolve any concrete type conforming to CustomInjectableValue
    //If a resolver has been registered then that will be used instead
    //to provide additional parameters for object initialisation
    //Useful for creating varients of the same type
    func resolve<Value: CustomInjectableValue>(key: String) -> Value

    //Resolve any concrete reference type conforming to InjectableObject
    //Useful for creating objects with out any registration
    func resolve<Object: InjectableObject>(lifetime: Lifetime) -> Object

    //Resolve any concrete reference type conforming to CustomInjectableObject
    //If a resolver has been registered then that will be used instead
    //to provide additional parameters for object initialisation
    //Useful for creating varients of the same type
    func resolve<Object: CustomInjectableObject>(key: String, lifetime: Lifetime) -> Object

    //Resolve any type so long as it has a registered interface resolver
    //Useful for creating objects that conform to an interface when
    //the concrete type is not available at the call site
    func resolveInterface<Interface>() -> Interface!

    //Resolve any type so long as it has a registered interface
    //resolver that resolves a CustomInjectable type by key
    //Useful for creating objects that conform to an interface when
    //the concrete type is not available at the call site and
    //allow for the creation of variants of the resolved type
    func resolveInterface<Interface>(key: String) -> Interface!
}

public extension Container {
    public func resolve<Object: InjectableObject>() -> Object {
        return resolve(lifetime: Object.lifetime)
    }

    public func resolve<Object: CustomInjectableObject>(key: String) -> Object {
        return resolve(key: key, lifetime: Object.lifetime)
    }
}
