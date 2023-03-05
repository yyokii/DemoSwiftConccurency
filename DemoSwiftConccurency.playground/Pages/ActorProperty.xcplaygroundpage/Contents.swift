import Foundation
import PlaygroundSupport

// https://www.hackingwithswift.com/quick-start/concurrency/what-is-an-actor-and-why-does-swift-have-them

actor User {
    var score = 10

    func printScore() {
        print("My score is \(score)")
    }

    func copyScore(from other: User) async {
        score = await other.score
    }
}

Task {
    let actor1 = User()
    await print(actor1.score)
}
