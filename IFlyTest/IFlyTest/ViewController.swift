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
    
    fileprivate var recognizeResult: String = ""
    fileprivate let speechRecognizer: SpeechRecognizer = SpeechRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        speechRecognizer.delegate = self
    }

    @IBAction func beginBtnClick(_ sender: UIButton) {

        speechRecognizer.startListening()
    }

    @IBAction func stopBtnClick(_ sender: UIButton) {

        speechRecognizer.stopListening()
    }
}

extension ViewController: SpeechRecognizerDelegate {
    
    func onError(errorCode: IFlySpeechError) {
        print("errorCode = \(errorCode.errorCode)")
        if errorCode.errorCode == SpeechError.successCode.rawValue {
            
        } else if errorCode.errorCode == SpeechError.networkDisableCode.rawValue {
            
        } else if  errorCode.errorCode == SpeechError.recordDisabelCode.rawValue {
            
        } else{
            
        }
    }
    
    func onResults(_ results: [Any]?, isLast: Bool) {
        
        var resultStr = ""
        guard let dic = results?.first as? Dictionary<String, Any> else{
            print("未能识别")
            return
        }
        
        dic.keys.forEach { key in
            resultStr += key
        }
        
        recognizeResult = textField.text! + resultStr
        
        let resultJson = SpeechRecognizerConfig.serializeSpeechRecognizeResult(from: resultStr)
        
        textField.text = textField.text! + resultJson!
        
        if isLast {
            print("听写结果(json)：\(recognizeResult)")
        }
    }

    func onEndOfSpeech() {
        print("识别中")
    }
    
}
