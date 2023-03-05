actor DataStore {
    var username = "Anonymous"
    var friends = [String]()
    var highScores = [Int]()
    var favorites = Set<Int>()

    init() {
        // load data here
    }

    func save() {
        // save data here
    }
}

// 関数全体がDataStoreアクターで実行される
func debugLog(dataStore: isolated DataStore) {
    print("Username: \(dataStore.username)")
    print("Friends: \(dataStore.friends)")
    print("High scores: \(dataStore.highScores)")
    print("Favorites: \(dataStore.favorites)")
}

// 個々のawaitの行で実行されるアクターが決まる
func debugLog2(dataStore: DataStore) async {
    await print("Username: \(dataStore.username)")
    await print("Friends: \(dataStore.friends)")
    await print("High scores: \(dataStore.highScores)")
    await print("Favorites: \(dataStore.favorites)")
}

Task {
    let data = DataStore()
    await debugLog(dataStore: data)
}
