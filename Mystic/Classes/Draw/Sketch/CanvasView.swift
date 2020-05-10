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

let π2 = CGFloat(Double.pi)


func mPoint(_ p1: CGPoint, p2: CGPoint) -> CGPoint
{
    return CGPoint (x: (p1.x + p2.x) * 0.5,y: (p1.y + p2.y) * 0.5);
}


@objc class CanvasView: UIView {
  
    // Parameters
    var sketchChanged: ((UIImage?, CanvasView?) -> Void)?
    var sketchEnded: ((UIImage?, CanvasView?) -> Void)?
    var sketchCancelled: ((UIImage?, CanvasView?) -> Void)?
    var sketchMaskFilled: ((UIImage?, CanvasView?) -> Void)?
    var sketchMaskCleared: ((UIImage?, CanvasView?) -> Void)?
    var sketchImageDebug: ((UIImage?, NSString?, CanvasView?) -> Void)?
    var sketchBrushChanged: ((CanvasView?) -> Void)?
    var sketchCleared: ((CanvasView?) -> Void)?
    
    fileprivate var subpaths:NSMutableArray?
    fileprivate var touchesStore:NSMutableArray?
    fileprivate var numberOfDraws: Int = 0
    fileprivate var maxNumberOfDraws: Int = 20
    fileprivate var previousPoint: CGPoint = CGPoint.zero
    fileprivate var currentPoint: CGPoint = CGPoint.zero
    fileprivate var previousPreviousPoint: CGPoint = CGPoint.zero
    fileprivate let kPointMinDistance: CGFloat = 0.05
    fileprivate let kPointMinDistanceSquared: CGFloat = 0.05*0.05
    fileprivate let defaultLineWidth: CGFloat = 6
    fileprivate let forceSensitivity: CGFloat = 4.0
    fileprivate let tiltThreshold = π2/6  // 30º
    fileprivate var drawingStrokeImageStore:UIImage?
    fileprivate var drawingStrokeImage:UIImage? {
        get { return drawingStrokeImageStore }
        set (value) { drawingStrokeImageStore = value }
    }
    
    fileprivate var path: CGMutablePath = CGMutablePath()
    var drawingImage: UIImage?
    
    fileprivate var toolTypeValue: NSInteger = 0
    var toolType: NSInteger
        {
            get { return self.toolTypeValue }
            set(newToolType)
            {
                switch (newToolType)
                {
                    case 0:
                        drawColorValue = UIColor.black
                        isErasing = true
                    
                    case 1:
                        drawColorValue = UIColor.clear
                        isErasing = false
                    
                    default: break;
                }
                self.toolTypeValue = newToolType
            }
        }
    var useStylus: Bool = false
    var isErasing: Bool = false
    var applyPressure: Bool = true
    var fingerErases: Bool = false
    var color:UIColor { return UIColor.withAlphaComponent(drawColorValue)(1) }
    fileprivate var drawColorValue: UIColor = UIColor.black
    var drawColor: UIColor  {
        get {
            let c:UIColor  = drawColorValue 
            return UIColor.withAlphaComponent(c)(!isErasing ? lineOpacity : 1-lineOpacity)
        }
        set(newColor)
        {
            drawColorValue = UIColor.withAlphaComponent(newColor)(1)
        }
    }
    fileprivate var eraserColorValue: UIColor = UIColor.black
    var eraserColor:UIColor {
        get {
            let c:UIColor  = eraserColorValue 
            let c2 = UIColor.withAlphaComponent(c)(!isErasing ? lineOpacity : 1-lineOpacity)
            return c2
        }
        set(newColor)
        {
            eraserColorValue = UIColor.withAlphaComponent(newColor)(1)
        }
    }
    var pencilTexture: UIColor = UIColor(patternImage: UIImage(named: "PencilTexture")!)
    fileprivate let minLineWidth: CGFloat = 1
    var lineSmooth: CGFloat = 0.1
    func lineWidth(_ context: CGContext?, touch: UITouch) -> CGFloat {
        
        var alineWidth: CGFloat
        if #available(iOS 9.1, *) {

            if touch.type == .stylus && useStylus {
                if touch.altitudeAngle < tiltThreshold {
                    alineWidth = lineWidthForShading(context, touch: touch)
                } else {
                    alineWidth = lineWidthForDrawing(context, touch: touch)
                }
            } else {
                alineWidth = touch.majorRadius / 2
            }
        } else {
            alineWidth = touch.majorRadius / 2
        }
        alineWidth = transform.isIdentity ? max(alineWidth, minLineWidth) : max(alineWidth, minLineWidth)*(1/transform.a);
        alineWidth = max(minLineWidth, alineWidth * (max(0.001,lineScale/2) * 100))
        return alineWidth
    }
    var lineScale: CGFloat = 0.2
    var lineFeather: CGFloat {
        get { return lineSmooth }
        set (value) { lineSmooth = value }
    }
    var lineOpacity: CGFloat = 1
    var delegate: AnyObject?
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
                maskLayer?.bounds = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
                maskLayer?.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
            }
            maskLayer!.contents = maskImageStore?.cgImage
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if subpaths == nil { subpaths = NSMutableArray() }
        if touchesStore == nil { touchesStore = NSMutableArray() }

        previousPoint = touch.previousLocation(in: self)
        previousPreviousPoint = previousPoint
        currentPoint = previousPoint
        touchesMoved(touches, with: event)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        maskImage = drawingImage
        numberOfDraws=0
        path=CGMutablePath()
        subpaths?.removeAllObjects()
        touchesStore?.removeAllObjects()
        if sketchEnded != nil { sketchEnded!(maskImage,self) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        maskImage = drawingImage
        if sketchCancelled != nil { sketchCancelled!(maskImage,self) }
    }
