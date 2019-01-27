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

private class TestCycle: InjectableObject {

    static let lifetime: Lifetime = .transient

    var startCycle: TestCycle2!

    required init(container: Container) {

    }

    func didInject(container: Container) {
        startCycle = container.resolve()
    }
}

private class TestCycle2: InjectableObject {
    var completeCycle: TestCycle!

    static let lifetime: Lifetime = .transient

    required init(container: Container) {
        completeCycle = container.resolve()
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
