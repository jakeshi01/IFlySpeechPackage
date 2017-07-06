//
//  SpeechRecognizerBar.swift
//  IFlyTest
//
//  Created by Jake on 2017/6/30.
//  Copyright © 2017年 Jake. All rights reserved.
//

import Foundation
import UIKit

protocol SpeechRecognizerControl:class {
    
    var speechBtn: UIButton { get }
    var delegate: SpeechRecognizerControlDelegate? { set get }
}

@objc protocol SpeechRecognizerControlDelegate {
    
    @objc func beginSpeech()
    @objc func willCancelSpeech()
    @objc func resumeSpeech()
    @objc func speechEnd()
    @objc func speechCanceled()
}

class NormalSpeechRecognizerBar: UIView, SpeechRecognizerControl {
   
    lazy var speechBtn: UIButton = {
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
    
    var delegate: SpeechRecognizerControlDelegate?
    
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

private extension NormalSpeechRecognizerBar {
    
    func initialization() {
        speechBtn.addTarget(self, action: #selector(NormalSpeechRecognizerBar.beginSpeech), for: .touchDown)
        speechBtn.addTarget(self, action: #selector(NormalSpeechRecognizerBar.resumeSpeech), for: .touchDragEnter)
        speechBtn.addTarget(self, action: #selector(NormalSpeechRecognizerBar.willCancelSpeech), for: .touchDragExit)
        speechBtn.addTarget(self, action: #selector(NormalSpeechRecognizerBar.speechEnd), for: .touchUpInside)
        speechBtn.addTarget(self, action: #selector(NormalSpeechRecognizerBar.speechCanceled), for: .touchUpOutside)

        addSubview(speechBtn)
        addSubview(seperateLine)
        backgroundColor = UIColor.lightGray
    }
    
    @objc func beginSpeech() {
        delegate?.beginSpeech()
    }
    
    @objc func willCancelSpeech() {
        delegate?.willCancelSpeech()
    }
    
    @objc func resumeSpeech() {
        delegate?.resumeSpeech()
    }
    
    @objc func speechEnd() {
        delegate?.speechEnd()
    }
    
    @objc func speechCanceled() {
        delegate?.speechCanceled()
    }
}

class AnimateSpeechRecognizerBar: UIView, SpeechRecognizerControl {
    
    lazy var speechBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(#imageLiteral(resourceName: "mic_red"), for: .normal)
        btn.backgroundColor = UIColor.clear
        return btn
    }()
    
    lazy fileprivate var gifImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var delegate: SpeechRecognizerControlDelegate?
    
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
        
        speechBtn.frame = CGRect(x: (bounds.width - 80) / 2 , y: (bounds.height - 80) / 2, width: 80, height: 80)
        gifImageView.frame = bounds
    }

}

private extension AnimateSpeechRecognizerBar {
    
    func initialization() {
        speechBtn.addTarget(self, action: #selector(NormalSpeechRecognizerBar.beginSpeech), for: .touchDown)
        speechBtn.addTarget(self, action: #selector(NormalSpeechRecognizerBar.resumeSpeech), for: .touchDragEnter)
        speechBtn.addTarget(self, action: #selector(NormalSpeechRecognizerBar.willCancelSpeech), for: .touchDragExit)
        speechBtn.addTarget(self, action: #selector(NormalSpeechRecognizerBar.speechEnd), for: .touchUpInside)
        speechBtn.addTarget(self, action: #selector(NormalSpeechRecognizerBar.speechCanceled), for: .touchUpOutside)
        
        addSubview(gifImageView)
        addSubview(speechBtn)
        backgroundColor = UIColor.white
        
        loadGifImages()
    }
    
    func loadGifImages() {
    
        guard let path = Bundle.main.path(forResource: "wave", ofType: "bundle") else { return }
        DispatchQueue.global().async {
            var images = [UIImage]()
            if let arrays = try? FileManager.default.contentsOfDirectory(atPath: path) {
                for name in arrays {
                    if let image = UIImage(named: "wave.bundle" + "/\(name)") {
                        images.append(image)
                    }
                }
            }
       
            self.gifImageView.animationImages = images
            self.gifImageView.animationDuration = 3.0
        }
    }
    
    @objc func beginSpeech() {
        delegate?.beginSpeech()
        gifImageView.startAnimating()
    }
    
    @objc func willCancelSpeech() {
        delegate?.willCancelSpeech()
        gifImageView.stopAnimating()
    }
    
    @objc func resumeSpeech() {
        delegate?.resumeSpeech()
        gifImageView.loadGif("wave")
    }
    
    @objc func speechEnd() {
        delegate?.speechEnd()
        gifImageView.stopAnimating()
    }
    
    @objc func speechCanceled() {
        delegate?.speechCanceled()
        gifImageView.stopAnimating()
    }
}


