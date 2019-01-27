//
//  CustomInjectable.swift
//  Injectable
//
//  Created by Nicholas Cross on 27/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation

public protocol CustomInjectableObject: InjectableObject {
    associatedtype ParameterType
    init(container: Container, parameter: ParameterType)
}
