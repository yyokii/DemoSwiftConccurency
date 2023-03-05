import Foundation

/**
 そのオブジェクトの操作のみを行うならisolatedで書く方がシンプルに見える
 そうでないならawaitで書いた方が見通しは良さそう。
 */

actor User {
    var name = "Swift"
    var height: Int?
    var weight: Int?
}

// isolatedをつけることで関数全体がsuspendポイントになる
func doWork(user: isolated User) {
    print("name: \(user.name)")
    print("height: \(user.height ?? 0)")
    print("weight: \(user.weight ?? 0)")
    await Task.sleep(2)
}

//// 個別にawaitする例。
//func doWork(user: User) async {
//    print("name: \(await user.name)")
//    print("height: \(await user.height ?? 0)")
//    print("weight: \(await user.weight ?? 0)")
//}


Task {
    let user = User()
    await doWork(user: user)
}
