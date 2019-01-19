//
//  TransientLifetimeTests.swift
//  InjectableTests
//
//  Created by Nicholas Cross on 19/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//


import Foundation
import XCTest
@testable import Injectable

private class Person: Injectable {
    static let lifetime: Lifetime = .transient

    let favourateLanguage: Language

    required init(container: Container) {
        favourateLanguage = container.create()
    }
}

private class Language: Injectable {
    static let lifetime: Lifetime = .persistent

    let name: String

    required init(container: Container) {
        name = "ObjC"
    }
}

class TransientLifetimeTests: XCTestCase {
    
    var container: DependencyContainer!

    override func setUp() {
        container = DependencyContainer()
    }

    override func tearDown() {
        container = nil
    }

    func testTransientLifetime() {
        var person1: Person? = container.create()
        var person2: Person? = container.create()

        XCTAssert(person1 === person2)

        person1 = container.create(lifetime: .ephemeral)
        person2 = container.create(lifetime: .ephemeral)

        XCTAssert(person1 !== person2)

        person1 = container.create()

        XCTAssert(person1 !== person2)

        person2 = container.create()

        XCTAssert(person1 === person2)
    }

    func testTransientLifetimeWhenSpecified() {
        var language1: Language? = container.create(lifetime: .transient)
        var language2: Language? = container.create(lifetime: .transient)

        XCTAssert(language1 === language2)

        language1 = container.create(lifetime: .ephemeral)
        language2 = container.create(lifetime: .ephemeral)

        XCTAssert(language1 !== language2)

        language1 = container.create()

        XCTAssert(language1 !== language2)

        language2 = container.create()

        XCTAssert(language1 === language2)
    }
}
