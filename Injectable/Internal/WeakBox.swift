//
//  WeakBox.swift
//  Injectable
//
//  Created by Nicholas Cross on 9/2/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation

class WeakBox {
    weak var item: AnyObject?

    init(item: AnyObject) {
        self.item = item
    }

    static func unbox(object: AnyObject?) -> AnyObject? {
        guard let box = object as? WeakBox else {
            return object
        }

        return box.item
    }

    static func box(object: AnyObject) -> AnyObject {
        return WeakBox(item: object)
    }
}
