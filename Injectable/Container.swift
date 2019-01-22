//
//  Container.swift
//  Injectable
//
//  Created by Nicholas Cross on 19/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation

public protocol Container {
    //Resolve any concrete type conforming to Injectable
    //Useful for creating objects with out any registration
    func resolve<Object: Injectable>(lifetime: Lifetime) -> Object
    
    //Resolve any concrete type conforming to CustomInjectable
    //If a resolver has been registered then that will be used instead
    //to provide additional parameters for object initialisation
    //Useful for creating varients of the same type
    func resolve<Object: CustomInjectable>(key: String, lifetime: Lifetime) -> Object
    
    //Resolve any type so long as it has a registered interface resolver
    //Useful for creating objects that conform to an interface when
    //the concrete type is not available at the call site
    func resolveInterface<Interface>() -> Interface!
}

public extension Container {
    public func resolve<Object: Injectable>() -> Object {
        return resolve(lifetime: Object.lifetime)
    }

    public func resolve<Object: CustomInjectable>(key: String) -> Object {
        return resolve(key: key, lifetime: Object.lifetime)
    }
}