//    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
//
//        guard let touch = touches.first else { return }
//        var touches = [UITouch]()
//        if let coalescedTouches = event?.coalescedTouchesForTouch(touch) { touches = coalescedTouches }
//        else { touches.append(touch) }
//        
////        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 1)
////        let context = UIGraphicsGetCurrentContext()
////        let stroke = lineWidth(context, touch: touch)
//        touchesStore?.addObjectsFromArray(touches)
//        for touch in touches {
//        
//            let location = touch.locationInView(self)
//            let dx:CGFloat = location.x - currentPoint.x;
//            let dy:CGFloat = location.y - currentPoint.y;
//            if ( ( dx * dx + dy * dy ) < kPointMinDistanceSquared ) { return }
//            previousPreviousPoint = previousPoint
//            previousPoint = currentPoint
//            currentPoint = location
//            let midA = mPoint(previousPoint, p2: previousPreviousPoint)
//            let midB = mPoint(currentPoint, p2: previousPoint)
//            let subpath = CGPathCreateMutable()
//            CGPathMoveToPoint(subpath, nil, midA.x, midA.y)
//            CGPathAddQuadCurveToPoint(subpath, nil, previousPoint.x, previousPoint.y, midB.x, midB.y)
//            CGPathAddPath(path, nil, subpath)
//            subpaths?.addObject(UIBezierPath.init(CGPath: subpath))
//        }
//        
//        
////        CGContextSetBlendMode(context, .Normal)
////        
////        CGContextAddPath(context, path)
////        CGContextSetLineCap(context, .Round)
////        CGContextSetLineWidth(context, stroke)
////        
////        // Outer shadow
////        let shadowBlurRadius = stroke * (max(0.01,lineSmooth)/4)
////        var shadowOffset:CGSize = CGSizeMake(0.1, -0.1);
////        shadowOffset.width = shadowOffset.width*(CGAffineTransformIsIdentity(transform) ? 1 : (1/transform.a));
////        shadowOffset.height = shadowOffset.height*(CGAffineTransformIsIdentity(transform) ? 1 : (1/transform.a));
////        
////        CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, self.color.CGColor);
////        CGContextStrokePath(context)
////        
////        drawingStrokeImage = UIGraphicsGetImageFromCurrentImageContext()
////        
////        UIGraphicsEndImageContext()
//        
//        self.setNeedsDisplayInRect(bounds)
//        
//
//        
//    }
//    override func drawRect(rect: CGRect) {
//        if touchesStore == nil || touchesStore?.count == 0 { return }
//        let context = UIGraphicsGetCurrentContext()
//        drawingStrokeImage?.drawInRect(bounds)
//        let touch = touchesStore?.lastObject as! UITouch
//        let stroke = lineWidth(context, touch: touch)
//        CGContextSetAlpha(context, lineOpacity)
//        CGContextSetBlendMode(context, .Normal)
//        
//        CGContextAddPath(context, path)
//        CGContextSetLineCap(context, .Round)
//        CGContextSetLineWidth(context, stroke)
//        
//        // Outer shadow
//        CGContextSetShadowWithColor(context, transformSize(CGSizeMake(0.1, -0.1), transform: transform), stroke * (max(0.01,lineSmooth)/4), self.color.CGColor);
//        CGContextStrokePath(context)
//        drawingStrokeImage = UIGraphicsGetImageFromCurrentImageContext()
//        maskImage = drawingStrokeImage
//        print("draw rect  \(maskImage)")
//        if sketchImageDebug != nil { sketchImageDebug!(maskImage,"mask-stroke", self) }
//
//        
//        CGContextSetAlpha(context, 1)
//        UIColor.whiteColor().setFill()
//        CGContextFillRect(context, bounds)
//        maskImage?.drawInRect(bounds, blendMode: !isErasing ? .DestinationOut : .Normal, alpha: 1)
//        
//        
//        
//        maskImage = UIGraphicsGetImageFromCurrentImageContext()
//        
//    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if lineOpacity <= 0 { return }
        guard let touch = touches.first else { return }
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 1)
        let context = UIGraphicsGetCurrentContext()
        // Draw previous image into context
