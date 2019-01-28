# Injectable

A Swift dependency injection container which minimises the need for centralised registration

# Features

- Support decentralised dependency resolution
- Support multiple object lifetimes
- Support reference and value types
- Support creation of type varients that are resolvable by key
- Support interface based registration to allow for resolving of dependencies where the implementing class is not available
- Support for cyclic dependencies
- Eliminates multiple parameters in initialisers with types numerous dependencies

# Trade-offs and limitations

- Registrationless resolving requires visibility of the exact type being resolved
- Coupling is created between dependency injection framework and injected types through protocol conformance
- Interface resovable types require registration, this registration is not enforced at compile time, meaning it can fail at runtime if registration is ommitted
- When resolving type varients if no custom parameters are registered then standard resolution will occur instead

# Show stoppers (needs to be refactored)

- Unable to add injection support to classes you do not own due to being unable to add required initializers via extension. "'required' initializer must be declared directly in class 'DateFormatter' (not in an extension)"

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

