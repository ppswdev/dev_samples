//
//  SceneDelegate.swift
//  MyCloudDrive
//
//  Created by xiaopin on 2024/9/19.
//

import UIKit
import SwiftyDropbox
import GoogleSignIn
import MSAL

let kAppKey_db = "nxawgjf8jfhmtrr"
let kAppSecret_db = "exdyasjx8c7tl48"

//let kAppKey_db = "lyxak6myps8nbg4"
//let kAppSecret_db = "eyjp936790kkl8p"

let redirect_uri = "http://localhost"

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        DropboxClientsManager.setupWithAppKey(kAppKey_db)
        
        MSALGlobalConfig.loggerConfig.setLogCallback { (logLevel, message, containsPII) in
            
            // If PiiLoggingEnabled is set YES, this block will potentially contain sensitive information (Personally Identifiable Information), but not all messages will contain it.
            // containsPII == YES indicates if a particular message contains PII.
            // You might want to capture PII only in debug builds, or only if you take necessary actions to handle PII properly according to legal requirements of the region
            if let displayableMessage = message {
                if (!containsPII) {
                    #if DEBUG
                    // NB! This sample uses print just for testing purposes
                    // You should only ever log to NSLog in debug mode to prevent leaking potentially sensitive information
                    print(displayableMessage)
                    #endif
                }
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {

        guard let url = URLContexts.first?.url else { return }
        if url.scheme == "com.googleusercontent.apps.150852583959-i49jt3u3subg7n99ie8vliep7oaap81d" {
            // Google Drive
            GIDSignIn.sharedInstance.handle(url)
        } else if url.scheme == "db-nxawgjf8jfhmtrr" {
            // Dropbox
            let oauthCompletion: DropboxOAuthCompletion = {
                if let authResult = $0 {
                    CloudDriveManager.shared.isLogined_dropbox = false
                    switch authResult {
                    case .success:
                        print("Success! User is logged into DropboxClientsManager.")
                        CloudDriveManager.shared.isLogined_dropbox = true
                        NotificationCenter.default.post(name: .loginStatusChanged, object: nil)
                    case .cancel:
                        print("Authorization flow was manually canceled by user!")
                    case .error(_, let description):
                        print("Error: \(String(describing: description))")
                    }
                }
            }

            for context in URLContexts {
                // stop iterating after the first handle-able url
                if DropboxClientsManager.handleRedirectURL(context.url, includeBackgroundClient: false, completion: oauthCompletion) { break }
            }
        }else if url.scheme == "msauth.com.ppsw.clouddrive" {
            // OneDrive
            MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: nil)
        }
    }
}

