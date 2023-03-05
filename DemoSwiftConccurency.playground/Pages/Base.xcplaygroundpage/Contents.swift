import Foundation
import SwiftUI

struct FileManager {

    func download() async {
        await Task {
            syncDownLoad()
        }.value
    }

    func upload() async {
        await Task {
            syncUpload()
        }.value
    }

    func syncDownLoad() {
        print("📝: start ", #function, Thread.isMainThread)
        Thread.sleep(forTimeInterval: 2)
        print("📝: finish ", #function, Thread.isMainThread)
    }

    func syncUpload() {
        print("📝: start ", #function, Thread.isMainThread)
        Thread.sleep(forTimeInterval: 2)
        print("📝: finish ", #function, Thread.isMainThread)
    }
}

let fileManager = FileManager()

/*
 Task {
 print("📝: start in Task ", #function, Thread.isMainThread)
 await fileManager.download()
 await fileManager.upload()
 }
 */

// MARK: @MainActorを付与した際のスレッド

@MainActor
final class ViewModel: ObservableObject {
    let fileManager = FileManager()

    func download() async {
        print("📝: start in Task ", #function, Thread.isMainThread)
        await fileManager.download()
        print("📝: after download ", #function, Thread.isMainThread)
    }

    func download2() {
        Task.detached {
            print("📝: start in Task ", #function, Thread.isMainThread)
            await self.fileManager.download()
            print("📝: after download ", #function, Thread.isMainThread)
        }
    }

    func fetchUserProfile() async throws {
        try await Task.sleep(nanoseconds: 2_000_000_000)
    }

    func download3() {
        Task {
            print("📝: start taskA ", #function, Thread.isMainThread)
            for i in 1...100 {
                print("In Task A: \(i)")
            }
            print("📝: finish taskA ", #function, Thread.isMainThread)
        }

        Task {
            print("📝: start taskB ", #function, Thread.isMainThread)
            for i in 1...100 {
                print("In Task B: \(i)")
            }
            print("📝: finish taskB ", #function, Thread.isMainThread)
        }
    }

    func download4() {
        Task.detached {
            print("📝: start taskA ", #function, Thread.isMainThread)
            for i in 1...100 {
                print("In Task A: \(i)")
            }
            print("📝: finish taskA ", #function, Thread.isMainThread)
        }

        Task.detached {
            print("📝: start taskB ", #function, Thread.isMainThread)
            for i in 1...100 {
                print("In Task B: \(i)")
            }
            print("📝: finish taskB ", #function, Thread.isMainThread)
        }
    }
}

Task {
    let vm = await ViewModel()

    //    await vm.download()
    /*
     @MainActorなので、Task内はメインスレッドで実行されている
     その子タスクではバックグラウンドスレッドで実行される
     @MainActorなので、func利用時はawaitが必要（と思う）

     📝: start in Task  download() true
     📝: start  syncDownLoad() false
     📝: finish  syncDownLoad() false
     📝: after download  download() true
     */

    //    print("\n --- \n")


    //    await vm.download2()
    /*
     Task.detachedの場合はバックグラウンドスレッドになる

     📝: start in Task  download2() false
     📝: start  syncDownLoad() false
     📝: finish  syncDownLoad() false
     📝: after download  download2() false
     */

//    await vm.download4()
}


/*
 initとdetachedの違いは？

 優先順位
 task local value
 actor context
 */


/*
 Class property 'isMainThread' is unavailable from asynchronous contexts; Work intended for the main actor should be marked with @MainActor; this is an error in Swift 6

 この警告の意味がいまいち
 サスペンドの前後で変わるから、信頼できないよね、だからなくすということ？
 */
