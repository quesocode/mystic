//
//  CameraAlbum.swift
//  Mystic
//
//  Created by Travis A. Weerts on 4/11/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

import UIKit

@objc class CameraAlbum:UIButton {
  
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
        self.setImage(UIImage.init(named: "shape-cam-album"), for: UIControlState())
        self.setImage(UIImage.init(named: "shape-cam-album-highlighted"), for: .highlighted)
    }
}
