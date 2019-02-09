//
//  ReadMeTests.swift
//  InjectableTests
//
//  Created by Nicholas Cross on 9/2/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation
import XCTest
@testable import Injectable

private protocol Animal { }
private protocol Person {
    var pet: Animal { get }
}

private struct Cat: Animal, Injectable {
    static func create(inContainer container: Container, variant: String?) -> Cat {
        return Cat()
    }
}

private struct CatPerson: Person, Injectable {
    let pet: Animal

    static func create(inContainer container: Container, variant: String?) -> CatPerson {
        return CatPerson(pet: container.resolve() as Cat)
    }

    init(pet: Animal) {
        self.pet = pet
    }
}

class ReadMeTests: XCTestCase {

    private var container: DependencyContainer!

    override func setUp() {
        container = DependencyContainer()
    }

    func testResolve() {
        let catPerson: CatPerson = container.resolve()
        let person: Person = container.resolve() as CatPerson

        XCTAssertTrue(catPerson.pet is Cat)
        XCTAssertTrue(person.pet is Cat)
    }
}
