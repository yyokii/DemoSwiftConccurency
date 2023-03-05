import PlaygroundSupport

// race conditionとなる例

import SwiftUI

actor ImageDownloader {
    var cache: [URL: Image] = [:]

    func getImage(_ url: URL) async -> Image {
        if let cachedImage = cache[url] {
            return cachedImage
        }

        // reentrancyのため、この前後で状態が変わっている可能性がある
        let image = await download(url)

        cache[url] = image
        return image
    }

    func download(_ url: URL) async -> Image {
        try! await Task.sleep(nanoseconds: 2_000_000_000)
        return Image(uiImage: .actions)
    }
}

// actor隔離

actor LibraryAccount {
    let idNumber: Int = 0
    var booksOnLoan: [String] = ["a", "b", "c"]
}

extension LibraryAccount {
    func readSome(_ book: String) -> Int  {
        return 1
    }

    func read() -> Int {
        booksOnLoan.reduce(0) { result, book in
            result + readSome(book)
        }
    }

    func readLater() {
        Task.detached {
            // Actor隔離されないのでawaitにする必要がある
            await self.read()
        }
    }

    func readLater2() {
        Task {
            self.read()
        }
    }
}

/*
 actor 競合

 https://github.com/stzn/SwiftPodcast/blob/main/episodes/Swift%20Concurrency%20WWDC22.md
 */

struct FileStatus {
    let url: URL
    var progress: Double
    var compressedSize: Int
    var uncompressedSize: Int
}

struct CompressionUtils {
    static func compressDataInFile(
        at: URL,
        completion: (Int) -> Void,
        progressNotification: (Double) -> Void,
        finalNotification: (Int) -> Void
    ) -> Data {
        return Data()
    }
}

actor ParallelCompressor {
    var logs: [String] = []
    unowned let status: CompressionState

    init(status: CompressionState) {
        self.status = status
    }

    nonisolated func compressFile(url: URL) async  -> Data { // nonisolatedでasyncにする
        await log(update: "Starting for \(url)")
        let compressedData = CompressionUtils.compressDataInFile(at: url) { uncompressedSize in
            Task { @MainActor in
                status.update(url: url, uncompressedSize: uncompressedSize)
            }
        } progressNotification: { progress in
            Task { @MainActor in
                status.update(url: url, progress: progress)
                await log(update: "Progress for \(url): \(progress)")
            }
        } finalNotification: { compressedSize in
            Task { @MainActor in
                status.update(url: url, compressedSize: compressedSize)
            }
        }
        await log(update: "Ending for \(url)")
        return compressedData
    }

    func log(update: String) {
        logs.append(update)
    }
}

@MainActor
class CompressionState: ObservableObject {
    @Published var files: [FileStatus] = []
    var compressor: ParallelCompressor!

    init() {
        self.compressor = ParallelCompressor(status: self)
    }

    func update(url: URL, progress: Double) {
        if let loc = files.firstIndex(where: {$0.url == url}) {
            files[loc].progress = progress
        }
    }

    func update(url: URL, uncompressedSize: Int) {
        if let loc = files.firstIndex(where: {$0.url == url}) {
            files[loc].uncompressedSize = uncompressedSize
        }
    }

    func update(url: URL, compressedSize: Int) {
        if let loc = files.firstIndex(where: {$0.url == url}) {
            files[loc].compressedSize = compressedSize
        }
    }

    func save(_ data: Data, to: URL) async {
        try! await Task.sleep(nanoseconds: 2_000_000_000)
    }

    func compressAllFiles() {
        for file in files {
            Task { // ここTask.detachedにしてるが、理由がいまいち。main actorで実行しなくてもいい、ということの意味合いで使ってるということか多分
                let compressedData = await self.compressor.compressFile(url: file.url)
                await self.save(compressedData, to: file.url)
            }
        }
    }
}


/*
 > ここTask.detachedにしてるが、理由がいまいち
 これの調べ

 https://stackoverflow.com/questions/74226295/difference-between-starting-a-detached-task-and-calling-a-nonisolated-func-in-ma
 */

@MainActor
class Bar {
    func bar() {
        Task.detached(priority: .background) { // detachedなので現在のactorとは切り離されたタスク
            // main actorによる制約を受けないため、スレッドの数によってのみ制限される？
            await self.foo()
        }
    }

    func foo() async {
        // main actor隔離されている
        // detachedしてるが、結局メインスレッドでこれが実行されるのを待つだけなので、このコードだと意味はほとんどない
        try! await Task.sleep(nanoseconds: 2_000_000_000)
    }
}

@MainActor
class Bar2 {
    func bar() {
        Task(priority: .background) {
            await foo()
        }
    }

    nonisolated func foo() async {
        // main actorに隔離されていない、メインスレッド外で実行される
        try! await Task.sleep(nanoseconds: 2_000_000_000)
    }
}
