//
//  SceneDelegate.swift
//  AuthPro
//
//  Created by 이주상 on 2023/04/17.
//

import UIKit
import KakaoSDKAuth
import NaverThirdPartyLogin

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.tintColor = .white
        window?.backgroundColor = .black
        window?.rootViewController = UINavigationController(rootViewController: RootViewController())
        window?.makeKeyAndVisible()
    }
    // kakao signin
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.handleOpenUrl(url: url)
            }
        }
        NaverThirdPartyLoginConnection
          .getSharedInstance()?
          .receiveAccessToken(URLContexts.first?.url)
    }
}

