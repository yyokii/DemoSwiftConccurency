
import SwiftUI


@MainActor
func doWork() {
    print("on MainActor")
}

struct ContentView: View {
    var body: some View {
        VStack {
            subView
            Text("hi")
                .task {
                    doWork()
                }
        }
    }

    var subView: some View {
        Text("sub view")
            .task {
               await doWork()
            }
    }
}
