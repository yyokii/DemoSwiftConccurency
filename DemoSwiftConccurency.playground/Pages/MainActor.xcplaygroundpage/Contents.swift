//: [Previous](@previous)
//: [Next](@next)

import Foundation
import Combine
import SwiftUI

@MainActor protocol DataStoring {
    func save()
}


struct AppleDataStore1: DataStoring {
    func save() { }
}


@MainActor
final class ViewModel: ObservableObject {
    var count: Int = 1

    func increment() {
        count += 1
    }
}


struct SampleView: View {
    @StateObject var vm = ViewModel()

    var body: some View {
        VStack {

            /*

             Button("Button1", action: vm.increment)

             error:
             Converting function value of type '@MainActor () -> ()' to '() -> Void' loses global actor 'MainActor'
             */

            /*
             {} で囲むとOK

             actionは @Sendable でないクロージャである。
             従ってactorコンテキストを引き継ぐのでMainActor
             */
            Button("Button1", action: {vm.increment()})
        }
    }
}

/*
 関数がすでにメインアクタで実行されている場合、await MainActor.run()を使用すると、
 次の実行ループを待たずにすぐにコードが実行されますが、Taskを使用すると、次の実行ループを待つことになる

 https://www.hackingwithswift.com/quick-start/concurrency/how-to-use-mainactor-to-run-code-on-the-main-queue
 */

@MainActor
class ViewModel2: ObservableObject {
    init() {}

    func runTest() async {
        print("runTest 1")
        print("1")

        await MainActor.run {
            print("2")

            Task { @MainActor in
                print("3")
            }

            print("4")
        }

        print("5")
    }

    func runTest2() async {
        print("runTest 2")
        print("1")

        await MainActor.run {
            print("2")
        }

        print("3")
    }

    func runTest3() async {
        print("runTest 3")
        print("1")

        Task { @MainActor in
            print("2")
        }

        print("3")
    }

    func runTest4() async {
        print("runTest 4")
        print("1")

        await MainActor.run {
            Task { @MainActor in
                print("2")
            }
        }

        print("3")
    }
}

Task {
    let model = await ViewModel2()
    // 1 2 4 3 5
//    await model.runTest()
    // 1 2 3
//    await model.runTest2()
    // 1 3 2
//    await model.runTest3()
    // 1 2 3
    await model.runTest4()
}
