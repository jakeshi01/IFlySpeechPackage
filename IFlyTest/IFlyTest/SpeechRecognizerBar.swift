//
//  SpeechRecognizerBar.swift
//  IFlyTest
//
//  Created by Jake on 2017/6/30.
//  Copyright © 2017年 Jake. All rights reserved.
//

import Foundation
import UIKit

class SpeechRecognizerBar: UIView {
    
    lazy fileprivate var speechBtn: UIButton = {
        
        let btn = UIButton(type: .custom)
        btn.setImage(#imageLiteral(resourceName: "speech"), for: .normal)
        btn.setTitle("按住  说出你想找什么", for: .normal)
        btn.setTitleColor(UIColor.blue, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btn.backgroundColor = UIColor.white

        return btn
        
    }()
    
    lazy fileprivate var seperateLine: UIView = {
        
        let line =  UIView(frame: CGRect.zero)
        line.backgroundColor = UIColor.red
        return line
        
    }()
    
    fileprivate let speechRecognizer: SpeechRecognizer = SpeechRecognizer()
    var handleView: SpeechRecognizerHandleView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialization()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialization()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        speechBtn.frame = CGRect(x: 50, y: 7.5, width: bounds.width - 100, height: bounds.height - 15)
        seperateLine.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 0.5)
        speechBtn.layer.cornerRadius = speechBtn.bounds.height / 2
    }
    
}

private extension SpeechRecognizerBar {
    
    func initialization() {
        speechBtn.addTarget(self, action: #selector(SpeechRecognizerBar.beginSpeech), for: .touchDown)
        speechBtn.addTarget(self, action: #selector(SpeechRecognizerBar.resumeSpeech), for: .touchDragEnter)
        speechBtn.addTarget(self, action: #selector(SpeechRecognizerBar.willCancelSpeech), for: .touchDragExit)
        speechBtn.addTarget(self, action: #selector(SpeechRecognizerBar.speechEnd), for: .touchUpInside)
        speechBtn.addTarget(self, action: #selector(SpeechRecognizerBar.speechCanceled), for: .touchUpOutside)
        
        addSubview(speechBtn)
        addSubview(seperateLine)
        backgroundColor = UIColor.lightGray
        
        speechRecognizer.delegate = self
    }
    
    @objc func beginSpeech() {
        print("开始")
        speechRecognizer.startListening()
    }
    
    @objc func willCancelSpeech() {
        print("手指移出")
    }
    
    @objc func resumeSpeech() {
        print("手指移入")
    }
    
    @objc func speechEnd() {
        print("结束")
        speechRecognizer.stopListening()
    }
    
    @objc func speechCanceled() {
        print("取消")
        speechRecognizer.stopListening()
    }
}

extension SpeechRecognizerBar: SpeechRecognizerDelegate {
    
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
        
//        recognizeResult = textField.text! + resultStr
        
        let resultJson = SpeechRecognizerConfig.serializeSpeechRecognizeResult(from: resultStr)
        
//        textField.text = textField.text! + resultJson!
        
        if isLast {
//            print("听写结果(json)：\(recognizeResult)")
        }
    }
    
    func onEndOfSpeech() {
        print("识别中")
    }
    
}
