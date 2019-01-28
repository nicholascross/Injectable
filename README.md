# Injectable

A Swift dependency injection container which minimises the need for centralised registration

# Features

- Support decentralised dependency resolution
- Support varying object lifetimes
- Support reference and value types
- Support registration of type varients that are resolvable by key
- Support registration of interface types to allow for resolving dependencies where the implementing class is not available
- Support for cyclic dependencies
- Eliminates multiple parameters in initialisers for types with numerous dependencies

# Trade-offs and limitations

- Registrationless resolving requires visibility of the exact type being resolved
- Coupling is created between dependency injection framework and injected types through protocol conformance
- Resolving via an interface requires registration, this registration is not enforced at compile time, meaning it can fail at runtime if the registration is ommitted
- Resolving type varients without registering custom parameters will result in parameterless resolution occuring instead
- Due to [restirctions on implementing required initializers in extenstions](https://forums.swift.org/t/why-you-cant-make-someone-elses-class-decodable-a-long-winded-explanation-of-required-initializers/6437) wrapper types might be needed for types you do not own and can only modify via extension

# Usage examples

Simple example

```swift
protocol Animal: InjectableValue { }
protocol Person: InjectableValue { }

struct Cat: Animal {
    init(container: Container) { }
}

struct CatPerson: Person {
    let pet: Animal

    init(container: Container) {
        self.init(pet: container.resolve() as Cat)
    }

    init(pet: Animal) {
        self.pet = pet
    }
}

let container = DependencyContainer()

let catPerson: CatPerson = container.resolve()
let person: Person = container.resolve() as CatPerson
```

See more [usage examples here](UsageExamples.md)
