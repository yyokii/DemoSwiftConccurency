import Foundation

extension Sequence {
    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()

        var count = 0

        for element in self {
            print("๐ element count: \(count)")
            /*
             ้ ๆฌกๅฆ็ใๅฎ่กใใใฎใงcountใฏ1ใใคๅขใใ
             */
            let value = try await transform(element)
            print("๐ asyncMap count: \(count)")
            count += 1
            values.append(value)
        }

        return values
    }

    func concurrentMap<T>(
        _ transform: @escaping (Element) async throws -> T
    ) async throws -> [T] {
        // ๅจใฆใฎใฟในใฏใๅใซไฝๆใใ
        let tasks = map { element in
            Task {
                try await transform(element)
            }
        }

        var count = 0

        return try await tasks.asyncMap { task in
            print("๐ await task value: \(count)")
            let value = try await task.value
            print("๐ concurrentMap count: \(count)")
            count += 1
            return value
        }
    }
}

func doWork(data: Int) async -> Int {
    print("๐ doWork: \(data)")
    try! await Task.sleep(nanoseconds: 2_000_000_000)
    return data * data
}

let datas = [1,2,3,4,5,6,7]

func asyncLoad() async throws -> [Int] {
    await datas.asyncMap({ data in
        print("๐ \(data)")
        return await doWork(data: data)
    })
}

func concurrentLoad() async throws -> [Int] {
    try await datas.concurrentMap({ data in
        print("๐ \(data)")
        return await doWork(data: data)
    })
}

//Task {
//    do {
//        print("๐ start asyncLoad")
//        let result = try await asyncLoad()
//        print("๐ finish asyncLoad")
//        print(result)
//    } catch {
//        print(error.localizedDescription)
//    }
//}

//Task {
//    do {
//        print("๐ start concurrentLoad")
//        let result = try await concurrentLoad()
//        print("๐ finish concurrentLoad")
//        print(result)
//    } catch {
//        print(error.localizedDescription)
//    }
//}

/*
 concurrentMapใฎๆนใฏใใใฎใฟในใฏใTaskใงๅฒใใใจใซใใฃใฆใไธฆๅๅฎ่กใๅฏ่ฝใซใใฆใใ
 ใใใใใฃใฑใใใใใใhttps://stackoverflow.com/questions/74957883/building-concurrent-version-of-map ่ณชๅใใใ

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
