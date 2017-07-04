//
//  SpeechRecognizerAdapter.swift
//  IFlyTest
//
//  Created by Jake on 2017/7/4.
//  Copyright © 2017年 Jake. All rights reserved.
//

import Foundation
import UIKit

class SpeechRecognizerAdapter: NSObject {
    
    fileprivate let speechRecognizer: SpeechRecognizer = SpeechRecognizer()
    fileprivate var recognizeResult: String = ""
    fileprivate var finishTask: Task?
    
    var recognizerBar: SpeechRecognizerControl? {
        didSet{
            recognizerBar?.delegate = self
        }
    }
    var handleView: SpeechRecognizeAction? {
        didSet{
            handleView?.finishAction = { [weak self] in
                self?.recognizerBar?.speechBtn.isEnabled = true
            }
        }
    }
    
    override init() {
        super.init()
        
        speechRecognizer.delegate = self
    }
}

extension SpeechRecognizerAdapter: SpeechRecognizerControlDelegate {
    
    func beginSpeech() {
        cancel(finishTask)
        handleView?.showAnimation()
        speechRecognizer.startListening()
        handleView?.beginSpeechAction()
    }
    
    func willCancelSpeech() {
        handleView?.cancelSpeechAction()
    }
    
    func resumeSpeech() {
        handleView?.resumeSpeechAction()
    }
    
    func speechEnd() {
        speechRecognizer.stopListening()
        //识别期间禁止再次点击语音
        recognizerBar?.speechBtn.isEnabled = false
    }
    
    func speechCanceled() {
        speechRecognizer.cancelSpeech()
        handleView?.endSpeechAction()
        handleView?.dismissAnimation()
    }
    
}

extension SpeechRecognizerAdapter: SpeechRecognizerDelegate {
    
    func onError(errorCode: IFlySpeechError) {
        
        print("errorCode = \(errorCode.errorDesc)")
        if errorCode.errorCode == SpeechError.successCode.rawValue {
            //此处用于解决讯飞第一次短暂识别（单击，无语音）无数据（错误码应该为10118时）实际返回errorCode = 0的问题
            guard recognizeResult.characters.count == 0 else { return }
            handleView?.setRecognizeResult("未识别到语音")
            
        } else if errorCode.errorCode == SpeechError.networkDisableCode.rawValue {
            //没有网络
        } else if errorCode.errorCode == SpeechError.recordDisabelCode.rawValue {
            //录音初始化失败
        } else{
            handleView?.setRecognizeResult("未识别到语音")
        }
        
        finishTask = delay(1.0, task: { [weak self] in
            self?.handleView?.dismissAnimation()
        })
    }
    
    func onResults(_ results: [Any]?, isLast: Bool) {
        
        var resultStr = ""
        guard let dic = results?.first as? Dictionary<String, Any> else{
            handleView?.setRecognizeResult("未识别到语音")
            return
        }
        
        dic.keys.forEach { key in
            resultStr += key
        }
        
        if let resultJson = SpeechRecognizerConfig.serializeSpeechRecognizeResult(from: resultStr) {
            recognizeResult += resultJson
        }
        
        if isLast {
            handleView?.setRecognizeResult(recognizeResult)
            recognizeResult = ""
        }
    }
    
    func onEndOfSpeech() {
        print("识别中")
        handleView?.showProgressHud()
    }
    
    func onCancel() {
        print("取消识别")
    }
    
    func onVolumeChanged(volumeValue value: Int32) {
        handleView?.speechAnimation(with: value)
    }
    
}
