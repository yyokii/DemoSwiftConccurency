import Foundation


// A protocol with a single `@MainActor` method.
protocol DataStoring {
    @MainActor func save()
}

// A struct that does not conform to the protocol.
struct DataStore1 { }

// When we make it conform and add save() at the same time, our method is implicitly @MainActor.
extension DataStore1: DataStoring {
    func save() { } // This is automatically @MainActor.
}

// A struct that conforms to the protocol.
struct DataStore2: DataStoring { }

// If we later add the save() method, it will *not* be implicitly @MainActor so we need to mark it as such ourselves.
extension DataStore2 {
    @MainActor func save() {}
}


// A protocol marked as @MainActor.
@MainActor protocol DataStoring2_0 {
    func save()
}

// A struct that conforms to DataStoring as part of its primary type definition.
struct DataStore2_1: DataStoring2_0 { // This struct is automatically @MainActor.
    func save() { } // This method is automatically @MainActor.
}

// Another struct that conforms to DataStoring as part of its primary type definition.
struct DataStore2_2: DataStoring2_0 { } // This struct is automatically @MainActor.

// The method is provided in an extension, but it's the same as if it were in the primary type definition.
extension DataStore2_2 {
    func save() { } // This method is automatically @MainActor.
}

// A third struct that does *not* conform to DataStoring in its primary type definition.
struct DataStore2_3 { } // This struct is not @MainActor.

// The conformance is added as an extension
extension DataStore2_3: DataStoring2_0 {
    func save() { } // This method is automatically @MainActor.
}

struct Demo {
    func demo() async {
        Task {
            print("📝: demo ", #function, Thread.isMainThread)
        }
    }
}

Task {
    let demo = Demo()
    await demo.demo()
}
