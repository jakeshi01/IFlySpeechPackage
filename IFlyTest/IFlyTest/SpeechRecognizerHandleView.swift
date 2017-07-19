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
    fileprivate var speechImages: [UIImage] = []
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
        loadGifImages()
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
    
    func loadGifImages() {
        guard let path = Bundle.main.path(forResource: "speech", ofType: "bundle") else { return }
        DispatchQueue.global().async {
            if let arrays = try? FileManager.default.contentsOfDirectory(atPath: path) {
                for name in arrays {
                    if let image = UIImage(named: "speech.bundle" + "/\(name)") {
                        self.speechImages.append(image)
                    }
                }
            }
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
            stateImageView.image = speechImages[0]
        } else if rate <= base * 2 {
            stateImageView.image = speechImages[1]
        } else if rate <= base * 3 {
            stateImageView.image = speechImages[2]
        } else if rate <= base * 4 {
            stateImageView.image = speechImages[3]
        } else if rate <= base * 5 {
            stateImageView.image = speechImages[4]
        } else if rate <= base * 7 {
            stateImageView.image = speechImages[5]
        } else if rate <= base * 8 {
            stateImageView.image = speechImages[6]
        } else {
            stateImageView.image = speechImages[7]
        }
    }
    
    func cancelSpeechAction() {
        stateImageView.image = speechImages.last
        willCancel = true
    }
    
    func resumeSpeechAction() {
        willCancel = false
    }
    
    func endSpeechAction() {
        stateImageView.isHidden = true
        stateImageView.image = speechImages.first
    }
    
    func setRecognizeResult(_ result: String?) {
        guard !willCancel else { return }
        delay(0.5) {
            guard self.stateImageView.isHidden else { return }
            self.finishAction?()
            self.dismissProgressHud()
            self.resultLabel.text = result
            self.resultLabel.sizeToFit()
            self.resultLabel.isHidden = false
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
