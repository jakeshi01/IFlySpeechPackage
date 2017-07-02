//
//  SpeechRecognizerHandleView.swift
//  IFlyTest
//
//  Created by 石 苏杰 on 2017/7/2.
//  Copyright © 2017年 Jake. All rights reserved.
//

import Foundation
import UIKit

class SpeechRecognizerHandleView: UIView {
    
    lazy fileprivate var stateImageView: UIImageView = {
        
        let imageView = UIImageView(frame: CGRect.zero)
        
        return imageView
    }()
    
    lazy fileprivate var resultLabel: UILabel = {
        
        let label = UILabel(frame: CGRect.zero)
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15)
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
        
        resultLabel.center = center
        resultLabel.frame.origin.x = 20
        resultLabel.frame.size.width = width - 40
        
        stateImageView.frame = CGRect(x: (width - 185) / 2, y: (height - 185) / 2, width: 185, height: 185)
    }
    
}

private extension SpeechRecognizerHandleView {
    
    func initialization() {
        backgroundColor = UIColor.init(white: 1, alpha: 0.9)
        
        addSubview(resultLabel)
        addSubview(stateImageView)
    }
}

extension SpeechRecognizerHandleView {
    
    func speechAnimation() {
        
    }
    
    func cancelSpeech() {
        
    }
}
