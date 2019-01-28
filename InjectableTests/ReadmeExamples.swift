//
//  ReadmeExamples.swift
//  InjectableTests
//
//  Created by Nicholas Cross on 27/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation
import XCTest
@testable import Injectable

private protocol Language: InjectableObject {

}

class InjectableDataFormatter: CustomInjectableObject {
    typealias ParameterType = String

    let formatter: DateFormatter

    required init(container: Container) {
        formatter = DateFormatter()
    }

    required init(container: Container, parameter: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = parameter
        formatter = dateFormatter
    }
}

class ReadmeExamplesTests: XCTestCase {

    var container: DependencyContainer!

    override func setUp() {
        container = DependencyContainer()
    }

    override func tearDown() {
        container = nil
    }

    func testSimple() {
        struct Fly: InjectableValue {
            init(container: Container) {}
        }

        struct Spider: InjectableValue {
            let stomachContents: Fly

            init(container: Container) {
                stomachContents = container.resolve()
            }
        }

        struct Bird: InjectableValue {
            let stomachContents: Spider

            init(container: Container) {
                stomachContents = container.resolve()
            }
        }

        struct Cat: InjectableValue {
            let stomachContents: Bird

            init(container: Container) {
                stomachContents = container.resolve()
            }
        }

        struct Dog: InjectableValue {
            let stomachContents: Cat

            init(container: Container) {
                stomachContents = container.resolve()
            }
        }

        let dog: Dog = container.resolve()
        let _: Fly = dog.stomachContents.stomachContents.stomachContents.stomachContents
    }

    func testLifetime() {
        /*protocol Language: InjectableObject {

        }*/

        class DeveloperX: InjectableObject {
            //the default lifetime is ephemeral
            //static let lifetime: Lifetime = .ephemeral

            let favourateLanguage: Language

            required init(container: Container) {
                favourateLanguage = container.resolve() as ObjCLanguage
            }
        }

        class DeveloperY: InjectableObject {
            //the default lifetime is ephemeral
            //static let lifetime: Lifetime = .ephemeral

            let favourateLanguage: Language

            required init(container: Container) {
                favourateLanguage = container.resolve() as SwiftLanguage
            }
        }

        class ObjCLanguage: Language {
            static let lifetime: Lifetime = .transient

            let name: String

            required init(container: Container) {
                name = "ObjC"
            }
        }

        class SwiftLanguage: Language {
            static let lifetime: Lifetime = .persistent

            let name: String

            required init(container: Container) {
                name = "Swift"
            }
        }

        var objc: ObjCLanguage! = container.resolve()
        var devX: DeveloperX! = container.resolve()
        var devY: DeveloperY! = container.resolve()

        print("\(devX.favourateLanguage === objc)") //true: it is the same instance
        print("\(devX !== container.resolve() as DeveloperX)") //true: a new instance DeveloperX will be created as it has an ephemeral lifetime

        devX = nil
        objc = nil
        devX = container.resolve() //create a new instance of DeveloperX and ObjCLanguage as ObjCLanguage had a transient lifetime and there was no more instances in memory

        weak var swift = devY.favourateLanguage
        devY = nil
        print("\(swift != nil)") //true: as SwiftLanguage has a persistent lifetime even though it is no longer reference by application code

        devY = container.resolve()
        print("\(swift === devY.favourateLanguage)") //true: when a new DeveloperY is created the same instance of SwiftLanguage is used
    }

    func testFullDateFormatter() {
        container.register(type: InjectableDataFormatter.self, key: "MMM YYYY")
        container.register(type: InjectableDataFormatter.self, key: "dd/MM/YYYY")

        let formatter: InjectableDataFormatter = container.resolve(key: "MMM YYYY")
        print("\(formatter.formatter.string(from: Date()))")
    }

    func testCycles() {
        class CycleStart: InjectableObject {

            static let lifetime: Lifetime = .transient

            var startCycle: CycleComplete!

            required init(container: Container) {

            }

            func didInject(container: Container) {
                startCycle = container.resolve()
            }
        }

        class CycleComplete: InjectableObject {
            var completeCycle: CycleStart

            static let lifetime: Lifetime = .transient

            required init(container: Container) {
                completeCycle = container.resolve()
            }
        }

        let objectWithCyclicDependency: CycleStart = container.resolve()
        print("\(objectWithCyclicDependency.startCycle.completeCycle === objectWithCyclicDependency)") //print: true
    }
}
