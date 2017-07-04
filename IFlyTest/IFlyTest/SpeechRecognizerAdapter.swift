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
    var handleView: SpeechRecognizerHandleView? {
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

private extension SpeechRecognizerAdapter {
    
    func handleViewDismissAnimation() {
        UIView.animate(withDuration: 0.3, animations: {
            self.handleView?.alpha = 0
        }) { _ in
            self.handleView?.isHidden = true
        }
    }
    
    func showHandleView() {
        guard let handle = handleView, handle.isHidden else { return }
        handle.alpha = 0
        handle.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            handle.alpha = 0.9
        })
    }

}
extension SpeechRecognizerAdapter: SpeechRecognizerControlDelegate {
    
    func beginSpeech() {
        cancel(finishTask)
        showHandleView()
        speechRecognizer.startListening()
        handleView?.beginSpeech()
    }
    
    func willCancelSpeech() {
        handleView?.cancelSpeech()
    }
    
    func resumeSpeech() {
        handleView?.goOnSpeech()
    }
    
    func speechEnd() {
        speechRecognizer.stopListening()
        //识别期间禁止再次点击语音
        recognizerBar?.speechBtn.isEnabled = false
    }
    
    func speechCanceled() {
        speechRecognizer.cancelSpeech()
        handleView?.endSpeech()
        handleViewDismissAnimation()
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
            self?.handleViewDismissAnimation()
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
