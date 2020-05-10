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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


@objc class CanvasMaskViewDelegate:NSObject, CALayerDelegate {
    var maskView:CanvasMaskView?
    static func mask(_ mask: CanvasMaskView) -> CanvasMaskViewDelegate {
        let d = CanvasMaskViewDelegate.init()
        d.maskView = mask
        return d
    }
    func draw(_ layer: CALayer, in ctx: CGContext) {
        var d:CGRect = (maskView?.bounds)!
        var transform:CGAffineTransform = CGAffineTransform.identity
        let isErase:Bool = maskView?._toolType == .eraser
        
        if maskView?.image != nil {
            transform = transform.scaledBy(x: 1.0, y: -1.0)
            transform = transform.translatedBy(x: 0.0, y: -(maskView?.bounds.size.height)!);
            ctx.concatenate(transform)
            d = (maskView?.bounds)!.applying(transform);
            if(isErase)
            {
                ctx.beginTransparencyLayer(auxiliaryInfo: nil)
                
            }
            ctx.draw((maskView?.image?.cgImage)!, in: d)

        }
        
        d = (maskView?.bounds)!
        ctx.concatenate(transform)
        maskView?.tool?.draw(d, context: ctx)
        
        if(isErase && maskView?.image != nil)
        {
            ctx.endTransparencyLayer()
        }
        ctx.setBlendMode(.sourceOut)
        ctx.setFillColor(UIColor.black.cgColor)
        ctx.fill(d)
//        
//        print("draw layer mask delegate 1")
//        print(maskView?.tool! as Any)
//        print((maskView?.bounds)!)
    }

}


@objc class CanvasMaskView: UIView {
  
    // Undo
    var canUndo:Bool { return paths?.count > 0 }
    var undoSteps:Int { return (buffer?.count)! }
    var canRedo:Bool { return buffer?.count > 0 }
    
    var transformOption:CGAffineTransform = CGAffineTransform.identity
    // Tool & Line
    var lineOpacity: CGFloat = 1
    var lineFeather: CGFloat = 0
    var lineScale: CGFloat = 0.2
    var image:UIImage?
    var useStylus: Bool = false
    var isErasing: Bool = false
    var applyPressure: Bool = true
    var fingerErases: Bool = false
    var defaultLineWidth: CGFloat = 6
    var color:UIColor? {
        get { return tool?.color }
        set(newColor) { tool?.color = newColor }
    }
    
    fileprivate let minLineWidth: CGFloat = 1
    fileprivate let forceSensitivity: CGFloat = 4.0
    fileprivate let tiltThreshold = π3/6  // 30º
    fileprivate var buffer:NSMutableArray?
    fileprivate var paths:NSMutableArray?
    fileprivate var _tool:SketchTool?
    fileprivate var pointPreviousLast:CGPoint = CGPoint.zero
    fileprivate var pointPrevious:CGPoint = CGPoint.zero
    fileprivate var pointCurrent:CGPoint = CGPoint.zero
    fileprivate var _toolType:SketchToolType = SketchToolType.brush
    var toolType:Int {
        get {
            switch _toolType {
                case .brush: return 1
                case .pen: return 1
                case .eraser: return 0
            }
        }
        set(value)
        {
            let _oldType:SketchToolType = _toolType
            switch value
            {
                case 0: _toolType = .pen
                case 1: _toolType = .eraser
                case 2: _toolType = .brush
                default: _toolType = .pen
            }
            
            if(_oldType != _toolType)
            {
                _tool = SketchTool.tool(_toolType)
            }
            if(_toolType == .eraser)
            {
                self.tool?.color = UIColor.clear
            }
            else
            {
                self.tool?.color = UIColor.white
            }
        }
    }
    
    var tool: SketchTool? {
        get { if (_tool == nil) { _tool = SketchTool.tool(_toolType) }; return _tool }
        set(value) { _tool = value }
    }
    // Blocks
    var started: ((CanvasMaskView?) -> Void)?
    var changed: ((CanvasMaskView?) -> Void)?
    var ended: ((CanvasMaskView?) -> Void)?
    var updated: ((UIImage?, String?, CanvasMaskView?) -> Void)?
    var endedTool: ((SketchTool?, CanvasMaskView?) -> Void)?
    var cancelled: ((CanvasMaskView?) -> Void)?
    var filled: ((CanvasMaskView?) -> Void)?
    var cleared: ((CanvasMaskView?) -> Void)?
    var debug: ((UIImage?, NSString?, CanvasMaskView?) -> Void)?
    var changedBrush: ((CanvasMaskView?) -> Void)?
    var didUndo:((CanvasMaskView?) -> Void)?
    var didRedo:((CanvasMaskView?) -> Void)?
    
