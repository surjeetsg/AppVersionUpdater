//
//  ViewController.swift
//  AppUpdater
//
//  Created by Surjeet Singh on 15/02/2019.
//  Copyright © 2019 Surjeet Singh. All rights reserved.
//

import UIKit

enum VersionError: Error {
    case invalidBundleInfo, invalidResponse
}

class LookupResult: Decodable {
    var results: [AppInfo]
}

class AppInfo: Decodable {
    var version: String
    var trackViewUrl: String
    
}

class AppUpdater: NSObject {
    public static var shared = AppUpdater()
    
    private override init() {
        
    }

    private func getAppInfo(completion: @escaping (AppInfo?, Error?) -> Void) -> URLSessionDataTask? {
        guard let identifier = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String,
            let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
                DispatchQueue.main.async {
                    completion(nil, VersionError.invalidBundleInfo)
                }
                return nil
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            do {
                if let error = error { throw error }
                guard let data = data else { throw VersionError.invalidResponse }
                
                let result = try JSONDecoder().decode(LookupResult.self, from: data)
                guard let info = result.results.first else { throw VersionError.invalidResponse }

                completion(info, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
        return task
    }
    private  func checkVersion(force: Bool) {
        let info = Bundle.main.infoDictionary
        let currentVersion = info?["CFBundleShortVersionString"] as? String
        _ = getAppInfo { (info, error) in
            
            let appStoreAppVersion = info?.version
  
            if let error = error {
                print(error)

            }else if appStoreAppVersion!.compare(currentVersion!, options: .numeric) == .orderedDescending {

                DispatchQueue.main.async {
                    let topController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
                    
                    topController.showAppUpdateAlert(Version: (info?.version)!, Force: force, AppURL: (info?.trackViewUrl)!)
                }
            }
        }
    }
    
    func showUpdateWithConfirmation() {
        checkVersion(force : false)
    }
    
    func showUpdateWithForce() {
        checkVersion(force : true)
    }

}

extension UIViewController {
    
    
    fileprivate func showAppUpdateAlert( Version : String, Force: Bool, AppURL: String) {
        
        let bundleName = Bundle.main.infoDictionary?["CFBundleDisplayName"] ?? ""
        let alertMessage = "\(bundleName) Version \(Version) is available on AppStore."
        let alertTitle = "New Version"
        
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
    
        if !Force {
            let notNowButton = UIAlertAction(title: "Not Now", style: .default) { (action:UIAlertAction) in
                print("Don't Call API");
            }
            alertController.addAction(notNowButton)
        }
        
        let updateButton = UIAlertAction(title: "Update", style: .default) { (action:UIAlertAction) in
            guard let url = URL(string: AppURL) else {
                return
            }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        
        alertController.addAction(updateButton)
        self.present(alertController, animated: true, completion: nil)
    }
}
