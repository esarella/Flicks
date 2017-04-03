//
//  AppDelegate.swift
//  Flicks
//
//  Created by Emmanuel Sarella on 3/29/17.
//  Copyright © 2017 Emmanuel Sarella. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let nowPlayingNavigationController = storyboard.instantiateViewController(withIdentifier: "MoviesNavigationController") as! UINavigationController
        let nowPlayingViewController = nowPlayingNavigationController.topViewController as! MoviesViewController
        nowPlayingViewController.endpoint = "now_playing"
        nowPlayingViewController.title = "Now Playing"
        nowPlayingViewController.tabBarItem.image = UIImage(named: "now_playing")

        let topRatedNavigationController = storyboard.instantiateViewController(withIdentifier: "MoviesNavigationController") as! UINavigationController
        let topRatedViewController = topRatedNavigationController.topViewController as! MoviesViewController
        topRatedViewController.endpoint = "top_rated"
        topRatedViewController.title = "Top Rated"
        topRatedViewController.tabBarItem.image = UIImage(named: "top_rated")

        let tabBarController = UITabBarController()
        tabBarController.tabBar.barTintColor = UIColor(red: 0.95, green: 0.71, blue: 0.21, alpha: 1.0)

        tabBarController.tabBar.tintColor = UIColor.black
        tabBarController.viewControllers = [nowPlayingNavigationController, topRatedNavigationController]

        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        return true
    }

}

