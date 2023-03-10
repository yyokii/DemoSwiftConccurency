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
        print("๐: start ", #function, Thread.isMainThread)
        Thread.sleep(forTimeInterval: 2)
        print("๐: finish ", #function, Thread.isMainThread)
    }

    func syncUpload() {
        print("๐: start ", #function, Thread.isMainThread)
        Thread.sleep(forTimeInterval: 2)
        print("๐: finish ", #function, Thread.isMainThread)
    }
}

let fileManager = FileManager()

/*
 Task {
 print("๐: start in Task ", #function, Thread.isMainThread)
 await fileManager.download()
 await fileManager.upload()
 }
 */

// MARK: @MainActorใไปไธใใ้ใฎในใฌใใ

@MainActor
final class ViewModel: ObservableObject {
    let fileManager = FileManager()

    func download() async {
        print("๐: start in Task ", #function, Thread.isMainThread)
        await fileManager.download()
        print("๐: after download ", #function, Thread.isMainThread)
    }

    func download2() {
        Task.detached {
            print("๐: start in Task ", #function, Thread.isMainThread)
            await self.fileManager.download()
            print("๐: after download ", #function, Thread.isMainThread)
        }
    }

    func fetchUserProfile() async throws {
        try await Task.sleep(nanoseconds: 2_000_000_000)
    }

    func download3() {
        Task {
            print("๐: start taskA ", #function, Thread.isMainThread)
            for i in 1...100 {
                print("In Task A: \(i)")
            }
            print("๐: finish taskA ", #function, Thread.isMainThread)
        }

        Task {
            print("๐: start taskB ", #function, Thread.isMainThread)
            for i in 1...100 {
                print("In Task B: \(i)")
            }
            print("๐: finish taskB ", #function, Thread.isMainThread)
        }
    }

    func download4() {
        Task.detached {
            print("๐: start taskA ", #function, Thread.isMainThread)
            for i in 1...100 {
                print("In Task A: \(i)")
            }
            print("๐: finish taskA ", #function, Thread.isMainThread)
        }

        Task.detached {
            print("๐: start taskB ", #function, Thread.isMainThread)
            for i in 1...100 {
                print("In Task B: \(i)")
            }
            print("๐: finish taskB ", #function, Thread.isMainThread)
        }
    }
}

Task {
    let vm = await ViewModel()

    //    await vm.download()
    /*
     @MainActorใชใฎใงใTaskๅใฏใกใคใณในใฌใใใงๅฎ่กใใใฆใใ
     ใใฎๅญใฟในใฏใงใฏใใใฏใฐใฉใฆใณใในใฌใใใงๅฎ่กใใใ
     @MainActorใชใฎใงใfuncๅฉ็จๆใฏawaitใๅฟ่ฆ๏ผใจๆใ๏ผ

     ๐: start in Task  download() true
     ๐: start  syncDownLoad() false
     ๐: finish  syncDownLoad() false
     ๐: after download  download() true
     */

    //    print("\n --- \n")


    //    await vm.download2()
    /*
     Task.detachedใฎๅ?ดๅใฏใใใฏใฐใฉใฆใณใในใฌใใใซใชใ

     ๐: start in Task  download2() false
     ๐: start  syncDownLoad() false
     ๐: finish  syncDownLoad() false
     ๐: after download  download2() false
     */

//    await vm.download4()
}


/*
 initใจdetachedใฎ้ใใฏ๏ผ

 ๅชๅ้?ไฝ
 task local value
 actor context
 */


/*
 Class property 'isMainThread' is unavailable from asynchronous contexts; Work intended for the main actor should be marked with @MainActor; this is an error in Swift 6

 ใใฎ่ญฆๅใฎๆๅณใใใพใใก
 ใตในใใณใใฎๅๅพใงๅคใใใใใไฟก้?ผใงใใชใใใญใใ?ใใใชใใใจใใใใจ๏ผ
 */
