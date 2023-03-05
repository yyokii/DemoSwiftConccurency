
import Foundation
import SwiftUI

// https://www.hackingwithswift.com/quick-start/concurrency/how-to-cancel-a-task-group

func printMessage() async {
    let result = await withThrowingTaskGroup(of: String.self) { group -> String in

        //        // キャンセルが起こってもそれをハンドリングしないタスク → キャンセルしても出力が得られる
        //        group.addTask {
        //            return "Testing"
        //        }

        // キャセルされるとthrowを投げる → キャンセルされるとこのタスクの出力は出ない
        // 実行順次第では他の終わっているタスクの出力は受け取れる可能性がある
        group.addTask {
            try Task.checkCancellation()
            return "Testing"
        }

        group.addTask {
            return "Group"
        }

        group.addTask {
            return "Cancellation"
        }

        group.cancelAll()
        var collected = [String]()

        do {
            for try await value in group {
                collected.append(value)
            }
        } catch {
            print("📝 catch error: " + error.localizedDescription)
        }

        return collected.joined(separator: " ")
    }

    print(result)
}

Task {
    await printMessage()
}

// MARK: ニュースフィードを取得する例

struct NewsStory: Identifiable, Decodable {
    let id: Int
    let title: String
    let strap: String
    let url: URL
}

struct ContentView {
        @State private var stories = [NewsStory]()

    //    var body: some View {
    //        NavigationView {
    //            List(stories) { story in
    //                VStack(alignment: .leading) {
    //                    Text(story.title)
    //                        .font(.headline)
    //
    //                    Text(story.strap)
    //                }
    //            }
    //            .navigationTitle("Latest News")
    //        }
    //        .task {
    //            await loadStories()
    //        }
    //    }

    private var stories = [NewsStory]()

    mutating func loadStories() async {
        do {
            try await withThrowingTaskGroup(of: [NewsStory].self) { group -> Void in
                for i in 1...5 {
                    group.addTask {
                        let url = URL(string: "https://hws.dev/news-\(i).json")!
                        let (data, _) = try await URLSession.shared.data(from: url)
                        try Task.checkCancellation()
                        let res = try JSONDecoder().decode([NewsStory].self, from: data)
                        print("📝 res \(i): \(res.count)")
                        return res
                    }
                }

                for try await result in group {
                    if result.isEmpty {
                        group.cancelAll()
                        print("📝 cancelAll is called")
                    } else {
                        stories.append(contentsOf: result)
                        print("📝 stories: \(stories.count)")
                    }
                }

                stories.sort { $0.id < $1.id }
            }
        } catch {
            print("Failed to load stories: \(error.localizedDescription)")
        }
    }
}

Task {
    var contentView = ContentView()
    await contentView.loadStories()
}

enum ExampleError: Error {
    case badURL
}

func testCancellation() async {
    do {
        try await withThrowingTaskGroup(of: Void.self) { group -> Void in
            group.addTask {
                try await Task.sleep(nanoseconds: 1_000_000_000)
                throw ExampleError.badURL
            }

            group.addTask {
                try await Task.sleep(nanoseconds: 2_000_000_000)
                print("Task is cancelled: \(Task.isCancelled)")
            }

            try await group.next()
        }
    } catch {
        print("Error thrown: \(error.localizedDescription)")
    }
}

Task {
    await testCancellation()
}
