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
        DispatchQueue.global().async {
            var images = [UIImage]()
            if let arrays = try? FileManager.default.contentsOfDirectory(atPath: path) {
                for name in arrays {
                    if let image = UIImage(named: "\(bundleName).bundle" + "/\(name)") {
                        images.append(image)
                    }
                }
            }
            DispatchQueue.main.async {
                self.animationImages = images
                self.startAnimating()
            }

        }
        
    }
    
}

extension UIView {
    
    func showLoadingHud() {
        let hud = MBProgressHUD(view: self)
        hud?.mode = .customView
        hud?.color = UIColor.clear
        hud?.labelText = "正在识别语音..."
        hud?.labelColor = UIColor.lightGray
        
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        customView.backgroundColor = UIColor.clear
        let loadingImageView = UIImageView.init(image: UIImage(named: "preloader.bundle/Preloader_00000@2x"))
        loadingImageView.center = customView.center
        loadingImageView.loadGif("preloader")
        customView.addSubview(loadingImageView)
        
        hud?.customView = customView
        addSubview(hud!)
        hud?.show(true)
    }
    
    func hideHUD() {
        MBProgressHUD.hide(for: self, animated: false)
    }
}
