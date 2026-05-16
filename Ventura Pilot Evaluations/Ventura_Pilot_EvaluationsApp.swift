import SwiftUI

@main
struct Ventura_Pilot_EvaluationsApp: App {
    @State private var store = EvaluationStore()

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environment(store)
        }
    }
}
