//
//  CycleTests.swift
//  InjectableTests
//
//  Created by Nicholas Cross on 19/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation
import XCTest
@testable import Injectable

private class TestCycle: Injectable, LifetimeProviding {

    static let lifetime: Lifetime = .transient

    var startCycle: TestCycle2!

    static func create(inContainer container: Container) -> TestCycle {
        return TestCycle()
    }

    static func didCreate(object: TestCycle, inContainer container: Container) {
        object.startCycle = container.resolve()
    }
}

private class TestCycle2: Injectable, LifetimeProviding {
    var completeCycle: TestCycle!

    static let lifetime: Lifetime = .transient

    init(completeCycle: TestCycle) {
        self.completeCycle = completeCycle
    }

    static func create(inContainer container: Container) -> TestCycle2 {
        return TestCycle2(completeCycle: container.resolve())
    }
}

class CycleTests: XCTestCase {

    var container: DependencyContainer!

    override func setUp() {
        container = DependencyContainer()
    }

    override func tearDown() {
        container = nil
    }

    func testDependencyInjectionWithCycle() {
        let objectWithCyclicDependency: TestCycle = container.resolve()
        XCTAssert(objectWithCyclicDependency.startCycle.completeCycle === objectWithCyclicDependency)
    }

}
