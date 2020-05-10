//
//  CameraFlash.swift
//  Mystic
//
//  Created by Travis A. Weerts on 4/11/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

import UIKit

@objc class CameraFlash:UIButton {
    fileprivate var _flashMode: UIImagePickerControllerCameraFlashMode = .auto
    var flashMode: UIImagePickerControllerCameraFlashMode {
        get { return _flashMode }
        set (v)
        {
            _flashMode = v
            switch _flashMode {
            case .on:
                self.setImage(UIImage.init(named: "shape-cam-flash-on"), for: UIControlState())
                self.setImage(UIImage.init(named: "shape-cam-flash-on-highlighted"), for: .highlighted)
                break
            case .off:
                self.setImage(UIImage.init(named: "shape-cam-flash-off"), for: UIControlState())
                self.setImage(UIImage.init(named: "shape-cam-flash-off-highlighted"), for: .highlighted)
            default:
                self.setImage(UIImage.init(named: "shape-cam-flash-auto"), for: UIControlState())
                self.setImage(UIImage.init(named: "shape-cam-flash-auto-highlighted"), for: .highlighted)
                break
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        
        self.backgroundColor=UIColor.clear
        self.isOpaque=false
        self.adjustsImageWhenHighlighted=false
        self.adjustsImageWhenDisabled=true
        self.flashMode = .auto
        
    }
}
