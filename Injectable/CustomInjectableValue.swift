//
//  CustomInjectableValue.swift
//  Injectable
//
//  Created by Nicholas Cross on 27/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation

public protocol CustomInjectableValue: InjectableValue {
    associatedtype ParameterType
    init(container: Container, parameter: ParameterType)
}
