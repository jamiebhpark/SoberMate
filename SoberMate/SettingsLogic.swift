import SwiftUI
import FirebaseAuth
import Combine

struct SettingsLogic {
    static func toggleDarkMode() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        window.overrideUserInterfaceStyle = window.overrideUserInterfaceStyle == .dark ? .light : .dark
    }

    static func shareApp() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        let url = URL(string: "https://example.com")!
        let activityController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        window.rootViewController?.present(activityController, animated: true, completion: nil)
    }

    static func setNickname(nickname: String) -> AnyPublisher<Void, Error> {
        return FirebaseManager.shared.setNickname(nickname: nickname)
    }
}
