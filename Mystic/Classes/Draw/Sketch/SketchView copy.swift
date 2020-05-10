//
//  SketchView.swift
//  Mystic
//
//  Created by Travis A. Weerts on 3/20/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

import UIKit

let π3 = CGFloat(M_PI)

struct LineInfo {
    var width:CGFloat
    var opacity:CGFloat
}

@objc class SketchView: UIView {

    // Undo
    var canUndo:Bool { return paths?.count > 0 }
    var undoSteps:Int { return (buffer?.count)! }
    var canRedo:Bool { return buffer?.count > 0 }
    
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
    
    private let minLineWidth: CGFloat = 1
    private let forceSensitivity: CGFloat = 4.0
    private let tiltThreshold = π3/6  // 30º
    private var buffer:NSMutableArray?
    private var paths:NSMutableArray?
    private var _tool:SketchTool?
    private var pointPreviousLast:CGPoint = CGPointZero
    private var pointPrevious:CGPoint = CGPointZero
    private var pointCurrent:CGPoint = CGPointZero
    private var _toolType:SketchToolType = SketchToolType.Brush
    var toolType:Int {
        get {
            switch _toolType {
                case .Brush: return 0
                case .Pen: return 1
                case .Eraser: return 0
            }
        }
        set(value)
        {
            switch value
            {
                case 0: _toolType = .Brush
                case 1: _toolType = .Pen
                case 2: _toolType = .Eraser
                default: _toolType = .Brush
            }
        }
    }
    
    var tool: SketchTool? {
        get { if (_tool == nil) { _tool = SketchTool.tool(_toolType) }; return _tool }
        set(value) { _tool = value }
    }
    // Blocks
    var started: ((SketchView?) -> Void)?
    var changed: ((SketchView?) -> Void)?
    var ended: ((SketchView?) -> Void)?
    var updated: ((UIImage?, String?, SketchView?) -> Void)?
    var endedTool: ((SketchTool?, SketchView?) -> Void)?
    var cancelled: ((SketchView?) -> Void)?
    var filled: ((SketchView?) -> Void)?
    var cleared: ((SketchView?) -> Void)?
    var debug: ((UIImage?, NSString?, SketchView?) -> Void)?
    var changedBrush: ((SketchView?) -> Void)?
    var didUndo:((SketchView?) -> Void)?
    var didRedo:((SketchView?) -> Void)?
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        setup()
    }
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        setup()
    }
    private func setup()
    {
        paths = NSMutableArray()
        buffer = NSMutableArray()
        backgroundColor = UIColor.clearColor()
        _toolType = .Brush
    }
    
    override func drawRect(rect: CGRect) {
//        super.drawRect(rect)
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
//        let ctx = UIGraphicsGetCurrentContext()
//        UIColor.blackColor().setFill()
//        CGContextFillRect(ctx, bounds)
        image?.drawAtPoint(CGPointZero)
        tool?.draw(rect)
        updated?(UIGraphicsGetImageFromCurrentImageContext(), "drawRect", self)
        UIGraphicsEndImageContext()
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else { return }
        pointPrevious = touch.previousLocationInView(self)
        pointCurrent = touch.locationInView(self)
        self.tool?.line = line(touch)
        self.tool?.feather = lineFeather
        self.tool?.pointStart = pointCurrent
        paths?.addObject(self.tool!)
        started?(self)
    }
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        cancelled?(self)
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        finished()
        ended?(self)
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else { return }
        pointPreviousLast = pointPrevious
        pointPrevious = touch.previousLocationInView(self)
        pointCurrent = touch.locationInView(self)
        self.tool?.line = line(touch)
        switch _toolType {
            
            case .Brush:
                setNeedsDisplayInRect((self.tool?.addPoint(pointPreviousLast, previous: pointPrevious, current: pointCurrent))!)
                break
//            case .Pen: setNeedsDisplayInRect((self.tool?.addPoint(pointPreviousLast, previous: pointPrevious, current: pointCurrent))!)
//            case .Eraser: self.tool?.movePoint(pointPrevious, to: pointCurrent); setNeedsDisplay()
            
            default:
                setNeedsDisplayInRect((self.tool?.addPoint(pointPreviousLast, previous: pointPrevious, current: pointCurrent))!)
                break
        }
        changed?(self)
    }
    func finished()
    {
        update(false)
        buffer?.removeAllObjects()
        endedTool?(tool,self)
        tool = nil
    }
    func update(redraw: Bool)
    {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        if(redraw)
        {
            image = nil
            for pathTool in paths! { pathTool.draw(bounds) }
        }
        else
        {
            image?.drawAtPoint(CGPointZero)
            tool?.draw(bounds)
        }
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        updated?(image, "updated", self)
    }
    
    
    func undo()
    {
        if canUndo == false { return }
        buffer?.addObject((paths?.lastObject)!)
        paths?.removeLastObject()
        update(true)
        setNeedsDisplay()
        didUndo?(self)
    }
    func redo()
    {
        if canRedo == false { return }
        paths?.addObject((buffer?.lastObject)!)
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
    }
    
    func fill()
    {
        
    }
    func empty()
    {
        clear()
    }
    
    
    private func line(touch: UITouch) -> LineInfo {
        if touch.type == .Stylus && useStylus {
            return touch.altitudeAngle < tiltThreshold ? lineForShading(touch) : lineForDrawing(touch);
        }
        return LineInfo(width:max(minLineWidth, (CGAffineTransformIsIdentity(transform) ? max(touch.majorRadius / 2, minLineWidth) : max(touch.majorRadius / 2, minLineWidth)*(1/transform.a) * (max(0.001,lineScale/2) * 100))), opacity: lineOpacity)
    }
    private func lineForShading(touch: UITouch) -> LineInfo {
        let __prev = touch.previousLocationInView(self)
        let location = touch.locationInView(self)
        let vector1 = touch.azimuthUnitVectorInView(self)
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
        let altitudeAngle = touch.altitudeAngle < minAltitudeAngle ? minAltitudeAngle : touch.altitudeAngle
        let normalizedAltitude = 1 - ((altitudeAngle - minAltitudeAngle) / (maxAltitudeAngle - minAltitudeAngle))
        lineWidth = lineWidth * normalizedAltitude + minLineWidth
        return  LineInfo(width:lineWidth * lineScale, opacity:(touch.force - 0) / (5 - 0))
    }
    private func lineForDrawing(touch: UITouch) -> LineInfo {
        if touch.force > 0 { return LineInfo(width:(touch.force * forceSensitivity), opacity: 1) }
        return LineInfo(width:defaultLineWidth, opacity: 1)
    }

}
