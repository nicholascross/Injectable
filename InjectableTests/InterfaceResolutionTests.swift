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
    static func create(inContainer container: Container, variant: String?) -> Earth {
        if variant == "Venus" {
            return Venus()
        }

        return Earth()
    }
}

private class Venus: Earth {

}

private class Mars: Planet, Injectable {
    var inhabitted: Bool

    static func create(inContainer container: Container, variant: String?) -> Mars {
        return Mars(inhabitted: true)
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

    func testProtocolResolution() {
        container.register(interface: Planet.self) { container -> Earth in return container.resolve() }
        let planet: Planet = container.resolveInterface()
        XCTAssert(planet is Earth)
    }

    func testSimpleRegistration() {
        container.register(interface: Planet.self, implementation: Earth.self)
        let planet: Planet = container.resolveInterface()
        XCTAssert(planet is Earth)
    }

    func testSubClassResolution() {
        container.register(interface: Earth.self) { container in container.resolve(variant: "Venus") as Earth }
        let planet: Earth = container.resolveInterface()
        XCTAssert(planet is Venus)
    }

}
