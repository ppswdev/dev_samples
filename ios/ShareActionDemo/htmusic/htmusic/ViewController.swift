//
//  ViewController.swift
//  htmusic
//
//  Created by xiaopin on 2025/8/14.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("sync_files_ok"), object: nil, queue: .main) { [weak self] (notify) in
            guard let self = self else{return}
            reloadDocuments()
        }
        reloadDocuments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @IBAction func readLocalSandbox(_ sender: Any) {
        checkForSharedFilesAndTransfer()
    }
    func reloadDocuments(){
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let tracksURL = documentsURL.appendingPathComponent("tracks")
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: tracksURL, includingPropertiesForKeys: nil)
            print("Documents目录下的文件:")
            var files = ""
            for url in fileURLs {
                print(url.lastPathComponent)
                files += url.lastPathComponent
                files += "\n"
            }
            label.text = files
        } catch {
            print("读取Documents目录失败: \(error)")
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
                reloadDocuments()
            }
        }
    }
}

