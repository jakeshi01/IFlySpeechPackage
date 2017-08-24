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
        navigationController?.interactivePopGestureRecognizer?.delaysTouchesEnded = false
        navigationController?.interactivePopGestureRecognizer?.delaysTouchesBegan = false
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
        navigationController?.interactivePopGestureRecognizer?.delaysTouchesEnded = false
        navigationController?.interactivePopGestureRecognizer?.delaysTouchesBegan = false
    }
}



class AudioRecordViewController: UIViewController {
    
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var stopRecordBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var cacheSizeLabel: UILabel!
    fileprivate let audioManager: AudioManager = AudioManager()
    fileprivate var currentMP3Path: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        currentMP3Path = "http://mjcdn1-test.oss-cn-hangzhou.aliyuncs.com/public/upload/livelesson_review/2017/08/24/b9d644914197f21f826e4ab0ac8a93d7.mp3"
        audioManager.delegate = self
    }
    @IBAction func play(_ sender: Any) {
        
//        "http://m7.music.126.net/20170824142433/b7e742d6a05dc3b245c22427f4f83571/ymusic/11e4/26c9/025e/7c4090c1a0cf9d884385dac7453cdfc5.mp3"

        audioManager.playAudio(with: currentMP3Path)
    }

    @IBAction func stopPlay(_ sender: Any) {
        audioManager.stopPlayAudio()
    }

    @IBAction func stopRecord(_ sender: Any) {
        audioManager.stopRecord()
        currentMP3Path = audioManager.getMP3FilePath()
//        audioManager.cancelRecord()
    }
    
    @IBAction func beginRecord(_ sender: Any) {
        audioManager.isMeteringEnabled = true
        audioManager.startRecord()
    }
}

extension AudioRecordViewController: AudioManagerDelegate {
    
    func onVolumeChanged(_ value: Double) {
        print("\(value)")
    }
}
