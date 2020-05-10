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

let π = CGFloat(Double.pi)

@objc class CanvasImageView: UIImageView {
  
    // Parameters
    fileprivate let defaultLineWidth: CGFloat = 6
    fileprivate let forceSensitivity: CGFloat = 4.0
    fileprivate let tiltThreshold = π/6  // 30º
    fileprivate let minLineWidth: CGFloat = 2
    var lineWidth: CGFloat = 5
    var lineScale: CGFloat = 1
    var lineFeather: CGFloat = 0
    var lineOpacity: CGFloat = 1
    var delegate: AnyObject?
    var sketchChanged: ((UIImage?, CanvasImageView?) -> Void)?
    var sketchEnded: ((UIImage?, CanvasImageView?) -> Void)?
    var sketchCancelled: ((UIImage?, CanvasImageView?) -> Void)?
    var sketchCleared: ((CanvasImageView?) -> Void)?

    fileprivate var drawingImage: UIImage?
    var toolType: NSInteger = 0
    var useStylus: Bool = false
    var applyPressure: Bool = true
    var fingerErases: Bool = false
    var drawColor: UIColor = UIColor.red
    var pencilTexture: UIColor = UIColor(patternImage: UIImage(named: "PencilTexture")!)

    fileprivate var eraserColor: UIColor {
        
        return backgroundColor ?? UIColor.white
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        // Draw previous image into context
        drawingImage?.draw(in: bounds)

        // 1
        var touches = [UITouch]()

        // Coalesce Touches
        // 2
        if #available(iOS 9.0, *) {
            if let coalescedTouches = event?.coalescedTouches(for: touch) { touches = coalescedTouches }
            else { touches.append(touch) }
        } else {
            // Fallback on earlier versions
        }

        // 4
        for touch in touches { drawStroke(context, touch: touch) }

        // 1
        drawingImage = UIGraphicsGetImageFromCurrentImageContext()
        // 2
        if #available(iOS 9.0, *) {
            if let predictedTouches = event?.predictedTouches(for: touch) {
              for touch in predictedTouches { drawStroke(context, touch: touch) }
            }
        }
        // Update image
        image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        if sketchChanged != nil { sketchChanged!(image,self) }

    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        image = drawingImage
        if sketchEnded != nil { sketchEnded!(image,self) }

    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        image = drawingImage
        if sketchCancelled != nil { sketchCancelled!(image,self) }
    }
    
    fileprivate func drawStroke(_ context: CGContext?, touch: UITouch) {
        let previousLocation = touch.previousLocation(in: self)
        let location = touch.location(in: self)

        var alineWidth: CGFloat
   
        if #available(iOS 9.1, *) {
            if touch.type == .stylus {
                // Calculate line width for drawing stroke
                if touch.altitudeAngle < tiltThreshold {
                    alineWidth = lineWidthForShading(context, touch: touch)
                } else {
                    alineWidth = lineWidthForDrawing(context, touch: touch)
                }
                // Set color
                pencilTexture.setStroke()
            } else {
                
                alineWidth = touch.majorRadius / 2
                
                if fingerErases { eraserColor.setStroke() }
                else { drawColor.setStroke() }
            }
        } else {
            // Fallback on earlier versions
            alineWidth = touch.majorRadius / 2
            
            if fingerErases { eraserColor.setStroke() }
            else { drawColor.setStroke() }
        }
        alineWidth = max(alineWidth, minLineWidth)
        
        
        

        // Configure line
        context?.setLineWidth(alineWidth)
        context?.setLineCap(.round)


        // Set up the points
        context?.move(to: CGPoint(x: previousLocation.x, y: previousLocation.y))
        context?.addLine(to: CGPoint(x: location.x, y: location.y))
        // Draw the stroke
        context?.strokePath()

    }

    fileprivate func lineWidthForShading(_ context: CGContext?, touch: UITouch) -> CGFloat {

        // 1
        let previousLocation = touch.previousLocation(in: self)
        let location = touch.location(in: self)

        // 2 - vector1 is the pencil direction
        var vector1 = CGVector(dx: location.x, dy: location.y)
        if #available(iOS 9.1, *) {
            vector1 = touch.azimuthUnitVector(in: self)
        }

        // 3 - vector2 is the stroke direction
        let vector2 = CGPoint(x: location.x - previousLocation.x, y: location.y - previousLocation.y)

        // 4 - Angle difference between the two vectors
        var angle = abs(atan2(vector2.y, vector2.x) - atan2(vector1.dy, vector1.dx))

        // 5
        if angle > π { angle = 2 * π - angle }
        if angle > π / 2 { angle = π - angle }

        // 6
        let minAngle: CGFloat = 0
        let maxAngle = π / 2
        let normalizedAngle = (angle - minAngle) / (maxAngle - minAngle)

        // 7
        let maxLineWidth: CGFloat = 60
        var lineWidth = maxLineWidth * normalizedAngle

        // 1 - modify lineWidth by altitude (tilt of the Pencil)
        // 0.25 radians means widest stroke and TiltThreshold is where shading narrows to line.

        let minAltitudeAngle: CGFloat = 0.25
        let maxAltitudeAngle = tiltThreshold

        // 2
        var altitudeAngle = CGFloat(0.0)

        
        if #available(iOS 9.1, *) {
            altitudeAngle = touch.altitudeAngle < minAltitudeAngle
                ? minAltitudeAngle : touch.altitudeAngle
            // 3 - normalize between 0 and 1
            let normalizedAltitude = 1 - ((altitudeAngle - minAltitudeAngle)
                / (maxAltitudeAngle - minAltitudeAngle))
            // 4
            lineWidth = lineWidth * normalizedAltitude + minLineWidth
            
            // Set alpha of shading using force
            let minForce: CGFloat = 0.0
            let maxForce: CGFloat = 5
            
            let normalizedAlpha = (touch.force - minForce) / (maxForce - minForce)
            
            context?.setAlpha(normalizedAlpha)
        }

        
        
        return lineWidth * lineScale
    }


    fileprivate func lineWidthForDrawing(_ context: CGContext?, touch: UITouch) -> CGFloat {

        var lineWidth = defaultLineWidth

        if #available(iOS 9.0, *) {
            if touch.force > 0 {  // If finger, touch.force = 0
                lineWidth = touch.force * forceSensitivity
            }
        } else {
            // Fallback on earlier versions
        }

        return lineWidth
    }

    func clearCanvas(animated: Bool) {
        if animated {
          UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 0
            }, completion: { finished in
              self.alpha = 1
              self.image = nil
              self.drawingImage = nil
          })
        } else {
          self.image = nil
          self.drawingImage = nil
            if sketchCleared != nil {
                sketchCleared!(self)
            }
        }
    }

    
    
}
