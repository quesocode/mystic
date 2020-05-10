//
//  CameraEngineDeviceInput.swift
//  CameraEngine2
//
//  Created by Remi Robert on 01/02/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

import UIKit
import AVFoundation

public enum CameraEngineDeviceInputErrorType: Error {
    case unableToAddCamera
    case unableToAddMic
}

class CameraEngineDeviceInput {

    fileprivate var cameraDeviceInput: AVCaptureDeviceInput?
    fileprivate var micDeviceInput: AVCaptureDeviceInput?
    
    func configureInputCamera(_ session: AVCaptureSession, device: AVCaptureDevice) throws {
        let possibleCameraInput: AnyObject? = try AVCaptureDeviceInput(device: device)
        if let cameraInput = possibleCameraInput as? AVCaptureDeviceInput {
            if let currentDeviceInput = self.cameraDeviceInput {
                session.removeInput(currentDeviceInput)
            }
            self.cameraDeviceInput = cameraInput
            if session.canAddInput(self.cameraDeviceInput) {
                session.addInput(self.cameraDeviceInput)
            }
            else {
                throw CameraEngineDeviceInputErrorType.unableToAddCamera
            }
        }
    }
    
    func configureInputMic(_ session: AVCaptureSession, device: AVCaptureDevice) throws {
        if self.micDeviceInput != nil {
            return
        }
        try self.micDeviceInput = AVCaptureDeviceInput(device: device)
        if session.canAddInput(self.micDeviceInput) {
            session.addInput(self.micDeviceInput)
        }
        else {
            throw CameraEngineDeviceInputErrorType.unableToAddMic
        }
    }
}
