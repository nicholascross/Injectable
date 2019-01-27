//
//  ValueTypeTests.swift
//  InjectableTests
//
//  Created by Nicholas Cross on 27/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation
import XCTest
@testable import Injectable

private protocol Planet {

}

private struct Earth: Planet, InjectableValue {
    init(container: Container) {

    }
}

private struct Mars: Planet, CustomInjectableValue {
    typealias ParameterType = Bool

    var inhabitted: Bool

    init(container: Container, parameter: ParameterType) {
        inhabitted = parameter
    }

    init(container: Container) {
        inhabitted = false
    }
}

class ValueTypeTests: XCTestCase {

    var container: DependencyContainer!

    override func setUp() {
        container = DependencyContainer()
    }

    override func tearDown() {
        container = nil
    }

    func testValueTypeResolution() {
        let _: Earth = container.resolve()

        //the fact that this compiles an executes without cris sufficient
    }

    func testCustomValueTypeResolution() {
        container.register(type: Mars.self, key: "2040") { _ in return true }
        container.register(type: Mars.self, key: "2020") { _ in return false }

        let mars: Mars = container.resolve(key: "2020")
        XCTAssertFalse(mars.inhabitted)

        let marsColony: Mars = container.resolve(key: "2040")
        XCTAssert(marsColony.inhabitted)
        //the fact that this compiles an executes without cris sufficient
    }

    func testValueTypeInterfaceResolution() {
        container.register(interface: Planet.self, implementation: Earth.self)

        let planet: Planet = container.resolveInterface()
        XCTAssert(planet is Earth)
    }

    func testValueTypeInterfaceResolutionClosure() {
        container.register(interface: Planet.self) { container -> Mars in container.resolve() }

        let planet: Planet = container.resolveInterface()
        XCTAssert(planet is Mars)
    }

    func testCustomValueTypeInterfaceResolution() {
        container.register(interface: Planet.self, type: Mars.self, key: "2040") { _ in return true }

        let planet: Planet = container.resolveInterface(key: "2040")
        XCTAssert(planet is Mars)
        if let marsColony = planet as? Mars {
            XCTAssert(marsColony.inhabitted)
        }
    }

    func testValueTypeResolutionForMissingKey() {
        let _: Mars = container.resolve(key: "missing")

        //the fact that this compiles an executes without cris sufficient
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
}
