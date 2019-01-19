//
//  InjectableTests.swift
//  InjectableTests
//
//  Created by Nicholas Cross on 19/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import XCTest
@testable import Injectable

private class Ecosystem: Injectable {
    let animals: [Animal]
    let plants: [Plant]

    required init(container: Container) {
        self.animals = [container.resolve() as Cat, container.resolve() as Dog, container.resolve() as Moose]
        self.plants = [container.resolve(), container.resolve()]
    }
}

private class Animal {
    let genome: Genome

    required init(container: Container) {
        self.genome = container.resolve()
    }
}

private class Dog: Animal, Injectable {

}

private class Cat: Animal, Injectable {

}

private class Moose: Animal, Injectable {

    let antlers: Int

    required init(container: Container) {
        antlers = 2
        super.init(container: container)
    }
}

private class Plant: Injectable {
    let genome: Genome

    required init(container: Container) {
        self.genome = container.resolve()
    }
}

private class Genome: Injectable {
    let data: Data

    required init(container: Container) {
        data = .init()
    }
}

class InjectableTests: XCTestCase {

    var container: DependencyContainer!

    override func setUp() {
        container = DependencyContainer()
    }

    override func tearDown() {
        container = nil
    }

    func testDependencyInjection() {
        let ecosystem: Ecosystem = container.resolve()
        let cat = ecosystem.animals[0] as? Cat
        let dog = ecosystem.animals[1] as? Dog
        let moose = ecosystem.animals[2] as? Moose

        XCTAssertNotNil(cat)
        XCTAssertNotNil(dog)
        XCTAssertNotNil(moose)
        XCTAssertEqual(ecosystem.plants.count, 2)
        XCTAssertEqual(cat?.genome.data, Data())
    }

}
