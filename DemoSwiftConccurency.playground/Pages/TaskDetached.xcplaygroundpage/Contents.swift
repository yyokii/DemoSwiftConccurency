import SwiftUI
import os.log

class ViewModel2: ObservableObject { }

struct ContentView: View {
    @StateObject private var model = ViewModel2()

    var body: some View {
        Button("Authenticate", action: doWork)
    }

    func doWork() {
        Task.detached {
            for i in 1...10_000 {
                print("In Task 1: \(i)")
            }
        }

        Task.detached {
            for i in 1...10_000 {
                print("In Task 2: \(i)")
            }
        }
    }
}

//let view = ContentView()
//view.doWork()

// detachedにしてるので、Task 1と2が同時に動くはずだが、順番になっているのはなぜ？

/*
 重い処理を利用して再検証

 https://stackoverflow.com/questions/73194897/multiple-detached-tasks-are-not-executed-at-the-same-time
 detachedにするということはそれが別タスクとして定義されるだけで必ずしも並列に動作が走るかはわからない
 */

private let log = OSLog(subsystem: "Detached tasks", category: .pointsOfInterest)

struct ContentView2: View {
    var body: some View {
        Button("Do work", action: doWork)
    }

    func doWork() {
//        os_signpost(.event, log: log, name: #function)

        for i in 0 ..< 1 {
            Task.detached {
//                let id = OSSignpostID(log: log)
//                os_signpost(.begin, log: log, name: #function, signpostID: id, "start %d", i)
                let value = calculatePi(decimalPlaces: 9)
                print(value)
//                os_signpost(.end, log: log, name: #function, signpostID: id, "done")
            }
        }
    }

    // deliberately inefficient calculation of pi using Leibniz series

    func calculatePi(decimalPlaces: Int = 9) -> Double {
        let threshold = pow(0.1, Double(decimalPlaces))
        var isPositive = true
        var denominator: Double = 1
        var value: Double = 0
        var increment: Double

        repeat {
            increment = 4 / denominator
            if isPositive {
                value += increment
            } else {
                value -= increment
            }
            isPositive.toggle()
            denominator += 2
        } while increment >= threshold

        return value
    }
}

let view2 = ContentView2()
view2.doWork()
