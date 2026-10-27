import SwiftUI

@main
struct CivicFixApp: App {
    @State private var session = SessionStore()

    var body: some Scene {
        WindowGroup {
            Group {
                switch session.state {
                case .splash:    SplashView()
                case .loggedOut: NavigationStack { LoginView() }
                case .loggedIn:  HomeView()
                }
            }
            .animation(.easeInOut, value: session.state)
            .environment(session)
            .task { await session.bootstrap() }
        }
    }
}
