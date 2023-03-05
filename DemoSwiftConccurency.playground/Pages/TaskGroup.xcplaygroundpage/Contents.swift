import Foundation

func doWork() async {
    let string = await withTaskGroup(of: String.self) { group -> String in
        group.addTask { "one" }
        group.addTask { "two" }
        group.addTask { "three" }
        group.addTask { "four" }

        // 次（この場合最初）のタスクが完了するのを待つ
        let result = await group.next()
        return result!

        // 全てのタスクを待つ
        var results: [String] = []
        for await value in group {
            results.append(value)
        }
        return results.joined(separator: ",")

        // 全てのタスクを待つが、戻り値なし
        await group.waitForAll()
    }

    print(string)
}

Task {
    await doWork()
}

