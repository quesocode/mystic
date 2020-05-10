//
//  CameraGrid.swift
//  Mystic
//
//  Created by Travis A. Weerts on 4/11/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

import UIKit

@objc class CameraGrid:UIButton {
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
        self.setImage(UIImage.init(named: "shape-cam-grid"), for: UIControlState())
        self.setImage(UIImage.init(named: "shape-cam-grid-highlighted"), for: .highlighted)
    }
}


@objc class CameraSteady:UIButton {
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
        self.setImage(UIImage.init(named: "shape-cam-steady"), for: UIControlState())
        self.setImage(UIImage.init(named: "shape-cam-steady-highlighted"), for: .highlighted)
    }
}

@objc class CameraGridView:UIView {
    required override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    func setup()
    {
        self.backgroundColor = UIColor.clear
        self.isOpaque=false
    }
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let w:CGFloat = 1.0
        UIColor.white.withAlphaComponent(0.4).setFill()
        context?.fill(CGRect(x: rect.size.width/3.0 - w/2.0, y: 0.0, width: w, height: rect.size.height))
        context?.fill(CGRect(x: (rect.size.width/3.0)*2.0 - w/2.0, y: 0.0, width: w, height: rect.size.height))
        context?.fill(CGRect(x: 0.0, y: rect.size.height/3.0 - w/2.0, width: rect.size.width, height: w))
        context?.fill(CGRect(x: 0.0, y: (rect.size.height/3.0)*2.0 - w/2.0, width: rect.size.width, height: w))
        
        
    }
}
