//
//  EphemeralLifetimeTests.swift
//  InjectableTests
//
//  Created by Nicholas Cross on 19/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation
import XCTest
@testable import Injectable

private class WebFramework: InjectableObject {

    required init(container: Container) {

    }
}

private class JavaScriptWebFramework: WebFramework {

    static let lifetime: Lifetime = .ephemeral

}

private class StaticWebsiteGenerator: InjectableObject {
    static let lifetime: Lifetime = .transient

    let framework: WebFramework

    required init(container: Container) {
        framework = container.resolve()
    }
}

private class DynamicWebsiteGenerator: InjectableObject {
    static let lifetime: Lifetime = .transient

    let framework: JavaScriptWebFramework

    required init(container: Container) {
        framework = container.resolve()
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
        let generator1: StaticWebsiteGenerator = container.resolve(lifetime: .ephemeral)
        let generator2: StaticWebsiteGenerator = container.resolve(lifetime: .ephemeral)

        XCTAssert(generator1 !== generator2)
        XCTAssert(generator1.framework !== generator2.framework)
    }

    func testEphemeralLifetimeWhenExplicit() {
        let generator1: DynamicWebsiteGenerator = container.resolve(lifetime: .ephemeral)
        let generator2: DynamicWebsiteGenerator = container.resolve(lifetime: .ephemeral)

        XCTAssert(generator1 !== generator2)
        XCTAssert(generator1.framework !== generator2.framework)
    }

    func testEphemeralLifetimeWhenSpecified() {
        let generator1: StaticWebsiteGenerator = container.resolve()
        let generator2: StaticWebsiteGenerator = container.resolve()

        XCTAssert(generator1 === generator2)

        let generator3: StaticWebsiteGenerator = container.resolve(lifetime: .ephemeral)

        XCTAssert(generator1 !== generator3)
    }
}
