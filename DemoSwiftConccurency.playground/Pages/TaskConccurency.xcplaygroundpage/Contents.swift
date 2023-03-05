import Foundation

var urls: [String] = []
var res: [String] = []

// loopで回しているが、毎回実行→待受となる。

Task {
    for url in urls {
        let task = Task {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            return url
        }

        let value = try await task.result.get()
        res.append(value)
    }
}

// 並列にするならこうなはず

let tasks = urls.map { url in
    Task {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return url
    }
}

for task in tasks {
    let value = try await task.result.get()
    res.append(value)
}
