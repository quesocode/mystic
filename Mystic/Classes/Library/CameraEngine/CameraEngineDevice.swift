//
//  CameraEngineDevice.swift
//  CameraEngine2
//
//  Created by Remi Robert on 24/12/15.
//  Copyright © 2015 Remi Robert. All rights reserved.
//

import UIKit
import AVFoundation

public enum CameraEngineCameraFocus {
    case locked
    case autoFocus
    case continuousAutoFocus
    
    func foundationFocus() -> AVCaptureFocusMode {
        switch self {
        case .locked: return AVCaptureFocusMode.locked
        case .autoFocus: return AVCaptureFocusMode.autoFocus
        case .continuousAutoFocus: return AVCaptureFocusMode.continuousAutoFocus
        }
    }
    
    public func description() -> String {
        switch self {
        case .locked: return "Locked"
        case .autoFocus: return "AutoFocus"
        case .continuousAutoFocus: return "ContinuousAutoFocus"
        }
    }
    
    public static func availableFocus() -> [CameraEngineCameraFocus] {
        return [
            .locked,
            .autoFocus,
            .continuousAutoFocus
        ]
    }
}

class CameraEngineDevice {

    fileprivate var backCameraDevice: AVCaptureDevice!
    fileprivate var frontCameraDevice: AVCaptureDevice!
    var micCameraDevice: AVCaptureDevice!
    var currentDevice: AVCaptureDevice?
    var currentPosition: AVCaptureDevicePosition = .unspecified
    
    func changeCameraFocusMode(_ focusMode: CameraEngineCameraFocus) {
        if let currentDevice = self.currentDevice {
            do {
                try currentDevice.lockForConfiguration()
                if currentDevice.isFocusModeSupported(focusMode.foundationFocus()) {
                    currentDevice.focusMode = focusMode.foundationFocus()
                }
                currentDevice.unlockForConfiguration()
            }
            catch {
                fatalError("[CameraEngine] error, impossible to lock configuration device")
            }
        }
    }
    
    func changeCurrentDevice(_ position: AVCaptureDevicePosition) {
        self.currentPosition = position
        switch position {
        case .back: self.currentDevice = self.backCameraDevice
        case .front: self.currentDevice = self.frontCameraDevice
        case .unspecified: self.currentDevice = nil
        }
    }
    
    fileprivate func configureDeviceCamera() {
        let availableCameraDevices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
        for device in availableCameraDevices as! [AVCaptureDevice] {
            if device.position == .back {
                self.backCameraDevice = device
            }
            else if device.position == .front {
                self.frontCameraDevice = device
            }
        }        
    }
    
    fileprivate func configureDeviceMic() {
        self.micCameraDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
    }
    
    init() {
        self.configureDeviceCamera()
        self.configureDeviceMic()
        self.changeCurrentDevice(.back)
    }
}
