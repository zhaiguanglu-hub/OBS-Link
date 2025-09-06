import UIKit

enum Haptics {
	static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
		UIImpactFeedbackGenerator(style: style).impactOccurred()
	}

	static func success() {
		UINotificationFeedbackGenerator().notificationOccurred(.success)
	}

	static func warning() {
		UINotificationFeedbackGenerator().notificationOccurred(.warning)
	}

	static func error() {
		UINotificationFeedbackGenerator().notificationOccurred(.error)
	}
}