//
//  ViewController.swift
//  MyCloudDrive
//
//  Created by xiaopin on 2024/9/19.
//

import UIKit
import SwiftyDropbox
import GoogleSignIn

extension Notification.Name {
    static let loginStatusChanged = Notification.Name("loginStatusChanged")
}

class ViewController: UIViewController {
    
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        NotificationCenter.default.addObserver(forName: .loginStatusChanged, object: nil, queue: .main) { [weak self] (notify) in
            guard let self = self else{return}
            label1.text = CloudDriveManager.shared.isLogined_dropbox ? "Logined" : "Not log in"
            label2.text = CloudDriveManager.shared.isLogined_googledrive ? "Logined" : "Not log in"
            label3.text = CloudDriveManager.shared.isLogined_onedrive ? "Logined" : "Not log in"
        }
    }

    @IBAction func toDropbox(_ sender: Any) {
        if CloudDriveManager.shared.isLogined_dropbox {
            let vc = DropboxManageViewController()
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        CloudDriveManager.shared.dropboxLogin(on: self)
    }
    
    @IBAction func toGoogleDrive(_ sender: Any) {
        if CloudDriveManager.shared.isLogined_googledrive {
            let vc = GoogleDriveManageViewController()
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        CloudDriveManager.shared.googleLogin(on: self) { [weak self] result in
            if !result {return }
            let vc = GoogleDriveManageViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func toOneDrive(_ sender: Any) {
        if CloudDriveManager.shared.isLogined_onedrive {
            let vc = OneDriveManageViewController()
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        CloudDriveManager.shared.onedriveLogin(on: self) { [weak self] result in
            if !result {return }
            let vc = OneDriveManageViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
}

