//
//  AppDelegate.swift
//  AppAccesibilidad
//
//  Created by Azuany Mila Cerón on 11/3/25.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    
    static var orientationLock = UIInterfaceOrientationMask.portrait {
        didSet {
            if #available(iOS 16.0, *) {
                UIApplication.shared.connectedScenes.forEach { scene in
                    if let windowScene = scene as? UIWindowScene {
                        windowScene.windows.forEach { window in
                            window.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
                        }
                        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: orientationLock)) { error in
                            print("Geometry update error: \(error.localizedDescription)")
                        }
                    }
                }
            } else {
                if orientationLock == .landscape || orientationLock == .landscapeRight {
                    UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
                } else {
                    UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                }
            }
        }
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
