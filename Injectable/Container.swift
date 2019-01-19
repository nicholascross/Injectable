//
//  Container.swift
//  Injectable
//
//  Created by Nicholas Cross on 19/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation

public protocol Container {
    func create<Object: Injectable>() -> Object
    func create<Object: Injectable>(lifetime: Lifetime) -> Object
}

public extension Container {
    public func create<Object: Injectable>() -> Object {
        return create(lifetime: Object.lifetime)
    }
}
