/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit



@objc class CanvasMaskView: UIView {
  
    // Parameters
    var drawView:SketchView?
    
    var sketchChanged: ((UIImage?, CanvasMaskView?) -> Void)?
    var sketchEnded: ((UIImage?, CanvasMaskView?) -> Void)?
    var sketchCancelled: ((UIImage?, CanvasMaskView?) -> Void)?
    var sketchMaskFilled: ((UIImage?, CanvasMaskView?) -> Void)?
    var sketchMaskCleared: ((UIImage?, CanvasMaskView?) -> Void)?
    var sketchImageDebug: ((UIImage?, NSString?, CanvasMaskView?) -> Void)?
    var sketchBrushChanged: ((CanvasMaskView?) -> Void)?
    var sketchCleared: ((CanvasMaskView?) -> Void)?
    var color:UIColor? {
        get { return drawView?.color }
        set(v) { drawView?.color = v }
    }
    var drawingImage: UIImage?
    var image:UIImage? {
        get { return drawView?.image }
        set(img) { drawView?.image = img }
    }
    var lineScale: CGFloat {
        get { return (drawView?.lineScale)! }
        set(value) { drawView?.lineScale = value }
    }
    var lineFeather: CGFloat {
        get { return (drawView?.lineFeather)! }
        set(value) { drawView?.lineFeather = value }
    }
    var lineOpacity: CGFloat {
        get { return (drawView?.lineOpacity)! }
        set(value) { drawView?.lineOpacity = value }
    }
    var toolType:Int {
        get { return (drawView?.toolType)! }
        set(type) { drawView?.toolType = type }
    }
    var maskLayer: CALayer?
    var backgroundLayer: CALayer?
    var foregroundLayer: CALayer?
    var maskImageStore: UIImage?
    var maskImage: UIImage? {
        get { return maskImageStore }
        set(newMaskImage)
        {
            if(newMaskImage == nil && maskImageStore != nil)
            {
                maskImageStore = newMaskImage
                if(foregroundLayer != nil && foregroundLayer?.mask != nil) { foregroundLayer?.mask = nil }
                if maskLayer != nil { maskLayer = nil }
                return
            }
            maskImageStore = newMaskImage
//            if drawingImage==nil { drawingImage=newMaskImage }
            if maskLayer == nil {
                maskLayer = CALayer()
                maskLayer?.bounds = CGRectMake(0, 0, bounds.size.width, bounds.size.height)
                maskLayer?.frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height)
            }
            maskLayer!.contents = maskImageStore?.CGImage
            if self.foregroundLayer != nil && self.foregroundLayer?.mask == nil { foregroundLayer?.mask = maskLayer }
            setNeedsDisplay()
        }
    }
    private var foregroundImageStore: UIImage?
    var foregroundImage: UIImage? {
        get { return foregroundImageStore }
        set(newForegroundImage)
        {
            foregroundImageStore = newForegroundImage
            if foregroundLayer == nil {
                foregroundLayer = CALayer()
                foregroundLayer?.bounds = CGRectMake(0, 0, bounds.size.width, bounds.size.height)
                foregroundLayer?.frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height)

                if maskLayer != nil { foregroundLayer?.mask = maskLayer }
                if self.backgroundLayer != nil { self.layer.insertSublayer(foregroundLayer!, above: backgroundLayer) }
                else { self.layer.addSublayer(foregroundLayer!) }
            }
            foregroundLayer!.contents = foregroundImageStore?.CGImage
            setNeedsDisplay()
        }
    }
    private var backgroundImageStore: UIImage?
    var backgroundImage: UIImage? {
        get { return backgroundImageStore }
        set(newImage)
        {
            backgroundImageStore = newImage
            if backgroundLayer == nil {
                backgroundLayer = CALayer()
                backgroundLayer?.bounds = CGRectMake(0, 0, bounds.size.width, bounds.size.height)
                backgroundLayer?.frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height)

                if (self.foregroundLayer != nil) { self.layer.insertSublayer(backgroundLayer!, below: foregroundLayer) }
                else if self.maskLayer != nil { self.layer.insertSublayer(backgroundLayer!, below: maskLayer) }
                else { self.layer.addSublayer(backgroundLayer!) }
            }
            backgroundLayer!.contents = newImage?.CGImage
            setNeedsDisplay()
        }
    }
    override var frame:CGRect {
        get { return super.frame }
        set(newFrame)
        {
            super.frame = newFrame
            if maskLayer != nil {
                maskLayer?.bounds = bounds
                maskLayer?.frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height)
            }
            if foregroundLayer != nil {
                foregroundLayer?.bounds = bounds
                foregroundLayer?.frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height)
            }
            if backgroundLayer != nil {
                backgroundLayer?.bounds = bounds
                backgroundLayer?.frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height)
            }
            drawView?.bounds = bounds
            drawView?.setNeedsDisplay()
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
    
    private func setup() {
        userInteractionEnabled = true
        drawView = SketchView.init(frame: bounds)
        drawView?.alpha = 1.0
        drawView?.layer.borderColor = UIColor.greenColor().CGColor
        drawView?.layer.borderWidth = 10.0
        drawView?.userInteractionEnabled = true
        func ui(image:UIImage?, tag:String?, view: SketchView?) -> Void {
            if image == nil { return }
            sketchImageDebug?(image,tag,self)
            UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
            let cntx = UIGraphicsGetCurrentContext()
            image?.drawInRect(bounds)
            CGContextSetBlendMode(cntx, .SourceOut)
            UIColor.blackColor().setFill()
            CGContextFillRect(cntx, bounds)
            let newImg = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            if newImg != nil { maskImage = newImg; sketchImageDebug?(newImg,"updatedMask-" + tag!,self) }
            
        };
        drawView?.updated = ui
        addSubview(drawView!)
        drawView?.setNeedsDisplay()
    }
    func empty() {
        drawView?.empty()
    }
    func fill() {
        drawView?.fill()
    }
    
    
}
