//
//  ViewController.swift
//  IFlyTest
//
//  Created by Jake on 2017/6/28.
//  Copyright © 2017年 Jake. All rights reserved.
//

import UIKit

class RecognizerBarViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var recognizerBar: NormalSpeechRecognizerBar!
    @IBOutlet weak var speechHandleView: SpeechRecognizerHandleView!
    
    fileprivate let speechAdapter: SpeechRecognizerAdapter = SpeechRecognizerAdapter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        speechAdapter.recognizerBar = recognizerBar
        speechAdapter.handleView = speechHandleView

    }

}


class SpeechRecognizerViewController: UIViewController {
    
    @IBOutlet weak var tipsView: UIView!
    @IBOutlet weak var recognizerBar: AnimateSpeechRecognizerBar!
    @IBOutlet weak var speechHandleView: SpeechRecognizerHandleView!
    fileprivate let speechAdapter: SpeechRecognizerAdapter = SpeechRecognizerAdapter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        speechAdapter.recognizerBar = recognizerBar
        speechAdapter.handleView = speechHandleView
        
    }
}

