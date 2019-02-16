//
//  EphemeralLifetimeTests.swift
//  InjectableTests
//
//  Created by Nicholas Cross on 19/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation
@testable import Injectable
import XCTest

private class JavaScriptWebFramework: Injectable {
    static func create(inContainer _: Container, variant _: String?) -> JavaScriptWebFramework {
        return JavaScriptWebFramework()
    }
}

private class StaticSiteGenerator: Injectable, LifetimeProviding {
    static let lifetime: Lifetime = .ephemeral

    static func create(inContainer _: Container, variant _: String?) -> StaticSiteGenerator {
        return StaticSiteGenerator()
    }
}

class EphemeralLifetimeTests: XCTestCase {
    var container: DependencyContainer!

    override func setUp() {
        container = DependencyContainer()
    }

    override func tearDown() {
        container = nil
    }

    func testEphemeralLifetimeWhenDefault() {
        let webFramework1: JavaScriptWebFramework = container.resolve()
        let webFramework2: JavaScriptWebFramework = container.resolve()

        XCTAssert(webFramework1 !== webFramework2)
    }

    func testEphemeralLifetimeWhenSpecified() {
        let webFramework1: StaticSiteGenerator = container.resolve()
        let webFramework2: StaticSiteGenerator = container.resolve()

        XCTAssert(webFramework1 !== webFramework2)
    }
}
