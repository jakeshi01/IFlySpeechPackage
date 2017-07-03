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
    fileprivate var recognizeResult: String = ""
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
        showHandleView()
        speechRecognizer.startListening()
        handleView?.beginSpeech()
    }
    
    @objc func willCancelSpeech() {
        handleView?.cancelSpeech()
    }
    
    @objc func resumeSpeech() {
        handleView?.goOnSpeech()
    }
    
    @objc func speechEnd() {
        speechRecognizer.stopListening()
    }
    
    @objc func speechCanceled() {
        speechRecognizer.cancelSpeech()
        handleView?.endSpeech()
        handleViewDismissAnimation()
    }
    
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

extension SpeechRecognizerBar: SpeechRecognizerDelegate {
    
    func onError(errorCode: IFlySpeechError) {
        print("errorCode = \(errorCode.errorCode)")
        handleView?.dismissProgressHud()
        if errorCode.errorCode == SpeechError.successCode.rawValue {
            
        } else if errorCode.errorCode == SpeechError.networkDisableCode.rawValue {
            
        } else if  errorCode.errorCode == SpeechError.recordDisabelCode.rawValue {
            
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
        handleView?.showProgressHud()
    }
    
    func onCancel() {
        print("取消识别")
    }
    
    func onVolumeChanged(volumeValue value: Int32) {
        handleView?.speechAnimation(with: value)
    }
    
}
