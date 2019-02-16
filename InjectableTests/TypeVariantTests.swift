//
//  TypeVariantTests.swift
//  InjectableTests
//
//  Created by Nicholas Cross on 9/2/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation
@testable import Injectable
import XCTest

extension DateFormatter: Injectable, LifetimeProviding {
    public static var lifetime: Lifetime { return .persistent }

    public static func create(inContainer _: Container, variant: String?) -> DateFormatter {
        guard let variant = variant else {
            return DateFormatter()
        }

        let formatter = DateFormatter()
        formatter.dateFormat = variant
        return formatter
    }
}

class TypeVariantTests: XCTestCase {
    private var container: DependencyContainer!

    override func setUp() {
        container = DependencyContainer()
    }

    override func tearDown() {
        container = nil
    }

    func testTypeVariants() {
        let formatter: DateFormatter = container.resolve()
        XCTAssertEqual(formatter.dateFormat, DateFormatter().dateFormat)

        let variantFormatter: DateFormatter = container.resolve(variant: "MMM YYYY")
        XCTAssertNotEqual(variantFormatter.dateFormat, formatter.dateFormat)
        XCTAssertEqual(variantFormatter.dateFormat, "MMM YYYY")

        let variantFormatter2: DateFormatter = container.resolve(variant: "MM-YYYY")
        XCTAssertNotEqual(variantFormatter2.dateFormat, variantFormatter.dateFormat)
        XCTAssertEqual(variantFormatter2.dateFormat, "MM-YYYY")

        XCTAssertTrue(formatter === container.resolve() as DateFormatter)
        XCTAssertTrue(variantFormatter === container.resolve(variant: "MMM YYYY") as DateFormatter)
        XCTAssertTrue(variantFormatter2 === container.resolve(variant: "MM-YYYY") as DateFormatter)
    }
}
