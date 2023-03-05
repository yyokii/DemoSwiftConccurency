import Foundation

class A {
    var b: B?

    deinit {
        print("📝 deinit A")
    }
}

class B {
    var a: A?

    deinit {
        print("📝 deinit B")
    }
}

let a = A()
let b = B()

a.b = b
b.a = a

a.b = nil
b.a = nil
