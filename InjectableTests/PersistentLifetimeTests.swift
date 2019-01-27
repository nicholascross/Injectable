//
//  PersistentLifetimeTests.swift
//  InjectableTests
//
//  Created by Nicholas Cross on 19/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation
import XCTest
@testable import Injectable

private class Person: InjectableObject {
    let hobby: Programming

    required init(container: Container) {
        hobby = container.resolve()
    }
}

private class Programming: InjectableObject {
    static let lifetime: Lifetime = .persistent

    let language: String

    required init(container: Container) {
        language = "Swift"
    }
}

class PersistentLifetimeTests: XCTestCase {

    var container: DependencyContainer!

    override func setUp() {
        container = DependencyContainer()
    }

    override func tearDown() {
        container = nil
    }

    func testPersistentLifetime() {
        let person1: Person = container.resolve()
        let person2: Person = container.resolve()

        XCTAssert(person1 !== person2)
        XCTAssert(person1.hobby === person2.hobby)
    }

    func testPersistentLifetimeWhenSpecified() {
        let person1: Person = container.resolve(lifetime: .persistent)
        let person2: Person = container.resolve(lifetime: .persistent)

        XCTAssert(person1 === person2)
    }
}
