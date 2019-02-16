//
//  Injectable.swift
//  Injectable
//
//  Created by Nicholas Cross on 19/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation

public protocol InjectableObject {
    associatedtype InjectedType: InjectableObject

    static func create(inContainer container: Container, variant: String?) -> InjectedType

    static func didCreate(object: InjectedType, inContainer container: Container)
}

extension InjectableObject {
    public static func didCreate(object: InjectedType, inContainer container: Container) {
        
    }
}
