import UIKit

final class OrientationManager {
	static let shared = OrientationManager()
	var allowedOrientations: UIInterfaceOrientationMask = .allButUpsideDown

	func setLandscapeLocked(_ locked: Bool) {
		allowedOrientations = locked ? .landscape : .allButUpsideDown
		let target: UIInterfaceOrientation = locked ? .landscapeRight : .portrait
		UIDevice.current.setValue(target.rawValue, forKey: "orientation")
		UINavigationController.attemptRotationToDeviceOrientation()
	}
}

final class AppDelegate: NSObject, UIApplicationDelegate {
	func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
		OrientationManager.shared.allowedOrientations
	}
}