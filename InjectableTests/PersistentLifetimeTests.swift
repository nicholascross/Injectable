//
//  PersistentLifetimeTests.swift
//  InjectableTests
//
//  Created by Nicholas Cross on 19/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation
import XCTest
@testable import Injectable

private class StaticSiteGenerator: Injectable, LifetimeProviding {
    static let lifetime: Lifetime = .persistent

    static func create(inContainer container: Container) -> StaticSiteGenerator {
        return StaticSiteGenerator()
    }
}

class PersistentLifetimeTests: XCTestCase {

    var container: DependencyContainer!

    override func setUp() {
        container = DependencyContainer()
    }

    override func tearDown() {
        container = nil
    }

    func testPersistentLifetimeWhenSpecified() {
        var webFramework1: StaticSiteGenerator? = container.resolve()
        weak var webFramework2: StaticSiteGenerator? = container.resolve()

        XCTAssert(webFramework1 === webFramework2)
        XCTAssertNotNil(webFramework2)

        webFramework1 = nil

        XCTAssertNotNil(webFramework2)
    }
}
