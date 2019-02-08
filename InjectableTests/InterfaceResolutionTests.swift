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

private protocol Planet {

}

private class Earth: Planet, Injectable {
    static func create(inContainer container: Container) -> Earth {
        return Earth()
    }

    static func didCreate(object: Earth, inContainer container: Container) {

    }
}

private class Venus: Planet, Injectable {
    static func create(inContainer container: Container) -> Venus {
        return Venus()
    }

    static func didCreate(object: Venus, inContainer container: Container) {

    }
}

private class Mars: Planet, Injectable {
    var inhabitted: Bool

    static func create(inContainer container: Container) -> Mars {
        return Mars(inhabitted: true)
    }

    static func didCreate(object: Mars, inContainer container: Container) {

    }

    init(inhabitted: Bool) {
        self.inhabitted = inhabitted
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
/*
    func testProtocolResolution() {
        container.register(interface: Planet.self) { container in container.resolve() as Earth }
        let planet: Planet = container.resolveInterface()
        XCTAssert(planet is Earth)
    }
*/
    func testSimpleRegistration() {
        container.register(interface: Planet.self, implementation: Earth.self)
        let planet: Planet = container.resolveInterface()
        XCTAssert(planet is Earth)
    }
/*
    func testSubClassResolution() {
        container.register(interface: Earth.self) { container in container.resolve() as Venus }
        let planet: Earth = container.resolveInterface()
        XCTAssert(planet is Venus)
    }
*/
   /* func testIndirectInterfaceResolution() {
        container.register(interface: Planet.self) { container -> Earth in container.resolveInterface() }
        container.register(interface: Earth.self) { container -> Venus in container.resolve() }

        let planet: Planet = container.resolveInterface()
        XCTAssert(planet is Venus)

        let earth: Earth = container.resolve()
        XCTAssertFalse(earth is Venus)
    }*/
}
