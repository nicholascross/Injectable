//
//  InjectableValue.swift
//  Injectable
//
//  Created by Nicholas Cross on 27/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation

public protocol InjectableValue {
    init(container: Container)

    func didInject(container: Container)
}

public extension InjectableValue {
    func didInject(container: Container) {

    }
}
