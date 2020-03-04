//
//  AppDelegate.swift
//  PSXCovers
//
//  Created by Digital on 23/02/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        deleteAllDataIfNeeded()
        return true
    }
}

//MARK: - Settings bundle
private extension AppDelegate {
    func deleteAllDataIfNeeded() {
        let key = "DeleteAllContent"
        if UserDefaults.standard.bool(forKey: key) {
            UserDefaults.standard.set(false, forKey: key)
            let appDomain = Bundle.main.bundleIdentifier
            UserDefaults.standard.removePersistentDomain(forName: appDomain!)
            deleteAllData()
        }
    }
}

//MARK: - Data persistence helpers
private extension AppDelegate {
    func deleteAllData() {
        try? DataService.realm.write {
            DataService.realm.deleteAll()
        }
    }
}

