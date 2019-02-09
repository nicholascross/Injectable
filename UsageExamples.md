# Usage Examples

## Decentralised dependency resolution

Simple types can be resolved without any prior registration with the container.

This is acheived through the use of generic functions on the container and conformance to the `Injectable` protocol for types that need to be injected.

See [InjectableTests.swift](InjectableTests/InjectableTests.swift)

## Object lifetime

- Ephemeral: will always resolve a new object. See [EphemeralLifetimeTests](InjectableTests/EphemeralLifetimeTests.swift)
- Transient: will resolve a new object unless there is an instance already in memory. See [TransientLifetimeTests](InjectableTests/TransientLifetimeTests.swift)
- Persistent: will always resolve the same object. See [PersistentLifetimeTests](InjectableTests/PersistentLifetimeTests.swift)

## Type variants

See [TypeVariantTests](InjectableTests/TypeVariantTests.swift)

## Interface registration

See [InterfaceResolutionTests](InjectableTests/InterfaceResolutionTests.swift)

## Cyclic dependencies

See [CyclesTests](InjectableTests/CycleTests.swift)

