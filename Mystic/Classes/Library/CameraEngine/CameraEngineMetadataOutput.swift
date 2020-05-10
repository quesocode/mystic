//
//  CameraEngineMetadataOutput.swift
//  CameraEngine2
//
//  Created by Remi Robert on 03/02/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

import UIKit
import AVFoundation

public typealias blockCompletionDetectionFace = (_ faceObject: AVMetadataFaceObject) -> (Void)
public typealias blockCompletionDetectionCode = (_ codeObject: AVMetadataMachineReadableCodeObject) -> (Void)

public enum CameraEngineCaptureOutputDetection {
    case face
    case qrCode
    case bareCode
    case none
    
    func foundationCaptureOutputDetection() -> [AnyObject] {
        switch self {
        case .face: return [AVMetadataObjectTypeFace as AnyObject]
        case .qrCode: return [AVMetadataObjectTypeQRCode as AnyObject]
        case .bareCode: return [
            AVMetadataObjectTypeUPCECode as AnyObject,
            AVMetadataObjectTypeCode39Code as AnyObject,
            AVMetadataObjectTypeCode39Mod43Code as AnyObject,
            AVMetadataObjectTypeEAN13Code as AnyObject,
            AVMetadataObjectTypeEAN8Code as AnyObject,
            AVMetadataObjectTypeCode93Code as AnyObject,
            AVMetadataObjectTypeCode128Code as AnyObject,
            AVMetadataObjectTypePDF417Code as AnyObject,
            AVMetadataObjectTypeQRCode as AnyObject,
            AVMetadataObjectTypeAztecCode as AnyObject
            ]
        case .none: return []
        }
    }
    
    public static func availableDetection() -> [CameraEngineCaptureOutputDetection] {
        return [
            .face,
            .qrCode,
            .bareCode,
            .none
        ]
    }
    
    public func description() -> String {
        switch self {
        case .face: return "Face detection"
        case .qrCode: return "QRCode detection"
        case .bareCode: return "BareCode detection"
        case .none: return "No detection"
        }
    }
}

class CameraEngineMetadataOutput: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    
    fileprivate var metadataOutput:AVCaptureMetadataOutput?
    fileprivate var currentMetadataOutput: CameraEngineCaptureOutputDetection = .none
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var blockCompletionFaceDetection: blockCompletionDetectionFace?
    var blockCompletionCodeDetection: blockCompletionDetectionCode?
    
    var shapeLayer = CAShapeLayer()
    var layer2 = CALayer()
    
    func configureMetadataOutput(_ session: AVCaptureSession, sessionQueue: DispatchQueue, metadataType: CameraEngineCaptureOutputDetection) {
        if self.metadataOutput == nil {
            self.metadataOutput = AVCaptureMetadataOutput()
            self.metadataOutput?.setMetadataObjectsDelegate(self, queue: sessionQueue)
            if session.canAddOutput(self.metadataOutput) {
                session.addOutput(self.metadataOutput)
            }
        }
        self.metadataOutput!.metadataObjectTypes = metadataType.foundationCaptureOutputDetection()
        self.currentMetadataOutput = metadataType
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        guard let previewLayer = self.previewLayer else {
            return
        }
        
        for metadataObject in metadataObjects as! [AVMetadataObject] {
            switch metadataObject.type {
            case AVMetadataObjectTypeFace:
                if let block = self.blockCompletionFaceDetection, self.currentMetadataOutput == .face {
                    let transformedMetadataObject = previewLayer.transformedMetadataObject(for: metadataObject)
                    block(transformedMetadataObject as! AVMetadataFaceObject)
                }
            case AVMetadataObjectTypeQRCode:
                if let block = self.blockCompletionCodeDetection, self.currentMetadataOutput == .qrCode {
                    let transformedMetadataObject = previewLayer.transformedMetadataObject(for: metadataObject)
                    block(transformedMetadataObject as! AVMetadataMachineReadableCodeObject)
                }
            case AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypePDF417Code,AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode:
                if let block = self.blockCompletionCodeDetection, self.currentMetadataOutput == .bareCode {
                    let transformedMetadataObject = previewLayer.transformedMetadataObject(for: metadataObject)
                    block(transformedMetadataObject as! AVMetadataMachineReadableCodeObject)
                }
            default:break
            }
        }
    }
}
