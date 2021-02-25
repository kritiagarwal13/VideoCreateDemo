//
//  AppDelegate.swift
//  VideoCreateDemo
//
//  Created by Kriti Agarwal on 25/02/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var navigationController = UINavigationController()
    static let shared = UIApplication.shared.delegate as! AppDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.window = UIWindow(frame:UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()
        showHomeScreen()
        return true
    }
    
    //MARK:- ShowHomeScreen
    
    func showHomeScreen()
    {
        window?.rootViewController = nil
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let home = storyBoard.instantiateViewController(withIdentifier: "ViewController") as? ViewController
        navigationController = UINavigationController(rootViewController: home!)
        navigationController.navigationBar.isHidden = false
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
        self.window?.isHidden = false
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
    }


}

