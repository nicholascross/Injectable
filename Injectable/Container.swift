//
//  Container.swift
//  Injectable
//
//  Created by Nicholas Cross on 19/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation

public protocol Container {
    func resolve<Object: Injectable>(lifetime: Lifetime) -> Object
    func resolve<Object: CustomInjectable>(key: String, lifetime: Lifetime) -> Object
}

public extension Container {
    public func resolve<Object: Injectable>() -> Object {
        return resolve(lifetime: Object.lifetime)
    }

    public func resolve<Object: CustomInjectable>(key: String) -> Object {
        return resolve(key: key, lifetime: Object.lifetime)
    }
}
