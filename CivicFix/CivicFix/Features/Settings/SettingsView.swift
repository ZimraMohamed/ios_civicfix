import SwiftUI

/// Profile + settings: account info, theme, change email/password, sign out.
struct SettingsView: View {
    @Environment(SessionStore.self) private var session
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage(AppAppearance.storageKey) private var appearanceRaw = AppAppearance.system.rawValue
    @State private var confirmSignOut = false

    private var appearance: Binding<AppAppearance> {
        Binding(
            get: { AppAppearance(rawValue: appearanceRaw) ?? .system },
            set: { appearanceRaw = $0.rawValue }
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.fieldToField) {
                profileCard

                section("Appearance") {
                    appearancePicker
                }

                section("Account") {
                    VStack(spacing: 0) {
                        NavigationLink {
                            ChangeEmailView(currentEmail: session.profile?.email ?? "")
                        } label: {
                            row(icon: "envelope", title: "Change email")
                        }
                        Divider().overlay(AppColors.border)
                        NavigationLink { ChangePasswordView() } label: {
                            row(icon: "lock", title: "Change password")
                        }
                    }
                }

                AppButton(title: "Sign Out", style: .secondary, systemImage: "rectangle.portrait.and.arrow.right") {
                    confirmSignOut = true
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, 16)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        // Pick up an email change the user just verified from their inbox.
        .task { await session.refreshProfile() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { Task { await session.refreshProfile() } }
        }
        .confirmationDialog("Sign out of CivicFix?", isPresented: $confirmSignOut, titleVisibility: .visible) {
            Button("Sign Out", role: .destructive) { session.signOut() }
        }
    }

    // MARK: - Pieces

    private var profileCard: some View {
        HStack(spacing: 16) {
            Text(session.profile?.initials ?? "?")
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(Circle().fill(AppColors.primary))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(displayName)
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
                Text(session.profile?.email ?? "")
                    .font(AppFonts.subtitle)
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
        .accessibilityElement(children: .combine)
    }

    private var displayName: String {
        let name = session.profile?.displayName ?? ""
        return name.isEmpty ? "Your account" : name
    }

    private var appearancePicker: some View {
        HStack(spacing: 8) {
            ForEach(AppAppearance.allCases) { option in
                let selected = appearance.wrappedValue == option
                Button {
                    appearance.wrappedValue = option
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: option.systemImage).font(.title3)
                        Text(option.title).font(AppFonts.fieldLabel)
                    }
                    .foregroundStyle(selected ? Color.white : AppColors.textPrimary)
                    .frame(maxWidth: .infinity, minHeight: 64)
                    .background(
                        RoundedRectangle(cornerRadius: AppSpacing.inputRadius)
                            .fill(selected ? AppColors.primary : AppColors.background)
                    )
                }
                .accessibilityLabel("\(option.title) appearance")
                .accessibilityAddTraits(selected ? .isSelected : [])
            }
        }
        .padding(8)
        .cardStyle()
    }

    private func section(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.labelToInput) {
            Text(title)
                .font(AppFonts.fieldLabel)
                .foregroundStyle(AppColors.textSecondary)
                .accessibilityAddTraits(.isHeader)
            content().cardStyle()
        }
    }

    private func row(icon: String, title: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundStyle(AppColors.primary)
            Text(title)
                .font(AppFonts.input)
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(AppColors.placeholder)
        }
        .padding(.horizontal, 16)
        .frame(minHeight: AppSpacing.inputHeight)
        .contentShape(Rectangle())
    }
}

private extension View {
    func cardStyle() -> some View {
        self
            .background(RoundedRectangle(cornerRadius: AppSpacing.inputRadius).fill(AppColors.surface))
            .overlay(RoundedRectangle(cornerRadius: AppSpacing.inputRadius)
                .stroke(AppColors.border, lineWidth: AppSpacing.borderWidth))
    }
}

#Preview {
    NavigationStack { SettingsView() }.environment(SessionStore.preview())
}