    // Parameters
    var sketchChanged: ((UIImage?, CanvasMaskView?) -> Void)?
    var sketchEnded: ((UIImage?, CanvasMaskView?) -> Void)?
    var sketchCancelled: ((UIImage?, CanvasMaskView?) -> Void)?
    var sketchMaskFilled: ((UIImage?, CanvasMaskView?) -> Void)?
    var sketchMaskCleared: ((UIImage?, CanvasMaskView?) -> Void)?
    var sketchImageDebug: ((UIImage?, NSString?, CanvasMaskView?) -> Void)?
    var sketchBrushChanged: ((CanvasMaskView?) -> Void)?
    var sketchCleared: ((CanvasMaskView?) -> Void)?
    
    var drawingImage: UIImage?
    fileprivate var maskLayerDelegate:CanvasMaskViewDelegate?
    var maskLayer: CALayer?
    var backgroundLayer: CALayer?
    var foregroundLayer: CALayer?
    var layerMaskImage: UIImage? {
        get {
            UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0);
            let ctx = UIGraphicsGetCurrentContext()
            maskLayer?.render(in: ctx!)
            let img = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return img
        }
        set(img)
        {
            UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0);
            let ctx = UIGraphicsGetCurrentContext()
            maskLayer?.render(in: ctx!)
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
    }
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
            if maskLayer == nil {
                if maskLayerDelegate == nil {
                    maskLayerDelegate = CanvasMaskViewDelegate.mask(self)
                }
                maskLayer = CALayer()
                maskLayer?.bounds = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
                maskLayer?.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)

            }
            maskLayer!.contents = maskImageStore?.cgImage
            maskLayer?.delegate = maskLayerDelegate as CALayerDelegate?
            if self.foregroundLayer != nil && self.foregroundLayer?.mask == nil { foregroundLayer?.mask = maskLayer }
            setNeedsDisplay()
        }
    }
    fileprivate var foregroundImageStore: UIImage?
    var foregroundImage: UIImage? {
        get { return foregroundImageStore }
        set(newForegroundImage)
        {
            foregroundImageStore = newForegroundImage
            if foregroundLayer == nil {
                foregroundLayer = CALayer()
                foregroundLayer?.bounds = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
                foregroundLayer?.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)

                if maskLayer != nil { foregroundLayer?.mask = maskLayer }
                if self.backgroundLayer != nil { self.layer.insertSublayer(foregroundLayer!, above: backgroundLayer) }
                else { self.layer.addSublayer(foregroundLayer!) }
                
                if maskLayer == nil
                {
                    UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
                    let ctx = UIGraphicsGetCurrentContext()
                    ctx?.setFillColor(UIColor.black.cgColor)
                    ctx?.fill(bounds)
                    maskImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    
                }
                
            }
            foregroundLayer!.contents = foregroundImageStore?.cgImage
            setNeedsDisplay()
        }
    }
    fileprivate var backgroundImageStore: UIImage?
    var backgroundImage: UIImage? {
        get { return backgroundImageStore }
        set(newImage)
        {
            backgroundImageStore = newImage
            if backgroundLayer == nil {
                backgroundLayer = CALayer()
                backgroundLayer?.bounds = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
                backgroundLayer?.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)

                if (self.foregroundLayer != nil) { self.layer.insertSublayer(backgroundLayer!, below: foregroundLayer) }
                else if self.maskLayer != nil { self.layer.insertSublayer(backgroundLayer!, below: maskLayer) }
                else { self.layer.addSublayer(backgroundLayer!) }
            }
            backgroundLayer!.contents = newImage?.cgImage
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
                maskLayer?.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
                maskLayer?.setNeedsDisplay()
            }
            if foregroundLayer != nil {
                foregroundLayer?.bounds = bounds
                foregroundLayer?.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
            }
            if backgroundLayer != nil {
                backgroundLayer?.bounds = bounds
                backgroundLayer?.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
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
        paths = NSMutableArray()
        buffer = NSMutableArray()
        backgroundColor = UIColor.clear
        _toolType = .brush
        isUserInteractionEnabled = true
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        pointPrevious = touch.previousLocation(in: self)
        pointCurrent = touch.location(in: self)
        self.tool?.line = line(touch)
        self.tool?.feather = lineFeather
        self.tool?.pointStart = pointCurrent
        paths?.add(self.tool!)
        started?(self)
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        cancelled?(self)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        finished()
        ended?(self)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        pointPreviousLast = pointPrevious
        pointPrevious = touch.previousLocation(in: self)
        pointCurrent = touch.location(in: self)
        self.tool?.line = line(touch)
        switch _toolType {
            
            case .brush:
//                maskLayer?.setNeedsDisplayInRect((self.tool?.addPoint(pointPreviousLast, previous: pointPrevious, current: pointCurrent))!)
                _ = self.tool?.addPoint(pointPreviousLast, previous: pointPrevious, current: pointCurrent)
                
                maskLayer?.setNeedsDisplayIn(bounds)
               

                break
                //            case .Pen: setNeedsDisplayInRect((self.tool?.addPoint(pointPreviousLast, previous: pointPrevious, current: pointCurrent))!)
                //            case .Eraser: self.tool?.movePoint(pointPrevious, to: pointCurrent); setNeedsDisplay()
                
            default:
//                maskLayer?.setNeedsDisplayInRect((self.tool?.addPoint(pointPreviousLast, previous: pointPrevious, current: pointCurrent))!)
       

                _ = self.tool?.addPoint(pointPreviousLast, previous: pointPrevious, current: pointCurrent)
                maskLayer?.setNeedsDisplayIn(bounds)
                break
        }
//        changed?(self)
    }
    func finished()
    {
        update(false)
        buffer?.removeAllObjects()
        endedTool?(tool,self)
        tool = nil
    }
    func update(_ redraw: Bool)
    {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        let ctx = UIGraphicsGetCurrentContext()
        if(redraw)
        {
            image = nil
            for pathTool in paths! { (pathTool as AnyObject).draw(bounds, context: ctx!) }
        }
        else
        {
            image?.draw(at: CGPoint.zero)
            tool?.draw(bounds, context: ctx!)
        }
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        updated?(image, "updated", self)
    }
    
    
    func undo()
    {
        if canUndo == false { return }
        buffer?.add((paths?.lastObject)!)
        paths?.removeLastObject()
        update(true)
        setNeedsDisplay()
        didUndo?(self)
    }
    func redo()
    {
        if canRedo == false { return }
        paths?.add((buffer?.lastObject)!)
        buffer?.removeLastObject()
        update(true)
        setNeedsDisplay()
        didRedo?(self)
    }
    
    func clear()
    {
        tool = nil
        buffer?.removeAllObjects()
        paths?.removeAllObjects()
        update(true)
        setNeedsDisplay()
        cleared?(self)
        maskLayer?.setNeedsDisplayIn(bounds)
    }
    
    func fill()
    {
        
    }
    func empty()
    {
        clear()
    }
    
    fileprivate func line(_ touch: UITouch) -> LineInfo {
        
        
        #if iOS91 && iOS91 > 0
        print("using ios91")
        if useStylus && touch.type == .Stylus { return touch.altitudeAngle < tiltThreshold ? lineForShading(touch) : lineForDrawing(touch); }
        #endif
        
        return LineInfo(width:max(minLineWidth, (transform.isIdentity ? max(touch.majorRadius / 2, minLineWidth) : max(touch.majorRadius / 2, minLineWidth)*(transform.a) * (max(0.001,lineScale/4) * 100))), opacity: lineOpacity)
    }
    fileprivate func lineForShading(_ touch: UITouch) -> LineInfo {
        let __prev = touch.previousLocation(in: self)
        let location = touch.location(in: self)
        var vector1 = CGVector(dx: location.x, dy: location.y)
        if #available(iOS 9.1, *) {
            vector1 = touch.azimuthUnitVector(in: self)
        }
        let vector2 = CGPoint(x: location.x - __prev.x, y: location.y - __prev.y)
        var angle = abs(atan2(vector2.y, vector2.x) - atan2(vector1.dy, vector1.dx))
        if angle > π2 { angle = 2 * π2 - angle }
        if angle > π2 / 2 { angle = π2 - angle }
        let minAngle: CGFloat = 0
        let maxAngle = π2 / 2
        let normalizedAngle = (angle - minAngle) / (maxAngle - minAngle)
        let maxLineWidth: CGFloat = 60
        var lineWidth = maxLineWidth * normalizedAngle
        let minAltitudeAngle: CGFloat = 0.25
        let maxAltitudeAngle = tiltThreshold
        if #available(iOS 9.1, *) {
            let altitudeAngle = touch.altitudeAngle < minAltitudeAngle ? minAltitudeAngle : touch.altitudeAngle
            let normalizedAltitude = 1 - ((altitudeAngle - minAltitudeAngle) / (maxAltitudeAngle - minAltitudeAngle))
            lineWidth = lineWidth * normalizedAltitude + minLineWidth
            return LineInfo(width:lineWidth * lineScale, opacity:(touch.force - 0) / (5 - 0))
        }
        return  LineInfo(width:lineWidth * lineScale, opacity:1)
    }
    fileprivate func lineForDrawing(_ touch: UITouch) -> LineInfo {
        if #available(iOS 9.1, *) {
            if touch.force > 0
            {
                return LineInfo(width:(touch.force * forceSensitivity), opacity: 1)
            }
        }
        return LineInfo(width:defaultLineWidth, opacity: 1)
    }
    
    
}
