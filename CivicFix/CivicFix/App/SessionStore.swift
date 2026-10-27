import SwiftUI

@MainActor @Observable
final class SessionStore {
    enum State { case splash, loggedOut, loggedIn }

    var state: State = .splash
    private let auth: AuthServicing

    init(auth: AuthServicing = MockAuthService()) { self.auth = auth }

    func bootstrap() async {
        try? await Task.sleep(for: .seconds(1.5))
        state = auth.isLoggedIn ? .loggedIn : .loggedOut
    }

    func didSignIn() { state = .loggedIn }

    func signOut() {
        auth.signOut()
        state = .loggedOut
    }
}
