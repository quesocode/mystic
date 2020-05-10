//
//  Switcher.swift
//  SwitcherExample
//
//  Created by Khoi Nguyen Nguyen on 11/2/15.
//  Copyright © 2015 Khoi Nguyen Nguyen. All rights reserved.
//

import UIKit

@objc protocol SwitcherChangeValueDelegate {
    func switcherDidChangeValue(_ switcher:Switcher?, value:Bool)
}

@objc class Switcher: UIView {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var leftSpace: NSLayoutConstraint!
    
    var delegate: SwitcherChangeValueDelegate?
    var selectedColor: UIColor?
    var disabledColor: UIColor?

    var status:Bool = false
    
    fileprivate var originPosition:CGFloat = 0.0
    fileprivate var finalPosition:CGFloat = 0.0
    
    override func awakeFromNib() {
        setUpUI()
    }
    override init(frame: CGRect) {
        super.init(frame:frame)
        setUpUI()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpUI()
    }
    func setUpUI() {
        
//        button.setImage(UIImage(named: "Delete"), forState: UIControlState.Normal)
    }
    func setupView(){
        if(button == nil)
        {
            let bs:CGFloat = 3.0+2.0;
            let bh:CGFloat = self.bounds.size.height-CGFloat(bs*2.0)
            let btn = UIButton.init(frame: CGRect(x: self.status ? CGFloat(self.bounds.size.width - bh - bs) : bs,y: bs,width: bh, height: bh))
            btn.addTarget(self, action: #selector(Switcher.switcherButtonDidTouch(_:)), for: .touchUpInside)
            btn.backgroundColor = self.status ? self.selectedColor : self.disabledColor
            btn.setNeedsDisplay()
            self.addSubview(btn)
            button = btn
        }
        self.backgroundColor = UIColor.clear
        self.layer.borderWidth = 2
        self.layer.borderColor = self.status ? self.selectedColor?.cgColor : self.disabledColor?.cgColor
    }
    override func layoutSubviews() {

    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
        
        button.layer.cornerRadius = button.frame.height / 2
        originPosition = (self.frame.height - button.frame.height) / 2;
        finalPosition = self.frame.width - originPosition - self.button.frame.width;
        if(leftSpace != nil)
        {
            leftSpace.constant = originPosition
        }
    }
    func toggle ()
    {
        status = !status;
        delegate?.switcherDidChangeValue(self, value:status)
        animationSwitcherButton(status)
    }
    func switcherButtonDidTouch(_ sender: AnyObject) {
        status = !status;
        animationSwitcherButton(status)
        delegate?.switcherDidChangeValue(self, value:status)
    }
    
    func animationSwitcherButton(_ status:Bool) {
        let bs:CGFloat = 3.0+2.0;
        let bh:CGFloat = self.bounds.size.height-CGFloat(bs*2.0)
        
        if status {
            
            // Clear Shadow
//            self.button.layer.shadowOffset = CGSizeZero
//            self.button.layer.shadowOpacity = 0
//            self.button.layer.shadowRadius = self.button.frame.height / 2
            self.button.layer.cornerRadius = self.button.frame.height / 2
//            self.button.layer.shadowPath = nil
            
            // Rotate animation
            let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotateAnimation.fromValue = 0.0
            rotateAnimation.toValue = CGFloat(Double.pi)
            rotateAnimation.duration = 0.35
            rotateAnimation.isCumulative = false;
            self.button.layer.add(rotateAnimation, forKey: "rotate")
            
            
            let color:CABasicAnimation = CABasicAnimation(keyPath: "borderColor")
            color.fromValue=self.layer.borderColor
            color.toValue=self.selectedColor?.cgColor
            color.isCumulative = false;
            color.duration = 0.35
            self.layer.borderColor = self.selectedColor?.cgColor
            
            
//            let both:CAAnimationGroup = CAAnimationGroup()
//            both.duration = 0.35
//            both.animations = [color,rotateAnimation]
//            both.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            
            self.layer.add(color, forKey: "bordercolor1")
            self.button.layer.add(rotateAnimation, forKey: "rotateAnimation1")

            
            
            UIView.animate(withDuration: 0.35, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
//                self.button.setImage(UIImage(named: "Delete"), forState: UIControlState.Normal)
                if(self.leftSpace != nil)
                {
                    self.leftSpace.constant = self.originPosition
                }
                else
                {
                    self.button.frame = CGRectX(self.button.frame, CGFloat(self.bounds.size.width - bh - bs));
                }
//                self.layer.borderColor = self.selectedColor?.CGColor
                self.layoutIfNeeded()
                self.button.backgroundColor = self.selectedColor
                }, completion: { (finish:Bool) -> Void in

            })

        } else {
            
            // Rotate animation
            let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotateAnimation.fromValue = CGFloat(Double.pi)
            rotateAnimation.toValue = 0.0
            rotateAnimation.duration = 0.35
            rotateAnimation.isCumulative = false;

            let color:CABasicAnimation = CABasicAnimation(keyPath: "borderColor")
            color.fromValue=self.layer.borderColor
            color.toValue=self.disabledColor?.cgColor
            color.duration = 0.35
            color.isCumulative = false;
            self.layer.borderColor = self.disabledColor?.cgColor
            
     
//            let both:CAAnimationGroup = CAAnimationGroup()
//            both.duration = 0.35
//            both.animations = [color,rotateAnimation]
//            both.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//
//            self.button.layer.addAnimation(both, forKey: "rotation and bordercolor")
            self.layer.add(color, forKey: "bordercolor2")
            self.button.layer.add(rotateAnimation, forKey: "rotateAnimation2")
            
            
            
            // Translation animation
            UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
//                self.button.setImage(UIImage(named: "Checkmark"), forState: UIControlState.Normal)
                if(self.leftSpace != nil)
                {
                    self.leftSpace.constant = self.finalPosition
                }
                else
                {
                    self.button.frame = CGRectX(self.button.frame, CGFloat(bs));
                }
//                self.layer.borderColor = self.disabledColor?.CGColor
                self.layoutIfNeeded()
                self.button.backgroundColor = self.disabledColor
                }, completion: { (finish:Bool) -> Void in
//                    self.button.layer.shadowOffset = CGSizeMake(0, 0.2)
//                    self.button.layer.shadowOpacity = 0.3
//                    self.button.layer.shadowRadius = 5.0
                    self.button.layer.cornerRadius = self.button.frame.height / 2
//                    self.button.layer.shadowPath = UIBezierPath(roundedRect: self.button.layer.bounds, cornerRadius: self.button.frame.height / 2).CGPath
            })

        }
    }
}
