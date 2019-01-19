//
//  Injectable.swift
//  Injectable
//
//  Created by Nicholas Cross on 19/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation

public protocol Injectable: AnyObject {
    static var lifetime: Lifetime { get }

    init(container: Container)

    func didInject(container: Container)
}

public extension Injectable {
    static var lifetime: Lifetime {
        return .ephemeral
    }

    func didInject(container: Container) {

    }
}
