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
    fileprivate var isCanceled: Bool = false
    
    var recognizerBar: SpeechRecognizerControl? {
        didSet{
            recognizerBar?.delegate = self
        }
    }
    var handleView: SpeechRecognizeAction? {
        didSet{
            handleView?.finishAction = { [weak self] in
                self?.recognizerBar?.speechBtn.isUserInteractionEnabled = true
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
        speechRecognizer.startListening()
        cancel(finishTask)
        handleView?.isCancelHidden = true
        handleView?.showAnimation()
        handleView?.beginSpeechAction()
    }
    
    func willCancelSpeech() {
        handleView?.cancelSpeechAction()
    }
    
    func resumeSpeech() {
        handleView?.resumeSpeechAction()
    }
    
    func speechEnd() {
        handleView?.endSpeechAction()
        speechRecognizer.stopListening()
    }
    
    func speechCanceled() {
        isCanceled = true
        handleView?.dismissAnimation()
        speechRecognizer.cancelSpeech()
        handleView?.endSpeechAction()
    }
    
}

extension SpeechRecognizerAdapter: SpeechRecognizerDelegate {
    
    func onError(errorCode: IFlySpeechError) {
        handleView?.isCancelHidden = false
        finishTask = delay(1.0, task: { [weak self] in
            self?.handleView?.dismissAnimation()
        })
        print("errorCode = \(errorCode.errorDesc)")
        if errorCode.errorCode == SpeechError.successCode.rawValue {
            //此处用于解决讯飞第一次短暂识别（单击，无语音）无数据（错误码应该为10118时）实际返回errorCode = 0的问题
            guard recognizeResult.characters.count == 0 else {
                recognizeResult = ""
                return
            }
            handleView?.setRecognizeResult("未识别到语音")
            recognizeResult = ""
        } else if errorCode.errorCode == SpeechError.networkDisableCode.rawValue {
            //没有网络
        } else if errorCode.errorCode == SpeechError.recordDisabelCode.rawValue {
            //录音初始化失败
        } else{
            handleView?.setRecognizeResult("未识别到语音")
        }
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
        }
    }
    
    func onEndOfSpeech() {
        print("识别中")
        speechEnd()
        guard !isCanceled else { return }
        handleView?.showProgressHud()
        //识别期间禁止再次点击语音
        recognizerBar?.speechBtn.isUserInteractionEnabled = false
    }
    
    func onCancel() {
        print("取消识别")
    }
    
    func onVolumeChanged(volumeValue value: Int32) {
        handleView?.speechAnimation(with: value)
    }
    
}
