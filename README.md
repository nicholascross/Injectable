# Injectable

A Swift dependency injection container which minimises the need for centralised registration

# Features

- Supports dependency resolution without prior registration of the type with the container
- Supports resolution of the same object based on object lifetime policy, persistent, transient or ephemeral
- Supports both reference and value types
- Supports resolution of multiple variants of the same type differentiated by key
- Supports registration of interface types to allow for resolving dependencies where the implementing class is not directly available
- Supports resolution of interdependant classes with cyclic dependencies

# Trade-offs and limitations

- Registrationless resolution requires visibility of the exact type being resolved
- Resolving via an interface works around the need for visibility of the type being resolved at the expense of requiring registration, this registration is not enforced at compile time, meaning it can fail at runtime if the registration was ommitted
- Coupling between dependency injection framework and injected types through protocol conformance

# Usage examples

See more [usage examples here](UsageExamples.md)

```swift
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
```


