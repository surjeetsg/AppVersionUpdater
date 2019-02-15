//
//  ViewController.swift
//  AppUpdater
//
//  Created by Surjeet Singh on 15/02/2019.
//  Copyright © 2019 Surjeet Singh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.checkAppVersion()
    }
    
    func checkAppVersion() {
        AppUpdater.shared.showUpdateWithConfirmation()
    }
    
}

