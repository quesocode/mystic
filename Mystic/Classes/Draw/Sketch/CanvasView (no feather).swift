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

let π2 = CGFloat(M_PI)

@objc class CanvasView: UIView {
  
    // Parameters
    private let defaultLineWidth: CGFloat = 6
    private let forceSensitivity: CGFloat = 4.0
    private let tiltThreshold = π2/6  // 30º
    private let minLineWidth: CGFloat = 2
    var drawingImage: UIImage?
    private var toolTypeValue: NSInteger = 0
    var toolType: NSInteger
        {
            get { return self.toolTypeValue }
            set(newToolType)
            {
                switch (newToolType)
                {
                    case 0:
                        drawColorValue = UIColor.blackColor()
                        isErasing = true
                    
                    case 1:
                        drawColorValue = UIColor.clearColor()
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
    private var drawColorValue: UIColor = UIColor.blackColor()
    var drawColor: UIColor  {
        get {
            let c:UIColor  = drawColorValue ?? UIColor.blackColor()
            let c2 = UIColor.colorWithAlphaComponent(c)(isErasing ? lineOpacity : 1-lineOpacity)
            return c2
        }
        set(newColor)
        {
            drawColorValue = newColor
        }
    }
    private var eraserColorValue: UIColor = UIColor.blackColor()
    var eraserColor:UIColor {
        get {
            let c:UIColor  = eraserColorValue ?? UIColor.blackColor()
            let c2 = UIColor.colorWithAlphaComponent(c)(isErasing ? lineOpacity : 1-lineOpacity)
            return c2
        }
        set(newColor)
        {
            eraserColorValue = newColor
        }
    }
    var pencilTexture: UIColor = UIColor(patternImage: UIImage(named: "PencilTexture")!)
    var lineWidth: CGFloat = 5
    var lineScale: CGFloat = 1
    var lineFeather: CGFloat = 0
    var lineOpacity: CGFloat = 1
    var delegate: AnyObject?
    var sketchChanged: ((UIImage?, CanvasView?) -> Void)?
    var sketchEnded: ((UIImage?, CanvasView?) -> Void)?
    var sketchCancelled: ((UIImage?, CanvasView?) -> Void)?
    var sketchMaskFilled: ((UIImage?, CanvasView?) -> Void)?
    var sketchMaskCleared: ((UIImage?, CanvasView?) -> Void)?
    var sketchBrushChanged: ((CanvasView?) -> Void)?
    var sketchCleared: ((CanvasView?) -> Void)?
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
            if drawingImage == nil { drawingImage=newMaskImage }
            if maskLayer == nil {
                maskLayer = CALayer()
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
            if maskLayer != nil { maskLayer?.bounds = bounds }
            if foregroundLayer != nil { foregroundLayer?.bounds = bounds }
            if backgroundLayer != nil { backgroundLayer?.bounds = bounds }

        }
    }
    
    
    func redraw()
    {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        // Draw previous image into context
        if drawingImage == nil
        {
            UIColor.blackColor().setFill()
            CGContextFillRect(context, bounds)
            drawingImage = UIGraphicsGetImageFromCurrentImageContext()
        }
        else
        {
            drawingImage?.drawInRect(bounds)
        }

        // Update image
        self.maskImage = drawingImage
        
        UIGraphicsEndImageContext()
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if lineOpacity <= 0 { return }
        guard let touch = touches.first else { return }

        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        // Draw previous image into context
        if drawingImage == nil
        {
            UIColor.blackColor().setFill()
            CGContextFillRect(context, bounds)
        }
        else
        {
            drawingImage?.drawInRect(bounds)
        }
        
        // 1
        var touches = [UITouch]()

        // Coalesce Touches
        // 2
        if let coalescedTouches = event?.coalescedTouchesForTouch(touch) { touches = coalescedTouches }
        else { touches.append(touch) }
        if !isErasing { CGContextSetBlendMode(context, CGBlendMode.Clear) }
        // 4
        for touch in touches { drawStroke(context, touch: touch) }

        // 1
        drawingImage = UIGraphicsGetImageFromCurrentImageContext()
        // 2
        if let predictedTouches = event?.predictedTouchesForTouch(touch) {
          for touch in predictedTouches { drawStroke(context, touch: touch) }
        }

        // Update image
        self.maskImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        if sketchChanged != nil { sketchChanged!(maskImage,self) }

    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        maskImage = drawingImage
        if sketchEnded != nil { sketchEnded!(maskImage,self) }
    }

    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        maskImage = drawingImage
        if sketchCancelled != nil { sketchCancelled!(maskImage,self) }
    }
    
    private func drawStroke(context: CGContext?, touch: UITouch) {
        let previousLocation = touch.previousLocationInView(self)
        let location = touch.locationInView(self)

        var alineWidth: CGFloat
   
        if touch.type == .Stylus {
            // Calculate line width for drawing stroke
            if touch.altitudeAngle < tiltThreshold {
                alineWidth = lineWidthForShading(context, touch: touch)
            } else {
                alineWidth = lineWidthForDrawing(context, touch: touch)
            }
            pencilTexture = pencilTexture.colorWithAlphaComponent(lineOpacity);
            // Set color
            pencilTexture.setStroke()
        } else {
            
            alineWidth = touch.majorRadius / 2
            if fingerErases { self.eraserColor.setStroke() }
            else { self.drawColor.setStroke() }
        }
        alineWidth = max(alineWidth, minLineWidth)
        // Configure line
        CGContextSetLineWidth(context, alineWidth)
        CGContextSetLineCap(context, .Round)


        // Set up the points
        CGContextMoveToPoint(context, previousLocation.x, previousLocation.y)
        CGContextAddLineToPoint(context, location.x, location.y)
        // Draw the stroke
        CGContextStrokePath(context)
        
        print("is erasing \(isErasing)  \(fingerErases)  \(lineOpacity)")

        if !isErasing {
            if touch.type != .Stylus
            {
                if fingerErases { self.eraserColor.setStroke() }
                else { self.drawColor.setStroke() }
            }
            CGContextSetBlendMode(context, CGBlendMode.Normal)
            CGContextSetLineWidth(context, alineWidth)
            CGContextSetLineCap(context, .Round)
            
            CGContextMoveToPoint(context, previousLocation.x, previousLocation.y)
            CGContextAddLineToPoint(context, location.x, location.y)
            // Draw the stroke
            CGContextStrokePath(context)
            CGContextSetBlendMode(context, CGBlendMode.Clear)
        }

    }

    private func lineWidthForShading(context: CGContext?, touch: UITouch) -> CGFloat {

        // 1
        let previousLocation = touch.previousLocationInView(self)
        let location = touch.locationInView(self)

        // 2 - vector1 is the pencil direction
        let vector1 = touch.azimuthUnitVectorInView(self)

        // 3 - vector2 is the stroke direction
        let vector2 = CGPoint(x: location.x - previousLocation.x, y: location.y - previousLocation.y)

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
        let altitudeAngle = touch.altitudeAngle < minAltitudeAngle
          ? minAltitudeAngle : touch.altitudeAngle

        // 3 - normalize between 0 and 1
        let normalizedAltitude = 1 - ((altitudeAngle - minAltitudeAngle)
          / (maxAltitudeAngle - minAltitudeAngle))
        // 4
        lineWidth = lineWidth * normalizedAltitude + minLineWidth

        // Set alpha of shading using force
        let minForce: CGFloat = 0.0
        let maxForce: CGFloat = 5

        // Normalize between 0 and 1
        let normalizedAlpha = (touch.force - minForce) / (maxForce - minForce)
        CGContextSetAlpha(context, normalizedAlpha)
        return lineWidth * lineScale
    }


    private func lineWidthForDrawing(context: CGContext?, touch: UITouch) -> CGFloat {
        if touch.force > 0 { return touch.force * forceSensitivity }
        return defaultLineWidth
    }
    func fillMask()
    {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        UIColor.blackColor().setFill()
        CGContextFillRect(context, bounds)
        drawingImage = nil
        maskImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if sketchChanged != nil { sketchChanged!(maskImage,self) }
        if sketchMaskFilled != nil { sketchMaskFilled!(maskImage,self) }
    }
    func emptyMask()
    {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        UIColor.clearColor().setFill()
        CGContextFillRect(context, bounds)
        drawingImage = UIGraphicsGetImageFromCurrentImageContext()
        maskImage = drawingImage
        UIGraphicsEndImageContext()
        if sketchChanged != nil { sketchChanged!(maskImage,self) }
        if sketchMaskCleared != nil { sketchMaskCleared!(maskImage,self) }
    }
    func clearCanvas(animated animated: Bool) {
        if animated {
          UIView.animateWithDuration(0.5, animations: {
            self.alpha = 0
            }, completion: { finished in
              self.alpha = 1
              self.maskImage = nil
              self.drawingImage = nil
          })
        } else {
          self.maskImage = nil
          self.drawingImage = nil
            if sketchCleared != nil {
                sketchCleared!(self)
            }
        }
    }

    
    
}
