//
//  DependencyStore.swift
//  Injectable
//
//  Created by Nicholas Cross on 19/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation

class DependencyStore {
    let transientObjects: NSMapTable<NSString, AnyObject> = .strongToWeakObjects()
    let persistentObjects: NSMapTable<NSString, AnyObject> = .strongToStrongObjects()
    let lock: RecursiveLock = .init()

    func createCustomObject<Object: CustomInjectableObject>(usingContainer container: Container, storedWithKey key: String, parameters: Object.ParameterType, in table: NSMapTable<NSString, AnyObject>) -> Object {
        let object: Object = Object(container: container, parameter: parameters)
        table.setObject(object, forKey: key as NSString)
        object.didInject(container: container)
        return object
    }

    func createObject<Object: InjectableObject>(usingContainer container: Container, storedWithKey key: String, in table: NSMapTable<NSString, AnyObject>) -> Object {
        let object = Object(container: container)
        table.setObject(object, forKey: key as NSString)
        object.didInject(container: container)
        return object
    }

    func createValue<Value: InjectableValue>(usingContainer container: Container) -> Value {
        let value = Value(container: container)
        value.didInject(container: container)
        return value
    }

    func createCustomValue<Value: CustomInjectableValue>(usingContainer container: Container, parameters: Value.ParameterType) -> Value {
        let value: Value = Value(container: container, parameter: parameters)
        value.didInject(container: container)
        return value
    }
}
