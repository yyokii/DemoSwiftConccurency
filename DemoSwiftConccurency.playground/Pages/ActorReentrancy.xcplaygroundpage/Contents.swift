import Foundation

actor Demo {
    var count = 0

    func doWork() async {
        print("📝 before sleep count: \(count)")

        // awaitにより他のタスクがここまで到達する可能性がある
        try! await Task.sleep(nanoseconds: 5_000_000_000)

        // countの値がawaitの前後で一致しない可能性がある
        print("📝 after sleep count: \(count)")
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
