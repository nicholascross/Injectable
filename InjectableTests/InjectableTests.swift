//
//  InjectableTests.swift
//  InjectableTests
//
//  Created by Nicholas Cross on 19/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

@testable import Injectable
import XCTest

private class Ecosystem: Injectable {
    let animals: [Animal]
    let plants: [Plant]

    init(container: Container) {
        animals = [container.resolve() as Cat, container.resolve() as Dog, container.resolve() as Moose]
        plants = [container.resolve(), container.resolve()]
    }

    static func create(inContainer container: Container, variant _: String?) -> Ecosystem {
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
    static func create(inContainer container: Container, variant _: String?) -> Dog {
        return Dog(genome: container.resolve())
    }
}

private class Cat: Animal, Injectable {
    static func create(inContainer container: Container, variant _: String?) -> Cat {
        return Cat(genome: container.resolve())
    }
}

private class Moose: Animal, Injectable {
    let antlers: Int

    init(genome: Genome, antlers: Int) {
        self.antlers = antlers
        super.init(genome: genome)
    }

    static func create(inContainer container: Container, variant _: String?) -> Moose {
        return Moose(genome: container.resolve(), antlers: 2)
    }
}

private class Plant: Injectable {
    let genome: Genome

    static func create(inContainer container: Container, variant _: String?) -> Plant {
        return Plant(genome: container.resolve())
    }

    init(genome: Genome) {
        self.genome = genome
    }
}

private class Genome: Injectable {
    let data: Data

    static func create(inContainer _: Container, variant _: String?) -> Genome {
        return Genome(data: Data())
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
