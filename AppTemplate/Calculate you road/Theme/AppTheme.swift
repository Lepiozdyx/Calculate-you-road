import SwiftUI
import UIKit

enum AppTheme {
    static let background = Color.black
    static let card = Color(red: 0.11, green: 0.11, blue: 0.12)
    static let gold = Color(red: 0.90, green: 0.72, blue: 0.30)
    static let secondaryText = Color(white: 0.55)
    static let statusGreen = Color(red: 0.20, green: 0.78, blue: 0.35)
    static let statusGreenBackground = Color(red: 0.10, green: 0.25, blue: 0.15)
    static let destructive = Color.red

    static let cardCornerRadius: CGFloat = 16
    static let buttonCornerRadius: CGFloat = 14
}

enum AppConfig {
    static let useMockData = false
}

enum OnboardingStorage {
    private static let key = "hasCompletedOnboarding"

    static var hasCompleted: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}

enum ProfileStorage {
    private static let nameKey = "profileName"
    private static let statusKey = "profileStatus"
    private static let avatarFileName = "profileAvatar.jpg"

    static var name: String {
        get { UserDefaults.standard.string(forKey: nameKey) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: nameKey) }
    }

    static var status: String {
        get { UserDefaults.standard.string(forKey: statusKey) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: statusKey) }
    }

    static var avatarURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(avatarFileName)
    }

    static var hasAvatar: Bool {
        FileManager.default.fileExists(atPath: avatarURL.path)
    }

    static func loadAvatar() -> UIImage? {
        guard hasAvatar else { return nil }
        return UIImage(contentsOfFile: avatarURL.path)
    }

    static func saveAvatar(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.85) else { return }
        try? data.write(to: avatarURL, options: .atomic)
    }

    static func removeAvatar() {
        try? FileManager.default.removeItem(at: avatarURL)
    }

    static var displayName: String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Username" : trimmed
    }

    static var displayStatus: String {
        let trimmed = status.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Status" : trimmed
    }

    static var avatarInitial: String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return "U" }
        return String(trimmed.prefix(1)).uppercased()
    }

    static var isNamePlaceholder: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    static var isStatusPlaceholder: Bool {
        status.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

extension View {
    func keyboardDoneToolbar() -> some View {
        toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                }
            }
        }
    }
}
