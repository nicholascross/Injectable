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

    init(container: Container) {
        self.animals = [container.resolve() as Cat, container.resolve() as Dog, container.resolve() as Moose]
        self.plants = [container.resolve(), container.resolve()]
    }

    static func create(inContainer container: Container) -> Ecosystem {
        return Ecosystem(container: container)
    }
}

private class Animal {
    let genome: Genome

    init(genome: Genome) {
        self.genome = genome
    }
}

private class Dog: Animal, Injectable {
    static func create(inContainer container: Container) -> Dog {
        return Dog(genome: container.resolve())
    }
}

private class Cat: Animal, Injectable {

    static func create(inContainer container: Container) -> Cat {
        return Cat(genome: container.resolve())
    }
}

private class Moose: Animal, Injectable {

    let antlers: Int

    init(genome: Genome, antlers: Int) {
        self.antlers = antlers
        super.init(genome: genome)
    }

    static func create(inContainer container: Container) -> Moose {
        return Moose(genome: container.resolve(), antlers: 2)
    }

    static func didCreate(object: Moose, inContainer container: Container) {

    }
}

private class Plant: Injectable {
    let genome: Genome

    static func create(inContainer container: Container) -> Plant {
        return Plant(genome: container.resolve())
    }

    static func didCreate(object: Plant, inContainer container: Container) {

    }

    init(genome: Genome) {
        self.genome = genome
    }
}

private class Genome: Injectable {
    let data: Data

    static func create(inContainer container: Container) -> Genome {
        return Genome(data: Data())
    }

    static func didCreate(object: Genome, inContainer container: Container) {

    }

    init(data: Data) {
        self.data = data
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
