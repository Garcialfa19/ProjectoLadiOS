import UIKit

enum ScannerHaptics {
    static func notify(success: Bool) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(success ? .success : .error)
    }
}
