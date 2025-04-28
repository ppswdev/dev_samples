//
//  CloudDriveManager.swift
//  MyCloudDrive
//
//  Created by xiaopin on 2024/9/20.
//

import Foundation
import UIKit
import SwiftyDropbox

import GoogleSignIn
import GoogleAPIClientForREST
import MSAL
import MSGraphClientSDK

//import MSAL

class CloudDriveManager{
    //MARK: 单例类写法
    static let shared = CloudDriveManager()
    private init(){}
    
    //MARK: 属性
    var isLogined_dropbox = false
    var isLogined_googledrive = false
    var isLogined_onedrive = false
    
    let driveService = GTLRDriveService()
    var msalAccessToken = String()
    var msalClient:MSALPublicClientApplication?
    
    //MARK: 方法
    func dropboxLogin(on vc:UIViewController){
        // OAuth 2 code flow with PKCE that grants a short-lived token with scopes, and performs refreshes of the token automatically.
        let scopeRequest = ScopeRequest(scopeType: .user, scopes: ["account_info.read", "files.metadata.read","files.content.read"], includeGrantedScopes: false)
        DropboxClientsManager.authorizeFromControllerV2(
            UIApplication.shared,
            controller: vc,
            loadingStatusDelegate: nil,
            openURL: { (url: URL) -> Void in UIApplication.shared.open(url, options: [:], completionHandler: nil) },
            scopeRequest: scopeRequest
        )
    }
    
    func dropboxLogout() {
        // 清理Dropbox登录状态
        DropboxClientsManager.unlinkClients()
        isLogined_dropbox = false
        NotificationCenter.default.post(name: .loginStatusChanged, object: nil)
    }
    
    func googleLogin(on vc:UIViewController, completion: @escaping (Bool)->()){
        // 尝试自动登录
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
                if let error = error {
                    print("Failed to restore previous sign-in: \(error)")
                } else {
                    print("Success! User is restored GIDSignIn.")
                    self?.driveService.authorizer = user?.fetcherAuthorizer
                    self?.isLogined_googledrive = true
                    NotificationCenter.default.post(name: .loginStatusChanged, object: nil)
                    completion(true)
                }
            }
            return
        }
        GIDSignIn.sharedInstance.signIn(withPresenting: vc, hint: nil, additionalScopes: [kGTLRAuthScopeDrive,kGTLRAuthScopeDriveFile,kGTLRAuthScopeDriveMetadata]) { [weak self] signInResult, error in
            guard error == nil, let user = signInResult?.user else {
                completion(false)
                return
            }
            // If sign in succeeded, display the app's main content View.
            print("Success! User is logged into GIDSignIn.")
            self?.driveService.authorizer = user.fetcherAuthorizer
            self?.isLogined_googledrive = true
            NotificationCenter.default.post(name: .loginStatusChanged, object: nil)
            completion(true)
        }
    }
    
    func googleLogout() {
        GIDSignIn.sharedInstance.signOut()
        GIDSignIn.sharedInstance.disconnect { error in
            if let error = error {
                print("Failed to disconnect: \(error)")
            } else {
                print("Successfully disconnected.")
                // 清理缓存和状态
                CloudDriveManager.shared.driveService.authorizer = nil
            }    
        }
        isLogined_googledrive = false
        NotificationCenter.default.post(name: .loginStatusChanged, object: nil)
    }

    func onedriveLogin(on vc: UIViewController, completion: @escaping (Bool) -> ()) {
        let kClientID = "0c91ff20-d670-48e0-8c92-75170b1bc538"
        let kRedirectUri = "msauth.com.ppsw.clouddrive://auth"
        let kAuthority = "https://login.microsoftonline.com/common"
        let kGraphEndpoint = "https://graph.microsoft.com/"
        do {
            let authority = try MSALAuthority(url: URL(string: kAuthority)!)
            let msalConfig = MSALPublicClientApplicationConfig(clientId: kClientID, redirectUri: kRedirectUri, authority: authority)
            msalClient = try MSALPublicClientApplication(configuration: msalConfig)
            
            let webViewParameters = MSALWebviewParameters(authPresentationViewController: vc)
            let interactiveParameters = MSALInteractiveTokenParameters(scopes: ["User.Read", "Files.ReadWrite"], webviewParameters: webViewParameters)
            
            msalClient?.acquireToken(with: interactiveParameters) { [weak self] (result, error) in
                guard let self = self, let result = result, error == nil else {
                    print("Could not acquire token: \(String(describing: error))")
                    completion(false)
                    return
                }
                print("OneDrive Access token is \(result.accessToken)")
                self.msalAccessToken = result.accessToken
                self.isLogined_onedrive = true
                NotificationCenter.default.post(name: .loginStatusChanged, object: nil)
                completion(true)
            }
        } catch {
            print("Unable to create MSAL client: \(error)")
            completion(false)
        }
    }
    
    func onedriveLogout() {
        guard let msalClient = msalClient else { return }
        
        do {
            let accounts = try msalClient.allAccounts()
            if let account = accounts.first {
                let signoutParameters = MSALSignoutParameters(webviewParameters: MSALWebviewParameters(authPresentationViewController: UIViewController()))
                msalClient.signout(with: account, signoutParameters: signoutParameters) { (success, error) in
                    if success {
                        print("Successfully signed out")
                        self.isLogined_onedrive = false
                        NotificationCenter.default.post(name: .loginStatusChanged, object: nil)
                    } else {
                        print("Sign out error: \(String(describing: error))")
                    }
                }
            }
        } catch {
            print("Sign out error: \(error)")
        }
    }
}
