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

private class Person: InjectableObject {
    static let lifetime: Lifetime = .transient

    let favourateLanguage: Language

    required init(container: Container) {
        favourateLanguage = container.resolve()
    }
}

private class Language: InjectableObject {
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
        var person1: Person? = container.resolve()
        var person2: Person? = container.resolve()

        XCTAssert(person1 === person2)

        person1 = container.resolve(lifetime: .ephemeral)
        person2 = container.resolve(lifetime: .ephemeral)

        XCTAssert(person1 !== person2)

        person1 = container.resolve()

        XCTAssert(person1 !== person2)

        person2 = container.resolve()

        XCTAssert(person1 === person2)
    }

    func testTransientLifetimeWhenSpecified() {
        var language1: Language? = container.resolve(lifetime: .transient)
        var language2: Language? = container.resolve(lifetime: .transient)

        XCTAssert(language1 === language2)

        language1 = container.resolve(lifetime: .ephemeral)
        language2 = container.resolve(lifetime: .ephemeral)

        XCTAssert(language1 !== language2)

        language1 = container.resolve()

        XCTAssert(language1 !== language2)

        language2 = container.resolve()

        XCTAssert(language1 === language2)
    }
}
