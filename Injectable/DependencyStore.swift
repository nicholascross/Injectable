//
//  DependencyStore.swift
//  Injectable
//
//  Created by Nicholas Cross on 19/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation

protocol DependencyStore {
    var transientObjects: NSMapTable<NSString, AnyObject> { get }
    var persistentObjects: NSMapTable<NSString, AnyObject> { get }
    var lock: RecursiveLock { get }
}

extension DependencyStore where Self: Container {
    func createCustomObject<Object: CustomInjectable>(storedWithKey key: String, parameters: Object.ParameterType, in table: NSMapTable<NSString, AnyObject>) -> Object {
        let object: Object = Object(container: self, parameter: parameters)
        table.setObject(object as AnyObject, forKey: key as NSString)
        object.didInject(container: self)
        return object
    }

    func createObject<Object: Injectable>(storedWithKey key: String, in table: NSMapTable<NSString, AnyObject>) -> Object {
        let object = Object(container: self)
        table.setObject(object as AnyObject, forKey: key as NSString)
        object.didInject(container: self)
        return object
    }
}
