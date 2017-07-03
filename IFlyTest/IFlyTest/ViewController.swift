//
//  ViewController.swift
//  IFlyTest
//
//  Created by Jake on 2017/6/28.
//  Copyright © 2017年 Jake. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var speechBar: SpeechRecognizerBar!
    @IBOutlet weak var speechHandleView: SpeechRecognizerHandleView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        speechBar.handleView = speechHandleView

    }

}
