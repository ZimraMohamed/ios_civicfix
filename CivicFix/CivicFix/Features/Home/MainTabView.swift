import SwiftUI

/// The signed-in shell: a bottom tab bar. Each tab has its own navigation stack.
/// Report tab (camera + location + hashtags): `.public` users. Reports tab (review list): `.admin` users.
struct MainTabView: View {
    enum Tab: Hashable { case home, report, reports, settings }

    @Environment(SessionStore.self) private var session
    @State private var selection: Tab = .home

    private var isAdmin: Bool { session.profile?.isAdmin ?? false }
    private var canReport: Bool { session.profile?.has(.public) ?? true }

    var body: some View {
        TabView(selection: $selection) {
            NavigationStack { HomeView() }
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(Tab.home)

            if canReport {
                NavigationStack { ReportView() }
                    .tabItem { Label("Report", systemImage: "camera.fill") }
                    .tag(Tab.report)
            }

            if isAdmin {
                NavigationStack { AdminReportsView() }
                    .tabItem { Label("Reports", systemImage: "tray.full.fill") }
                    .tag(Tab.reports)
            }

            NavigationStack { SettingsView() }
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(Tab.settings)
        }
        .tint(AppColors.primary)
    }
}

#Preview { MainTabView().environment(SessionStore.preview()) }
