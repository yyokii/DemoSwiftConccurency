import Foundation

actor User: Codable, hoge {
    enum CodingKeys: CodingKey {
        case username, password
    }

    let username: String
    let password: String
    var isOnline = false

    init(username: String, password: String) {
        self.username = username
        self.password = password
    }

    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(username, forKey: .username)
        try container.encode(password, forKey: .password)
    }

    // protocolのactor隔離されていないfuncはasync宣言にする（actor-isolatedにする）かnonIsolatedにする必要がある
    func doWork() async {
        print("do work")
    }
}

protocol hoge {
    func doWork() async
}


let user = User(username: "twostraws", password: "s3kr1t")
if let encoded = try? JSONEncoder().encode(user) {
    let json = String(decoding: encoded, as: UTF8.self)
    print(json)
}