//        let framez = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
        
//        CGContextSetAlpha(context, 1);
        drawingStrokeImage?.draw(in: bounds)
        // 1
        var touches = [UITouch]()
        if #available(iOS 9.0, *) {
            if let coalescedTouches = event?.coalescedTouches(for: touch) { touches = coalescedTouches }
            else { touches.append(touch) }
        } else { touches.append(touch) }



        context?.saveGState()
        context?.beginTransparencyLayer(auxiliaryInfo: nil)
        context?.setAlpha(lineOpacity)

        // 4
        for touch in touches { drawStroke(context, touch: touch, type:0) }

        context?.endTransparencyLayer()
        context?.restoreGState()
        context?.setAlpha(1)

        // 1
        drawingStrokeImage = UIGraphicsGetImageFromCurrentImageContext()
        maskImage = drawingStrokeImage
        // 2
        
//        let predicts = event?.predictedTouchesForTouch(touch)
//        if (predicts != nil) { for touch in predicts! { drawStroke(context, touch: touch, type:1) } }
        
//        maskImage = predicts != nil ? UIGraphicsGetImageFromCurrentImageContext() : drawingStrokeImage
        context?.setAlpha(1)

//        CGContextClearRect(context, self.bounds)
        
        UIColor.white.setFill()
        context?.fill(bounds)
        
//        if sketchImageDebug != nil { sketchImageDebug!(maskImage,"mask-stroke", self) }
//
//        if !isErasing { CGContextSetBlendMode(context, .DestinationOut) }
//        CGContextSetAlpha(context, lineOpacity)
        maskImage?.draw(in: bounds, blendMode: !isErasing ? .destinationOut : .normal, alpha: 1)


        maskImage = UIGraphicsGetImageFromCurrentImageContext()
        
//        if sketchImageDebug != nil { sketchImageDebug!(maskImage,"mask-final", self) }

        
        UIGraphicsEndImageContext()
        
        
        
        if numberOfDraws > maxNumberOfDraws
        {
            numberOfDraws = 0
            subpaths?.removeObjects(in: NSRange.init(location: 0,length: (subpaths?.count)!-10))
            path = CGMutablePath()
            for (_,value) in (subpaths?.enumerated())! {
                let a = value as! UIBezierPath
                path.addPath(a.cgPath)
//                CGPathAddPath(path, nil, a.cgPath)
            }
        }
        
        if sketchChanged != nil { sketchChanged!(maskImage,self) }

    }
    
    
    fileprivate func drawStroke(_ context: CGContext?, touch: UITouch, type: Int) {
        let location = touch.location(in: self)
        let dx:CGFloat = location.x - currentPoint.x;
        let dy:CGFloat = location.y - currentPoint.y;
        if ( ( dx * dx + dy * dy ) < kPointMinDistanceSquared ) { return }
        var alineWidth: CGFloat = defaultLineWidth
        
        if #available(iOS 9.1, *) {
            if touch.type == .stylus
            {
                if touch.altitudeAngle < tiltThreshold {
                    alineWidth = lineWidthForShading(context, touch: touch)
                } else {
                    alineWidth = lineWidthForDrawing(context, touch: touch)
                }
                pencilTexture = pencilTexture.withAlphaComponent(lineOpacity);
                pencilTexture.setStroke()
            } else {
                alineWidth = touch.majorRadius / 2
                self.color.setStroke()
            }
        } else {
            alineWidth = touch.majorRadius / 2
            self.color.setStroke()
        }
    
        alineWidth = transform.isIdentity ? max(alineWidth, minLineWidth) : max(alineWidth, minLineWidth)*(1/transform.a)
    
        alineWidth = max(minLineWidth, alineWidth * (max(0.001,lineScale/2) * 100))
        previousPreviousPoint = previousPoint
        previousPoint = currentPoint
        currentPoint = location
        
        let midA = mPoint(previousPoint, p2: previousPreviousPoint)
        let midB = mPoint(currentPoint, p2: previousPoint)
        
        
        let subpath = CGMutablePath()
        subpath.move(to: midA)
        subpath.addQuadCurve(to: midB, control: previousPoint)
        path.addPath(subpath)
//        CGPathMoveToPoint(subpath, nil, midA.x, midA.y)
//        CGPathAddQuadCurveToPoint(subpath, nil, previousPoint.x, previousPoint.y, midB.x, midB.y)

