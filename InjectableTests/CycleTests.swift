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

private class TestCycle: Injectable {

    static let lifetime: Lifetime = .transient

    var startCycle: TestCycle2!

    required init(container: Container) {

    }

    func didInject(container: Container) {
        startCycle = container.create()
    }
}

private class TestCycle2: Injectable {
    var completeCycle: TestCycle!

    static let lifetime: Lifetime = .transient

    required init(container: Container) {
        completeCycle = container.create()
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
        let objectWithCyclicDependency: TestCycle = container.create()
        XCTAssert(objectWithCyclicDependency.startCycle.completeCycle === objectWithCyclicDependency)
    }

}
