# Injectable

A Swift dependency injection container which minimises the need for centralised registration

# Features

- Support decentralised dependency resolution
- Support varying object lifetimes
- Support reference and value types
- Support creation of type varients that are resolvable by key
- Support interface based registration to allow for resolving of dependencies where the implementing class is not available/desirable
- Support for cyclic dependencies
- Eliminates multiple parameters in initialisers with types numerous dependencies

# Trade-offs and limitations

- Registrationless resolving requires visibility of the exact type being resolved
- Coupling is created between dependency injection framework and injected types through protocol conformance
- Interface resovable types require registration, this registration is not enforced at compile time, meaning it can fail at runtime if registration is ommitted
- When resolving type varients if no custom parameters are registered then standard resolution will occur instead
- Due to [restirctions on implementing required initializers in extenstions](https://forums.swift.org/t/why-you-cant-make-someone-elses-class-decodable-a-long-winded-explanation-of-required-initializers/6437) wrapper types might be needed for types you do not own and can only modify via extension

# Usage Examples

## Decentralised dependency resolution

Simple types can be resolved without any prior registration with the container.

This is acheived through the use of generic functions on the container and conformance to one of the injectable protocols for types that need to be injected.

- InjectableValue: for value types
- InjectableObject: for reference types

```swift
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
```

## Object lifetime

- Ephemeral: will always resolve a new object
- Transient: will resolve a new object unless there is an instance already in memory
- Persistent: will always resolve the same object

```swift
protocol Language: InjectableObject {

}

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
```

## Custom parameters

```swift
class Person: CustomInjectableObject {
    typealias ParameterType = Int
    let hobby: Programming

    required init(container: Container, parameter: ParameterType) {
        hobby = parameter > 29 ? container.resolve(key: "OldSchool") : container.resolve(key: "NewAge")
    }

    required init(container: Container) {
        hobby = .init(container: container)
    }
}

class Programming: CustomInjectableObject {
    typealias ParameterType = String
    let language: String

    required init(container: Container, parameter: ParameterType) {
        language = parameter
    }

    required init(container: Container) {
        language = "Java"
    }
}

container.register(type: Programming.self, key: "OldSchool") { _ in "ObjC" }
container.register(type: Programming.self, key: "NewAge") { _ in "Swift" }
container.register(type: Person.self, key: "Nick", { _ in 34 })
container.register(type: Person.self, key: "Jim", { _ in 25 })

let nick: Person = container.resolve(key: "Nick")
let jim: Person = container.resolve(key: "Jim")

print("\(nick.hobby.language == "ObjC")") //print: true
print("\(jim.hobby.language == "Swift")") //print: true
```

## Interface registration

```swift
protocol Planet {

}

class Earth: Planet, InjectableObject {
    required init(container: Container) { }
}

class Venus: Earth {

}

container.register(interface: Planet.self, implementation: Earth.self)
let planet1: Planet = container.resolveInterface()
print("\(planet1 is Earth)") //print: true

container.register(interface: Earth.self) { container in container.resolve() as Venus }
let planet2: Earth = container.resolveInterface()
print("\(planet2 is Venus)") //print: true
```

## Cyclic dependencies

```swift
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
```

## Resolving types you do not own

Due to restrictions on implementing required initializers in extensions the only way to inject types you do not own is by creating some kind of wrapper type.

The same problems are faced when trying to apply Decodable to a type you do not own.  See [this discussion](https://forums.swift.org/t/why-you-cant-make-someone-elses-class-decodable-a-long-winded-explanation-of-required-initializers/6437) for more details.

```swift
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

container.register(type: InjectableDataFormatter.self, key: "MMM YYYY")
container.register(type: InjectableDataFormatter.self, key: "dd/MM/YYYY")

let formatter: InjectableDataFormatter = container.resolve(key: "MMM YYYY")
print("\(formatter.formatter.string(from: Date()))") //prints: Jan 2019
```
