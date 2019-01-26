//
//  CustomParametersTests.swift
//  InjectableTests
//
//  Created by Nicholas Cross on 19/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation

import Foundation
import XCTest
@testable import Injectable

private class Person: CustomInjectable {
    typealias ParameterType = Int
    let hobby: Programming

    required init(container: Container, parameter: ParameterType) {
        hobby = parameter > 29 ? container.resolve(key: "OldSchool") : container.resolve(key: "NewAge")
    }

    required init(container: Container) {
        hobby = .init(container: container)
    }
}

private class Programming: CustomInjectable {
    typealias ParameterType = String
    let language: String

    required init(container: Container, parameter: ParameterType) {
        language = parameter
    }

    required init(container: Container) {
        language = "Java"
    }
}

private class MockCustomObject: CustomInjectable {
    typealias ParameterType = String

    let parameter: String

    required init(container: Container, parameter: ParameterType) {
        self.parameter = parameter
    }

    required init(container: Container) {
        self.parameter = "missing"
    }
}

class CustomParametersTests: XCTestCase {

    var container: DependencyContainer!

    override func setUp() {
        container = DependencyContainer()
    }

    override func tearDown() {
        container = nil
    }

    func testCustomParameterInjectionAndResolution() {
        container.register(type: Programming.self, key: "OldSchool") { _ in "ObjC" }
        container.register(type: Programming.self, key: "NewAge") { _ in "Swift" }
        container.register(type: Person.self, key: "Nick", { _ in 34 })
        container.register(type: Person.self, key: "Jim", { _ in 25 })

        let nick: Person = container.resolve(key: "Nick")
        let jim: Person = container.resolve(key: "Jim")

        XCTAssertEqual(nick.hobby.language, "ObjC")
        XCTAssertEqual(jim.hobby.language, "Swift")
    }

    func testTransientCustomParameterInjectionAndResolution() {
        container.register(type: Programming.self, key: "OldSchool") { _ in "ObjC" }
        container.register(type: Programming.self, key: "NewAge") { _ in "Swift" }
        container.register(type: Person.self, key: "Nick", { _ in 34 })
        container.register(type: Person.self, key: "Jim", { _ in 25 })

        let nick: Person = container.resolve(key: "Nick", lifetime: .transient)
        let jim: Person = container.resolve(key: "Jim", lifetime: .transient)

        XCTAssertEqual(nick.hobby.language, "ObjC")
        XCTAssertEqual(jim.hobby.language, "Swift")
    }

    func testPersistentCustomParameterInjectionAndResolution() {
        container.register(type: Programming.self, key: "OldSchool") { _ in "ObjC" }
        container.register(type: Programming.self, key: "NewAge") { _ in "Swift" }
        container.register(type: Person.self, key: "Nick", { _ in 34 })
        container.register(type: Person.self, key: "Jim", { _ in 25 })

        let nick: Person = container.resolve(key: "Nick", lifetime: .persistent)
        let jim: Person = container.resolve(key: "Jim", lifetime: .persistent)

        XCTAssertEqual(nick.hobby.language, "ObjC")
        XCTAssertEqual(jim.hobby.language, "Swift")
    }

    func testObjectCreationOccursOnlyOnce() {
        let mock0: MockCustomObject? = container.resolve(key: "test")
        XCTAssertEqual(mock0?.parameter, "missing")

        container.register(type: MockCustomObject.self, key: "test") { _ -> String in return "test" }

        let mock1: MockCustomObject = container.resolve(key: "test")

        XCTAssert(mock0 !== mock1)
        XCTAssertEqual(mock1.parameter, "test")
    }

    func testObjectCreationOccursOnlyOnceWhenTransient() {
        weak var mock0: MockCustomObject? = container.resolve(key: "test", lifetime: .transient)

        container.register(type: MockCustomObject.self, key: "test") { _ -> String in return "test" }

        let mock1: MockCustomObject = container.resolve(key: "test", lifetime: .transient)
        let mock2: MockCustomObject = container.resolve(key: "test", lifetime: .transient)

        XCTAssertNil(mock0)
        XCTAssert(mock1 === mock2)
    }
}
