//
//  Container.swift
//  Injectable
//
//  Created by Nicholas Cross on 19/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation

public protocol Container {
    func resolve<Object: Injectable>(variant: String?) -> Object
    func resolveInterface<Interface>(variant: String?) -> Interface!
}

public extension Container {
    func resolve<Object: Injectable>() -> Object {
        return resolve(variant: nil)
    }

    func resolveInterface<Interface>() -> Interface! {
        return resolveInterface(variant: nil)
    }
}
