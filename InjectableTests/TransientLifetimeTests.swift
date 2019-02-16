//
//  TransientLifetimeTests.swift
//  InjectableTests
//
//  Created by Nicholas Cross on 19/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation
@testable import Injectable
import XCTest

private class StaticSiteGenerator: Injectable, LifetimeProviding {
    static let lifetime: Lifetime = .transient

    static func create(inContainer _: Container, variant _: String?) -> StaticSiteGenerator {
        return StaticSiteGenerator()
    }
}

class TransientLifetimeTests: XCTestCase {
    private var container: DependencyContainer!
    private var webFramework1: StaticSiteGenerator?
    private weak var webFramework2: StaticSiteGenerator?

    override func setUp() {
        container = DependencyContainer()
    }

    override func tearDown() {
        container = nil
    }

    func testTransientLifetimeWhenSpecified() {
        webFramework1 = container.resolve()
        webFramework2 = container.resolve()

        XCTAssert(webFramework1 === webFramework2)
        XCTAssertNotNil(webFramework2)

        webFramework1 = nil

        webFramework1 = container.resolve()

        XCTAssert(webFramework1 !== webFramework2)
    }
}
