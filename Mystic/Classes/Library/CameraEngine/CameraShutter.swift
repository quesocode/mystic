//
//  CameraShutter.swift
//  Mystic
//
//  Created by Travis A. Weerts on 4/11/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

import UIKit

@objc class CameraShutter:UIButton {
    
    fileprivate var circleView:UIView?
    fileprivate var borderView:UIView?
    override var isHighlighted: Bool
    {
        get { return super.isHighlighted }
        set (v) {
            let lv = super.isHighlighted
            super.isHighlighted = v;
            if v { self.circleView?.alpha = 0.5 }
            if lv && !v
            {
                self.circleView?.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                        self.circleView?.transform = CGAffineTransform.identity
                        self.circleView?.alpha=1.0
                    }, completion: { (f) in
                        self.circleView?.transform = CGAffineTransform.identity
                })
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
        
        self.layer.borderWidth=3.0
        self.layer.borderColor = UIColor.init(red: 237.0/255.0, green: 222.0/255.0, blue: 204.0/255.0, alpha: 1.0).cgColor
        self.layer.cornerRadius = self.frame.size.height*0.5
        self.clipsToBounds=true
        self.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        self.circleView = UIView.init(frame: self.bounds.insetBy(dx: 5, dy: 5))
        self.circleView?.isUserInteractionEnabled=false
        self.circleView?.backgroundColor = UIColor.init(red: 237.0/255.0, green: 222.0/255.0, blue: 204.0/255.0, alpha: 1.0)
        self.circleView?.layer.cornerRadius = (self.circleView?.frame.size.height)!*0.5
        self.circleView?.clipsToBounds=true
        self.addSubview(self.circleView!)
        
    }
    
}

@objc class CameraFocalPoint:UIView {
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
        UIColor.white.set()
        context?.fill(CGRect(x: 0, y: 0, width: rect.size.width/4.0, height: w))
        context?.fill(CGRect(x: rect.size.width - rect.size.width/4.0, y: 0, width: rect.size.width/4.0, height: w))
        context?.fill(CGRect(x: 0, y: rect.size.height - w, width: rect.size.width/4.0, height: w))
        context?.fill(CGRect(x: rect.size.width - rect.size.width/4.0, y: rect.size.height - w, width: rect.size.width/4.0, height: w))

        context?.fill(CGRect(x: 0, y: 0, width: w, height: rect.size.height/4.0))
        context?.fill(CGRect(x: rect.size.width - w, y: 0, width: w, height: rect.size.height/4.0))
        context?.fill(CGRect(x: 0, y: rect.size.height - rect.size.height/4.0, width: w, height: rect.size.height/4.0))
        context?.fill(CGRect(x: rect.size.width - w, y: rect.size.height - rect.size.height/4.0, width: w, height: rect.size.height/4.0))

        context?.setLineWidth(w)
        context?.strokeEllipse(in: CGRect(x: rect.size.width/2.0 - 10.0, y: rect.size.height/2.0 - 10.0, width: 20.0, height: 20.0))
        
        
    }
}
