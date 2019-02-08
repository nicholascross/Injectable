//
//  VariantCreating.swift
//  Injectable
//
//  Created by Nicholas Cross on 6/2/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation

public protocol VariantCreating {
    static func create<InjectorType: Injector>(inContainer container: Container, injector: InjectorType.Type, variant: String) -> InjectorType.InjectedType
}
