//
//  SpeechProtocol.swift
//  IFlyTest
//
//  Created by Jake on 2017/6/28.
//  Copyright © 2017年 Jake. All rights reserved.
//

import Foundation

struct SpeechRecognizerConfig {
    
    let domain = "iat"        //应用领域：听写
    let noDot = "0"           //非自动补全标点
    let rate_16K = "16000"     //采样率= 16k
    let timeOut = "15000"      //识别语音时长 = 15s
    let vad_bos = "3000"       //前段静默检测时长 = 3s
    let vad_eos = "3000"       //后段静默检测时长 = 3s
    
    static func serializeSpeechRecognizeResult(from JSONData:String?) -> String? {
        
        guard let json = JSONData?.data(using: .utf8) else {
            return nil
        }

        guard let param = try? JSONSerialization.jsonObject(with: json, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) as? [String: Any] else {
            return nil
        }
        guard let words: [Dictionary<String, Any>] = param?["ws"] as? Array else {
           return nil
        }
        var result = ""
        words.forEach { (element) in
            if let arr:[Dictionary<String, Any>] = element["cw"] as? Array {
                arr.forEach({ dic in
                    if let str = dic["w"] as? String {
                        result += str
                    }
                })
            }
        }
        return result
    }
}

enum SpeechError: Int32 {
    case successCode = 0
    case networkDisableCode = 20001
    case recordDisabelCode = 20009
}

protocol SpeechRecognizeable {
    
    associatedtype T
    
    var speechRecognizer: T { get }
    var delegate: SpeechRecognizerDelegate? { set get}
    
    func startListening()
    func stopListening()
}

@objc protocol SpeechRecognizerDelegate {
    
    @objc func onError(errorCode code: IFlySpeechError)
    @objc func onResults(_ results:Array<Any>?, isLast:Bool)
    
    @objc optional func onVolumeChanged(volumeValue value: Int32)
    @objc optional func onBeginOfSpeech()
    @objc optional func onEndOfSpeech()
    @objc optional func onCancel()
    
}

class SpeechRecognizer:NSObject, SpeechRecognizeable {

    typealias T = IFlySpeechRecognizer
    
    var speechRecognizer: T
    var delegate: SpeechRecognizerDelegate?
    let config: SpeechRecognizerConfig = SpeechRecognizerConfig()
    
    override init() {
        speechRecognizer = IFlySpeechRecognizer.sharedInstance()
        super.init()
        speechRecognizer.setParameter(config.domain, forKey: IFlySpeechConstant.ifly_DOMAIN())
        speechRecognizer.setParameter(config.noDot, forKey: IFlySpeechConstant.asr_PTT())
        speechRecognizer.setParameter(config.rate_16K, forKey: IFlySpeechConstant.sample_RATE())
        speechRecognizer.setParameter(config.timeOut, forKey: IFlySpeechConstant.speech_TIMEOUT())
        speechRecognizer.setParameter(config.vad_bos, forKey: IFlySpeechConstant.vad_BOS())
        speechRecognizer.setParameter(config.vad_eos, forKey: IFlySpeechConstant.vad_EOS())
        
        speechRecognizer.delegate = self
    }
}

extension SpeechRecognizer {
    
    func startListening() {
        speechRecognizer.startListening()
    }
    
    func stopListening() {
        speechRecognizer.stopListening()
    }
    
    func cancelSpeech() {
        speechRecognizer.cancel()
        speechRecognizer.stopListening()
    }
}

// IFlySpeechRecognizerDelegate
extension SpeechRecognizer: IFlySpeechRecognizerDelegate {
    
    func onError(_ errorCode: IFlySpeechError!) {
        delegate?.onError(errorCode: errorCode)
    }
    
    func onResults(_ results: [Any]!, isLast: Bool) {
        delegate?.onResults(results, isLast: isLast)
    }
    
    func onVolumeChanged(_ volume: Int32) {
        delegate?.onVolumeChanged?(volumeValue: volume)
    }
    
    func onBeginOfSpeech() {
        delegate?.onBeginOfSpeech?()
    }
    
    func onEndOfSpeech() {
        delegate?.onEndOfSpeech?()
    }
    
    func onCancel() {
        delegate?.onCancel?()
    }
}
