import Foundation
//import UIKit

// main actor利用時に main スレッドで実行されることと、detachedした際にバックグラウンドスレッドになることの確認

struct User {
    let id: ID

    struct ID {
        let id: String
    }
}

class Database {
    func loadModel(withID: User.ID) throws -> User {
        print("📝: loadModel ", Thread.isMainThread)
        return User(id: .init(id: "id"))
    }
}

@MainActor
class ProfileViewController {
    let userID: User.ID? = nil
    let database: Database = Database()
    var user: User? = nil
    private var loadingTask: Task<Void, Never>? = nil

//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//    }

    func doWork() {
        guard loadingTask == nil else {
            return
        }

        print("📝: start doWork ", Thread.isMainThread)

        loadingTask = Task {
//            [weak self] in
//            guard let self = self else {
//                return
//            }
            print("📝: start task ", Thread.isMainThread)
            do {
                let user = try self.database.loadModel(withID: self.userID ?? .init(id: ""))

                print("📝: task 2 ", Thread.isMainThread)

                await self.userDidLoad(user)
            } catch {
                await self.handleError(error)
            }

            await self.loadingTaskDidFinish()
        }
    }

    private func loadingTaskDidFinish() {
        loadingTask = nil
    }

    private func userDidLoad(_ user: User) {}

    private func handleError(_ error: Error) {}
}

Task { @MainActor in
    let vc = ProfileViewController()
    vc.doWork()
}

/*
 doWorkにてTask.detached使用した場合
 📝: start doWork  true
 📝: start task  false
 📝: loadModel  false
 📝: task 2  false

 doWorkにてTask.init使用した場合
 📝: start doWork  true
 📝: start task  true
 📝: loadModel  true
 📝: task 2  true

 */


import SwiftUI

func demo() async {
    let doTask = Task { () -> String in
        return "hi"
    }

    let result = await doTask.result

    do {
        let data = try result.get()
    } catch {
        print(error)
    }
}
