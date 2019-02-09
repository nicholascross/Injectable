//
//  Injectable.swift
//  Injectable
//
//  Created by Nicholas Cross on 19/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation

public protocol InjectableObject {
    associatedtype InjectorType

    static var injector: InjectorType.Type { get }
}

public protocol Injector {
    associatedtype InjectedType: InjectableObject

    static func create(inContainer container: Container) -> InjectedType

    static func create(inContainer container: Container, variant: String) -> InjectedType

    static func didCreate(object: InjectedType, inContainer container: Container)
}

extension Injector {
    static func create(inContainer container: Container, variant: String) -> InjectedType {
        return create(inContainer: container)
    }
}
