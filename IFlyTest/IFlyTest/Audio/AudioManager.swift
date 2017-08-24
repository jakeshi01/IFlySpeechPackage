//
//  AudioManager.swift
//  IFlyTest
//
//  Created by Jake on 2017/8/15.
//  Copyright © 2017年 Jake. All rights reserved.
//

import Foundation
import AVFoundation

fileprivate struct AudioConfig {
    
    fileprivate let recorderSetting: Dictionary = [
        AVFormatIDKey: NSNumber(value: kAudioFormatLinearPCM),
        AVSampleRateKey: NSNumber(value: 11025.0),
        AVNumberOfChannelsKey: NSNumber(value: 2),
        AVLinearPCMBitDepthKey: NSNumber(value: 16),
        AVEncoderAudioQualityKey: NSNumber(value: AVAudioQuality.min.rawValue)
    ]

    fileprivate var cacheSourceFilePath: String {
        return NSTemporaryDirectory().appending("/livelesson.caf")
    }
    
}

@objc enum AudioPlayStatus: Int {
    case loading = 0
    case success
    case fail
}

@objc protocol AudioManagerDelegate {
    @objc optional func onVolumeChanged(_ value: Double)
    @objc optional func onLoading(_ success: AudioPlayStatus)
}

class AudioManager: NSObject {
    
    var delegate: AudioManagerDelegate?
    var maxRecordTime: TimeInterval = 60.0     //秒级
    var isMeteringEnabled: Bool = false
    
    fileprivate var timer: Timer?
    fileprivate var isEncodingSuccess: Bool = false
    fileprivate lazy var player: AVPlayer = AVPlayer()
    fileprivate lazy var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    fileprivate lazy var audioEncoding: AudioEncoding = AudioEncoding()
    fileprivate lazy var audioConfig: AudioConfig = AudioConfig()
    fileprivate lazy var fileManager: FileManager = FileManager.default
    
    fileprivate lazy var audioRecorder: AVAudioRecorder? = { [unowned self] in
        guard let cacheUrl = URL(string: self.audioConfig.cacheSourceFilePath) else {
            return nil
        }
        let audioRecorder = try? AVAudioRecorder(url: cacheUrl, settings: self.audioConfig.recorderSetting)
        guard let recorder = audioRecorder else {
            return nil
        }
        return recorder
    }()
    
    fileprivate var isStopPlay: Bool = false {
        didSet{
            guard isStopPlay , oldValue != isStopPlay else {
                return
            }
            player.currentItem?.removeObserver(self, forKeyPath: "status")
        }
    }
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(AudioManager.playerDidFinished), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
        NotificationCenter.default.removeObserver(self)
    }
}

private extension AudioManager {

    func deletSourceFile() {
        guard fileManager.fileExists(atPath: audioConfig.cacheSourceFilePath) else { return }
        try? fileManager.removeItem(atPath: audioConfig.cacheSourceFilePath)
    }
    
    func audioVolumeChanged() {
        guard let recorder = audioRecorder else {
            return
        }
        if recorder.currentTime > maxRecordTime {
            stopRecord()
            return
        }
        recorder.updateMeters()
        let value: Double = Double(recorder.averagePower(forChannel: 0))
        let volume: Double = pow(10.0, 0.05 * value)
        delegate?.onVolumeChanged?(volume)
    }
    
    func addPlayerItemObserver() {
        player.currentItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
    }
    
}

extension AudioManager {
    
    @discardableResult
    func startRecord() -> Bool {
        guard let recorder = audioRecorder else {
            return  false
        }
        if recorder.isRecording {
            cancelRecord()
        }
        deletSourceFile()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setActive(true)
        } catch {
            return false
        }
        recorder.isMeteringEnabled = isMeteringEnabled
        if isMeteringEnabled {
            timer = Timer.every(0.1, target: self, { [weak self] _ in
                self?.audioVolumeChanged()
            })
        }
        isEncodingSuccess = false
        return recorder.prepareToRecord() && recorder.record()
    }
    
    func stopRecord() {
        guard let recorder = audioRecorder else { return }
        if recorder.delegate == nil {
            recorder.delegate = self
        }
        recorder.stop()
        audioEncoding.sourceFilePath = audioConfig.cacheSourceFilePath
        isEncodingSuccess = audioEncoding.encodingPCMToMP3()
    }
    
    func cancelRecord() {
        timer?.invalidate()
        timer = nil
        audioRecorder?.delegate = nil
        audioRecorder?.stop()
        isEncodingSuccess = false
    }
    
    @discardableResult
    func playAudio(with path: String?) -> Bool {
        stopPlayAudio()
        guard let playPath = path else {
            return false
        }
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession.setActive(true)
        } catch {
            return false
        }
        let playUrl: URL? = playPath.hasPrefix("http") ? URL(string: playPath) : URL.init(fileURLWithPath: playPath)
        guard let url = playUrl else {
            return false
        }
        let playItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playItem)
        addPlayerItemObserver()
        isStopPlay = false
        player.play()
        return true
    }
    
    func stopPlayAudio() {
        isStopPlay = true
        player.pause()
    }
    
    func getMP3FilePath() -> String? {
        return isEncodingSuccess ? audioEncoding.ouputFilePath : nil
    }
}

extension AudioManager: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        timer?.invalidate()
        timer = nil
    }
}

extension AudioManager {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let path = keyPath, path == "status" else {
            return
        }
        delegate?.onLoading?(.loading)
        switch player.status {
        case .unknown:
            delegate?.onLoading?(.loading)
        case .readyToPlay:
            delegate?.onLoading?(.success)
        case .failed:
            delegate?.onLoading?(.fail)
        }
        
    }
    
    @objc func playerDidFinished() {
        isStopPlay = true
    }
}

