//
//  ProtocolResolutionTests.swift
//  InjectableTests
//
//  Created by Nick Cross on 21/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation
import XCTest
@testable import Injectable

protocol Planet {

}

class Earth: Planet, Injectable {
    required init(container: Container) {

    }
}

class Venus: Earth {

}

class Mars: Planet, CustomInjectable {
    typealias ParameterType = Bool

    var inhabitted: Bool

    required init(container: Container, parameter: ParameterType) {
        inhabitted = parameter
    }

    required init(container: Container) {
        inhabitted = false
    }
}

class InterfaceResolutionTests: XCTestCase {

    var container: DependencyContainer!

    override func setUp() {
        container = DependencyContainer()
    }

    override func tearDown() {
        container = nil
    }

    func testProtocolResolution() {
        container.register(interface: Planet.self) { container in container.resolve() as Earth }
        let planet: Planet = container.resolveInterface()
        XCTAssert(planet is Earth)
    }

    func testSimpleRegistration() {
        container.register(interface: Planet.self, implementation: Earth.self)
        let planet: Planet = container.resolveInterface()
        XCTAssert(planet is Earth)
    }

    func testSubClassResolution() {
        container.register(interface: Earth.self) { container in container.resolve() as Venus }
        let planet: Earth = container.resolveInterface()
        XCTAssert(planet is Venus)
    }

    func testIndirectInterfaceResolution() {
        container.register(interface: Planet.self) { container -> Earth in container.resolveInterface() }
        container.register(interface: Earth.self) { container -> Venus in container.resolve() }

        let planet: Planet = container.resolveInterface()
        XCTAssert(planet is Venus)

        let earth: Earth = container.resolve()
        XCTAssertFalse(earth is Venus)
    }

    func testCustomInjectionForInterface() {
        container.register(interface: Planet.self, type: Mars.self, key: "2040") { _ in return true }
        container.register(interface: Planet.self, type: Mars.self, key: "2020") { _ in return false }

        var planet: Planet = container.resolveInterface(key: "2040")

        XCTAssert(planet is Mars)
        if let marsColony = planet as? Mars {
            XCTAssert(marsColony.inhabitted)
        }

        planet = container.resolveInterface(key: "2020")

        XCTAssert(planet is Mars)
        if let marsColony = planet as? Mars {
            XCTAssertFalse(marsColony.inhabitted)
        }

        var mars: Mars = container.resolve(key: "2040")
        XCTAssert(mars.inhabitted)
        mars = container.resolve(key: "2020")
        XCTAssertFalse(mars.inhabitted)
    }

    func testInvalidRegistration() {
        let planet: Planet! = container.resolveInterface()

        XCTAssertNil(planet)
    }

    func testInvalidRegistrationWithKey() {
        let planet: Planet! = container.resolveInterface(key: "asdf")

        XCTAssertNil(planet)
    }
}
