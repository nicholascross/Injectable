//
//  PersistentLifetimeTests.swift
//  InjectableTests
//
//  Created by Nicholas Cross on 19/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation
@testable import Injectable
import XCTest

private class StaticSiteGenerator: Injectable, LifetimeProviding {
    static let lifetime: Lifetime = .persistent

    static func create(inContainer _: Container, variant _: String?) -> StaticSiteGenerator {
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

    func testReplacePersistentStorage() {
        let webFramework1: StaticSiteGenerator = container.resolve()
        container.storeObject(object: StaticSiteGenerator())
        let webFramework2: StaticSiteGenerator = container.resolve()

        XCTAssert(webFramework1 !== webFramework2)
    }
}
