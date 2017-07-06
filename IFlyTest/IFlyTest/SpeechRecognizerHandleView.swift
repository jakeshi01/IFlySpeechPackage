//
//  SpeechRecognizerHandleView.swift
//  IFlyTest
//
//  Created by 石 苏杰 on 2017/7/2.
//  Copyright © 2017年 Jake. All rights reserved.
//

import Foundation
import UIKit

protocol SpeechRecognizeAction {

    var finishAction: (() -> Void)? { set get }
    var isCancelHidden: Bool { set get }
    
    func beginSpeechAction()
    func speechAnimation(with volume: Int32)
    func cancelSpeechAction()
    func resumeSpeechAction()
    func endSpeechAction()
    func setRecognizeResult(_ result: String?)
    func showProgressHud()
    func dismissProgressHud()
    func showAnimation()
    func dismissAnimation()
}

class SpeechRecognizerHandleView: UIView, SpeechRecognizeAction {

    var finishAction: (() -> Void)?
    fileprivate var willCancel: Bool = false
    var isCancelHidden: Bool = false
    
    lazy fileprivate var stateImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.image = #imageLiteral(resourceName: "speech_1")
        return imageView
    }()
    
    lazy fileprivate var resultLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center
        label.textColor = UIColor.red
        return label
    }()
    
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
        
        let width = bounds.width
        let height = bounds.height
    
        resultLabel.center = CGPoint(x: width / 2, y: height / 2)
        resultLabel.frame.origin.x = 20
        resultLabel.frame.size.width = width - 40
        stateImageView.frame = CGRect(x: (width - 185) / 2, y: (height - 185) / 2, width: 185, height: 185)
    }
    
}

private extension SpeechRecognizerHandleView {
    
    func initialization() {
        resultLabel.isHidden = true
        stateImageView.isHidden = true
        
        addSubview(resultLabel)
        addSubview(stateImageView)
    }
    
    func reset() {
        resultLabel.isHidden = true
        stateImageView.isHidden = true
        resultLabel.text = ""
        willCancel = false
    }
    
    func showResultAnimated() {
        resultLabel.isHidden = false
        resultLabel.alpha = 0.3
        UIView.animate(withDuration: 0.3) {
            self.resultLabel.alpha = 1
        }
    }
}

extension SpeechRecognizerHandleView {
    
    func beginSpeechAction() {
        resultLabel.text = ""
        resultLabel.isHidden = true
        stateImageView.isHidden = false
    }
    
    func speechAnimation(with volume: Int32) {
        guard !willCancel else { return }
        let rate = Double(volume) / 30.0
        let base = 5 / 30.0

        if rate <= base {
            stateImageView.image = #imageLiteral(resourceName: "speech_1")
        } else if rate <= base * 2 {
            stateImageView.image = #imageLiteral(resourceName: "speech_2")
        } else if rate <= base * 3 {
            stateImageView.image = #imageLiteral(resourceName: "speech_3")
        } else if rate <= base * 4 {
            stateImageView.image = #imageLiteral(resourceName: "speech_4")
        } else if rate <= base * 5 {
            stateImageView.image = #imageLiteral(resourceName: "speech_5")
        } else if rate <= base * 7 {
            stateImageView.image = #imageLiteral(resourceName: "speech_6")
        } else {
            stateImageView.image = #imageLiteral(resourceName: "speech_7")
        }
    }
    
    func cancelSpeechAction() {
        stateImageView.image = #imageLiteral(resourceName: "cancel_speech")
        willCancel = true
    }
    
    func resumeSpeechAction() {
        willCancel = false
    }
    
    func endSpeechAction() {
        stateImageView.isHidden = true
        stateImageView.image = #imageLiteral(resourceName: "speech_1")
    }
    
    func setRecognizeResult(_ result: String?) {
        guard !willCancel else { return }
        delay(0.5) {
            self.finishAction?()
            self.dismissProgressHud()
            self.resultLabel.text = result
            self.resultLabel.sizeToFit()
            self.resultLabel.isHidden = false
//            self.showResultAnimated()
        }
    }
    
    func showProgressHud() {
        guard !willCancel else { return }
        showLoadingHud()
    }
    
    func dismissProgressHud() {
        hideHUD()
    }
    
    func dismissAnimation() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { _ in
            self.isHidden = self.isCancelHidden ? false : true
            self.alpha = self.isCancelHidden ? 1 : 0
            guard !self.isCancelHidden else { return }
            self.reset()
        }
    }

    func showAnimation() {
        alpha = 0
        isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0.9
        })
    }

}
