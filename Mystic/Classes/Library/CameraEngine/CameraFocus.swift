//
//  CameraFocus.swift
//  Mystic
//
//  Created by Travis A. Weerts on 4/11/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

import UIKit

@objc class CameraFocus:UIButton {
    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        
    }
}
