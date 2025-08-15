//
//  SceneDelegate.swift
//  htmusic
//
//  Created by xiaopin on 2025/8/14.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
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
       checkForSharedFilesAndTransfer()
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
    
    // 处理URL Scheme调用（SceneDelegate方式）
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for urlContext in URLContexts {
            let url = urlContext.url
            if url.scheme == "htofflinemusic" && url.host == "share" {
                // 从分享扩展跳转过来，立即检查并转存文件
                checkForSharedFilesAndTransfer()
            }
        }
    }

    func checkForSharedFilesAndTransfer() {
        let appGroupId = "group.com.mobiunity.htmusic.shared"
        let userDefaults = UserDefaults(suiteName: appGroupId)
        if userDefaults?.bool(forKey: "com.mobiunity.htmusic.shareCompleted") == true {
            userDefaults?.set(false, forKey: "com.mobiunity.htmusic.shareCompleted")
            userDefaults?.synchronize()
            
            // 从共享沙盒的tracks目录读取文件
            if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId) {
                let sharedTracksURL = containerURL.appendingPathComponent("tracks")
                
                // 创建本地沙盒的tracks目录
                let localDocumentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let localTracksURL = localDocumentsURL.appendingPathComponent("tracks")
                
                do {
                    if !FileManager.default.fileExists(atPath: localTracksURL.path) {
                        try FileManager.default.createDirectory(at: localTracksURL, withIntermediateDirectories: true)
                    }
                } catch {
                    print("创建本地tracks目录失败: \(error)")
                    return
                }
                
                // 读取共享沙盒tracks目录中的所有文件
                let fileURLs = try? FileManager.default.contentsOfDirectory(at: sharedTracksURL, includingPropertiesForKeys: nil)
                for fileURL in fileURLs ?? [] {
                    let destURL = localTracksURL.appendingPathComponent(fileURL.lastPathComponent)
                    do {
                        if FileManager.default.fileExists(atPath: destURL.path) {
                            try FileManager.default.removeItem(at: destURL)
                        }
                        try FileManager.default.moveItem(at: fileURL, to: destURL)
                        print("文件转存成功: \(fileURL.lastPathComponent)")
                    } catch {
                        print("文件转存失败: \(error)")
                    }
                }
                NotificationCenter.default.post(name: NSNotification.Name("sync_files_ok"), object: nil)
            }
        }
    }
}

