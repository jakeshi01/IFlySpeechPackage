//
//  UIView+Hub.swift
//  IFlyTest
//
//  Created by Jake on 2017/7/3.
//  Copyright © 2017年 Jake. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

extension UIImageView {
    
    func loadGif(_ bundleName: String) {
        
        guard let path = Bundle.main.path(forResource: bundleName, ofType: "bundle") else { return }
        var images = [UIImage]()
        if let arrays = try? FileManager.default.contentsOfDirectory(atPath: path) {
            for name in arrays {
                if let image = UIImage(named: "\(bundleName).bundle" + "/\(name)") {
                    images.append(image)
                }
            }
        }
        self.animationImages = images
        self.startAnimating()
    }
    
}

extension UIView {
    
    func showLoadingHud() {
        let hud = MBProgressHUD(view: self)
        hud?.mode = .customView
        hud?.color = UIColor.clear
        hud?.labelText = "正在识别语音"
        
        let loadingImageView = UIImageView.init(image: UIImage(named: "preloader.bundle/Preloader_00000@2x"))
        
        loadingImageView.loadGif("preloader")
        
        hud?.customView = loadingImageView
        addSubview(hud!)
        hud?.show(true)
    }
    
    func hideHUD(_ animated: Bool = true) {
        MBProgressHUD.hide(for: self, animated: animated)
    }
}
