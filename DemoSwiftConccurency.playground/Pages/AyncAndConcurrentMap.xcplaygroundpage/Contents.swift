import Foundation

extension Sequence {
    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()

        var count = 0

        for element in self {
            print("📝 element count: \(count)")
            /*
             順次処理を実行するのでcountは1ずつ増える
             */
            let value = try await transform(element)
            print("📝 asyncMap count: \(count)")
            count += 1
            values.append(value)
        }

        return values
    }

    func concurrentMap<T>(
        _ transform: @escaping (Element) async throws -> T
    ) async throws -> [T] {
        // 全てのタスクを先に作成する
        let tasks = map { element in
            Task {
                try await transform(element)
            }
        }

        var count = 0

        return try await tasks.asyncMap { task in
            print("📝 await task value: \(count)")
            let value = try await task.value
            print("📝 concurrentMap count: \(count)")
            count += 1
            return value
        }
    }
}

func doWork(data: Int) async -> Int {
    print("📝 doWork: \(data)")
    try! await Task.sleep(nanoseconds: 2_000_000_000)
    return data * data
}

let datas = [1,2,3,4,5,6,7]

func asyncLoad() async throws -> [Int] {
    await datas.asyncMap({ data in
        print("📝 \(data)")
        return await doWork(data: data)
    })
}

func concurrentLoad() async throws -> [Int] {
    try await datas.concurrentMap({ data in
        print("📝 \(data)")
        return await doWork(data: data)
    })
}

//Task {
//    do {
//        print("📝 start asyncLoad")
//        let result = try await asyncLoad()
//        print("📝 finish asyncLoad")
//        print(result)
//    } catch {
//        print(error.localizedDescription)
//    }
//}

//Task {
//    do {
//        print("📝 start concurrentLoad")
//        let result = try await concurrentLoad()
//        print("📝 finish concurrentLoad")
//        print(result)
//    } catch {
//        print(error.localizedDescription)
//    }
//}

/*
 concurrentMapの方はここのタスクをTaskで囲むことによって、並列実行を可能にしており
 いや、やっぱりわからん。https://stackoverflow.com/questions/74957883/building-concurrent-version-of-map 質問した。

 Tasks are executed immediately after creation and do not require explicit initiation. Therefore, each process is executed (in parallel) at the point where tasks are created.

 I misunderstood that it would not be executed until the declaration of .value.
 value | Apple Developer Documentation

 */


let hoge = Task {
    await doWork(data: 2)
}

do {
    print(await hoge.value)
}


func fetchData(completion: @MainActor @escaping (Result<[Int], Error>) -> Void) {
    URLSession.shared.dataTask(with: URL(string: "..some URL")!) { data, response, error in
        // .. Decode data to a result
        let result: Result<[Int], Error> = .success([])

        Task {
            await completion(result)
        }
    }
}
