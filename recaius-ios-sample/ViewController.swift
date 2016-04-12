//
//  ViewController.swift
//  recaius-ios-sample
//
//  Created by Miyake Akira on 2016/03/25.
//  Copyright © 2016年 Miyake Akira. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var informationLabel: UILabel?
    
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        appDelegate.appOperator?.statePublisher.on(.DidChange) { state in
            self.updateInformationLabel(state)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let appOperator = appDelegate.appOperator {
            updateInformationLabel(appOperator.statePublisher.value)
        }
    }

    
    private func updateInformationLabel(state: AppState) {
        switch state {
        case .Initializing:
            self.informationLabel?.text = "初期化中です"
        case .Idling:
            self.informationLabel?.text = "待機中です"
        case .AcceptingInput:
            self.informationLabel?.text = "入力受付中です"
        case .NotifyingCommandUnrecognized:
            self.informationLabel?.text = "コマンドを認識できません"
        case .SpeakingWikipediaContent:
            self.informationLabel?.text = "Wikipedia"
        case .Terminating:
            self.informationLabel?.text = "終了処理中です"
        case .Unauthorized:
            self.informationLabel?.text = "マイクを許可してください"
        }
    }

}