//        CGPathAddPath(path, nil, subpath)
        subpaths?.add(UIBezierPath.init(cgPath: subpath))
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.setBlendMode(.normal)

        context?.addPath(path)
        context?.setLineCap(.round)
        context?.setLineWidth(alineWidth)
        
        // Outer shadow
        let shadowBlurRadius = alineWidth * (max(0.01,lineSmooth)/4)
        var shadowOffset:CGSize = CGSize(width: 0.1, height: -0.1);
        shadowOffset.width = shadowOffset.width*(transform.isIdentity ? 1 : (1/transform.a));
        shadowOffset.height = shadowOffset.height*(transform.isIdentity ? 1 : (1/transform.a));

        context?.setShadow(offset: shadowOffset, blur: shadowBlurRadius, color: self.color.cgColor);
        context?.strokePath()
        
        numberOfDraws += 1
    }

    fileprivate func lineWidthForShading(_ context: CGContext?, touch: UITouch) -> CGFloat {

        // 1
        let __previousLocation = touch.previousLocation(in: self)
        let location = touch.location(in: self)

        // 2 - vector1 is the pencil direction
        var vector1 = CGVector(dx: location.x, dy: location.y)
        if #available(iOS 9.1, *)
        {
            vector1 = touch.azimuthUnitVector(in: self)
        }
        // 3 - vector2 is the stroke direction
        let vector2 = CGPoint(x: location.x - __previousLocation.x, y: location.y - __previousLocation.y)

        // 4 - Angle difference between the two vectors
        var angle = abs(atan2(vector2.y, vector2.x) - atan2(vector1.dy, vector1.dx))

        // 5
        if angle > π2 { angle = 2 * π2 - angle }
        if angle > π2 / 2 { angle = π2 - angle }

        // 6
        let minAngle: CGFloat = 0
        let maxAngle = π2 / 2
        let normalizedAngle = (angle - minAngle) / (maxAngle - minAngle)

        // 7
        let maxLineWidth: CGFloat = 60
        var lineWidth = maxLineWidth * normalizedAngle

        // 1 - modify lineWidth by altitude (tilt of the Pencil)
        // 0.25 radians means widest stroke and TiltThreshold is where shading narrows to line.

        let minAltitudeAngle: CGFloat = 0.25
        let maxAltitudeAngle = tiltThreshold

        // 2
        if #available(iOS 9.1, *) {

            let altitudeAngle = touch.altitudeAngle < minAltitudeAngle
              ? minAltitudeAngle : touch.altitudeAngle

            // 3 - normalize between 0 and 1
            let normalizedAltitude = 1 - ((altitudeAngle - minAltitudeAngle)
              / (maxAltitudeAngle - minAltitudeAngle))
            // 4
            lineWidth = lineWidth * normalizedAltitude + minLineWidth
            let minForce: CGFloat = 0.0
            let maxForce: CGFloat = 5
            
            // Normalize between 0 and 1
            let normalizedAlpha = (touch.force - minForce) / (maxForce - minForce)
            context?.setAlpha(normalizedAlpha)
        }
        // Set alpha of shading using force
        
        return lineWidth * lineScale
    }


    fileprivate func lineWidthForDrawing(_ context: CGContext?, touch: UITouch) -> CGFloat {
        if #available(iOS 9.1, *) {
            if touch.force > 0 { return touch.force * forceSensitivity }
        }
        return defaultLineWidth
    }
    func fillMask()
    {
        let framez = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)

        UIGraphicsBeginImageContextWithOptions(framez.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        UIColor.black.setFill()
        context?.fill(framez)
        drawingStrokeImage = nil
        maskImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if sketchChanged != nil { sketchChanged!(maskImage,self) }
        if sketchMaskFilled != nil { sketchMaskFilled!(maskImage,self) }
    }
    func emptyMask()
    {
        let framez = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)

        UIGraphicsBeginImageContextWithOptions(framez.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        UIColor.clear.setFill()
        context?.fill(framez)
        drawingStrokeImage = UIGraphicsGetImageFromCurrentImageContext()
        maskImage = drawingImage
        UIGraphicsEndImageContext()
        if sketchChanged != nil { sketchChanged!(maskImage,self) }
        if sketchMaskCleared != nil { sketchMaskCleared!(maskImage,self) }
    }
    func clearCanvas(animated: Bool) {
        if animated {
          UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 0
            }, completion: { finished in
              self.alpha = 1
              self.maskImage = nil
              self.drawingStrokeImage = nil
          })
        } else {
          self.maskImage = nil
          self.drawingStrokeImage = nil
            if sketchCleared != nil {
                sketchCleared!(self)
            }
        }
    }

    
    
}
