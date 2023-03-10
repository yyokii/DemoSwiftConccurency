import Foundation

actor Demo {
    var count = 0

    func doWork() async {
        print("ð before sleep count: \(count)")

        // awaitã«ããä»ã®ã¿ã¹ã¯ãããã¾ã§å°éããå¯è½æ§ããã
        try! await Task.sleep(nanoseconds: 5_000_000_000)

        // countã®å¤ãawaitã®åå¾ã§ä¸è´ããªãå¯è½æ§ããã
        print("ð after sleep count: \(count)")
    }

    func increment() {
        count += 1
    }
}

let demo = Demo()

Task {
    print("2_0")
    let task: Task<Int, Error> = Task.detached(priority: .background) {
        assert(!Thread.isMainThread)
        print("3_0")
        try await Task.sleep(nanoseconds: 10)
        print("3_1")
        return Int.random(in: 0..<10)
    }
    let value = try await task.value
    print("value:", value)
    print("2_1")
}

Task {
    await demo.doWork()
}

Task {
    await demo.increment()
}
