//
//  CameraEngine.swift
//  CameraEngine2
//
//  Created by Remi Robert on 24/12/15.
//  Copyright © 2015 Remi Robert. All rights reserved.
//

import UIKit
import AVFoundation

public enum CameraEngineSessionPreset {
    case photo
    case high
    case medium
    case low
    case res352x288
    case res640x480
    case res1280x720
    case res1920x1080
    case res3840x2160
    case frame960x540
    case frame1280x720
    case inputPriority
    
    public func foundationPreset() -> String {
        switch self {
        case .photo: return AVCaptureSessionPresetPhoto
        case .high: return AVCaptureSessionPresetHigh
        case .medium: return AVCaptureSessionPresetMedium
        case .low: return AVCaptureSessionPresetLow
        case .res352x288: return AVCaptureSessionPreset352x288
        case .res640x480: return AVCaptureSessionPreset640x480
        case .res1280x720: return AVCaptureSessionPreset1280x720
        case .res1920x1080: return AVCaptureSessionPreset1920x1080
        case .res3840x2160:
            if #available(iOS 9.0, *) {
                return AVCaptureSessionPreset3840x2160
            }
            else {
                return AVCaptureSessionPresetPhoto
            }
        case .frame960x540: return AVCaptureSessionPresetiFrame960x540
        case .frame1280x720: return AVCaptureSessionPresetiFrame1280x720
        default: return AVCaptureSessionPresetPhoto
        }
    }
    
    public static func availablePresset() -> [CameraEngineSessionPreset] {
        return [
            .photo,
            .high,
            .medium,
            .low,
            .res352x288,
            .res640x480,
            .res1280x720,
            .res1920x1080,
            .res3840x2160,
            .frame960x540,
            .frame1280x720,
            .inputPriority
        ]
    }
}

let cameraEngineSessionQueueIdentifier = "com.cameraEngine.capturesession"

open class CameraEngine: NSObject {
    
    static let sharedInstance = CameraEngine()
//    private static var __once: () = {
//            Static.instance = CameraEngine()
//        }()
    
    fileprivate let session = AVCaptureSession()
    fileprivate let cameraDevice = CameraEngineDevice()
    fileprivate let cameraOutput = CameraEngineCaptureOutput()
    fileprivate let cameraInput = CameraEngineDeviceInput()
    fileprivate let cameraMetadata = CameraEngineMetadataOutput()
    fileprivate let cameraGifEncoder = CameraEngineGifEncoder()
    fileprivate var captureDeviceIntput: AVCaptureDeviceInput?
    
    fileprivate var sessionQueue: DispatchQueue! = {
        DispatchQueue(label: cameraEngineSessionQueueIdentifier, attributes: [])
    }()
    
    fileprivate var _torchMode: AVCaptureTorchMode = .off
    open var torchMode: AVCaptureTorchMode! {
        get {
            return _torchMode
        }
        set {
            _torchMode = newValue
            configureTorch(newValue)
        }
    }
    
    fileprivate var _flashMode: AVCaptureFlashMode = .off
    open var flashMode: AVCaptureFlashMode! {
        get {
            return _flashMode
        }
        set {
            _flashMode = newValue
            configureFlash(newValue)
        }
    }
    
    open lazy var previewLayer: AVCaptureVideoPreviewLayer! = {
        let layer =  AVCaptureVideoPreviewLayer(session: self.session)
        layer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        return layer
    }()
    
    fileprivate var _sessionPresset: CameraEngineSessionPreset = .inputPriority
    open var sessionPresset: CameraEngineSessionPreset! {
        get {
            return self._sessionPresset
        }
        set {
            if self.session.canSetSessionPreset(newValue.foundationPreset()) {
                self._sessionPresset = newValue
                self.session.sessionPreset = self._sessionPresset.foundationPreset()
            }
            else {
                //fatalError("[CameraEngine] session presset : [\(newValue.foundationPreset())] uncompatible with the current device")
            }
        }
    }
    
    fileprivate var _cameraFocus: CameraEngineCameraFocus = .continuousAutoFocus
    open var cameraFocus: CameraEngineCameraFocus! {
        get {
            return self._cameraFocus
        }
        set {
            self.cameraDevice.changeCameraFocusMode(newValue)
            self._cameraFocus = newValue
        }
    }
    
    fileprivate var _metadataDetection: CameraEngineCaptureOutputDetection = .none
    open var metadataDetection: CameraEngineCaptureOutputDetection! {
        get {
            return self._metadataDetection
        }
        set {
            self._metadataDetection = newValue
            self.cameraMetadata.configureMetadataOutput(self.session, sessionQueue: self.sessionQueue, metadataType: self._metadataDetection)
        }
    }
    
    fileprivate var _videoEncoderPresset: CameraEngineVideoEncoderEncoderSettings!
    open var videoEncoderPresset: CameraEngineVideoEncoderEncoderSettings! {
        set {
            self._videoEncoderPresset = newValue
            self.cameraOutput.setPressetVideoEncoder(self._videoEncoderPresset)
        }
        get {
            return self._videoEncoderPresset
        }
    }
    
    open var blockCompletionBuffer: blockCompletionOutputBuffer? {
        didSet {
            self.cameraOutput.blockCompletionBuffer = self.blockCompletionBuffer
        }
    }
    
    open var blockCompletionProgress: blockCompletionProgressRecording? {
        didSet {
            self.cameraOutput.blockCompletionProgress = self.blockCompletionProgress
        }
    }
    
    open var blockCompletionFaceDetection: blockCompletionDetectionFace? {
        didSet {
            self.cameraMetadata.blockCompletionFaceDetection = self.blockCompletionFaceDetection
        }
    }
    
    open var blockCompletionCodeDetection: blockCompletionDetectionCode? {
        didSet {
            self.cameraMetadata.blockCompletionCodeDetection = self.blockCompletionCodeDetection
        }
    }
    
    open var isRecording: Bool {
        get {
            return self.cameraOutput.isRecording
        }
    }
    
//    open class var sharedInstance: CameraEngine {
//        struct Static {
//            static var onceToken: Int = 0
//            static var instance: CameraEngine? = nil
//        }
//        _ = CameraEngine.__once
//        return Static.instance!
//    }
    
    public override init() {
        super.init()
        self.setupSession()
    }
    
    deinit {
        self.stopSession()
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func setupSession() {
        self.sessionQueue.async { () -> Void in
            self.configureInputDevice()
            self.configureOutputDevice()
            self.handleDeviceOrientation()
        }
    }
    
    open class func askAuthorization() -> AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
    }
    
    //MARK: Session management
    
    open func startSession() {
        self.sessionQueue.async { () -> Void in
            self.session.startRunning()
        }
    }
    
    open func stopSession() {
        self.sessionQueue.async { () -> Void in
            self.session.stopRunning()
        }
    }
    
    //MARK: Device management
    
    fileprivate func handleDeviceOrientation() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIDeviceOrientationDidChange, object: nil, queue: OperationQueue.main) { (_) -> Void in
            self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.orientationFromUIDeviceOrientation(UIDevice.current.orientation)
        }
    }
    
    open func changeCurrentDevice(_ position: AVCaptureDevicePosition) {
        self.cameraDevice.changeCurrentDevice(position)
        self.configureInputDevice()
    }
    
    open func compatibleCameraFocus() -> [CameraEngineCameraFocus] {
        if let currentDevice = self.cameraDevice.currentDevice {
            return CameraEngineCameraFocus.availableFocus().filter {
                return currentDevice.isFocusModeSupported($0.foundationFocus())
            }
        }
        else {
            return []
        }
    }
    
    open func compatibleSessionPresset() -> [CameraEngineSessionPreset] {
        return CameraEngineSessionPreset.availablePresset().filter {
            return self.session.canSetSessionPreset($0.foundationPreset())
        }
    }
    
    open func compatibleVideoEncoderPresset() -> [CameraEngineVideoEncoderEncoderSettings] {
        return CameraEngineVideoEncoderEncoderSettings.availableFocus()
    }
    
    open func compatibleDetectionMetadata() -> [CameraEngineCaptureOutputDetection] {
        return CameraEngineCaptureOutputDetection.availableDetection()
    }
    
    fileprivate func configureFlash(_ mode: AVCaptureFlashMode) {
        if let currentDevice = self.cameraDevice.currentDevice, currentDevice.isFlashAvailable && currentDevice.flashMode != mode {
            do {
                try currentDevice.lockForConfiguration()
                currentDevice.flashMode = mode
                currentDevice.unlockForConfiguration()
            }
            catch {
                //fatalError("[CameraEngine] error lock configuration device")
            }
        }
    }
    
    fileprivate func configureTorch(_ mode: AVCaptureTorchMode) {
        if let currentDevice = self.cameraDevice.currentDevice, currentDevice.isTorchAvailable && currentDevice.torchMode != mode {
            do {
                try currentDevice.lockForConfiguration()
                currentDevice.torchMode = mode
                currentDevice.unlockForConfiguration()
            }
            catch {
                //fatalError("[CameraEngine] error lock configuration device")
            }
        }
    }
    
    open func switchCurrentDevice() {
        if self.isRecording == false {
            self.changeCurrentDevice((self.cameraDevice.currentPosition == .back) ? .front : .back)
        }
    }
    
    //MARK: Device I/O configuration
    
    fileprivate func configureInputDevice() {
        do {
            if let currentDevice = self.cameraDevice.currentDevice {
                try self.cameraInput.configureInputCamera(self.session, device: currentDevice)
            }
//            if let micDevice = self.cameraDevice.micCameraDevice {
//                try self.cameraInput.configureInputMic(self.session, device: micDevice)
//            }
        }
        catch CameraEngineDeviceInputErrorType.unableToAddCamera {
            //fatalError("[CameraEngine] unable to add camera as InputDevice")
        }
//        catch CameraEngineDeviceInputErrorType.UnableToAddMic {
//            fatalError("[CameraEngine] unable to add mic as InputDevice")
//        }
        catch {
            //fatalError("[CameraEngine] error initInputDevice")
        }
    }
    
    fileprivate func configureOutputDevice() {
        self.cameraOutput.configureCaptureOutput(self.session, sessionQueue: self.sessionQueue)
        self.cameraMetadata.previewLayer = self.previewLayer
        self.cameraMetadata.configureMetadataOutput(self.session, sessionQueue: self.sessionQueue, metadataType: self.metadataDetection)
    }
}

//MARK: Extension Device

public extension CameraEngine {
    
    public func focus(_ atPoint: CGPoint) {
        if let currentDevice = self.cameraDevice.currentDevice {
            if currentDevice.isFocusModeSupported(AVCaptureFocusMode.autoFocus) && currentDevice.isFocusPointOfInterestSupported {
                let focusPoint = self.previewLayer.captureDevicePointOfInterest(for: atPoint)
                do {
                    try currentDevice.lockForConfiguration()
                    currentDevice.focusPointOfInterest = CGPoint(x: focusPoint.x, y: focusPoint.y)
                    currentDevice.focusMode = AVCaptureFocusMode.autoFocus
                    
                    if currentDevice.isExposureModeSupported(AVCaptureExposureMode.autoExpose) {
                        currentDevice.exposureMode = AVCaptureExposureMode.autoExpose
                    }
                    currentDevice.unlockForConfiguration()
                }
                catch {
                    //fatalError("[CameraEngine] error lock configuration device")
                }
            }
        }
    }
}

//MARK: Extension capture

public extension CameraEngine {
    
    public func capturePhoto(_ blockCompletion: @escaping blockCompletionCapturePhoto) {
        self.cameraOutput.capturePhoto(blockCompletion)
    }
    
    public func startRecordingVideo(_ url: URL, blockCompletion: @escaping blockCompletionCaptureVideo) {
        if self.isRecording == false {
            self.sessionQueue.async(execute: { () -> Void in
                self.cameraOutput.startRecordVideo(blockCompletion, url: url)
            })
        }
    }
    
    public func stopRecordingVideo() {
        if self.isRecording {
            self.sessionQueue.async(execute: { () -> Void in
                self.cameraOutput.stopRecordVideo()
            })
        }
    }
    
    public func createGif(_ fileUrl: URL, frames: [UIImage], delayTime: Float, loopCount: Int = 0, completionGif: @escaping blockCompletionGifEncoder) {
        self.cameraGifEncoder.blockCompletionGif = completionGif
        self.cameraGifEncoder.createGif(fileUrl, frames: frames, delayTime: delayTime, loopCount: loopCount)
    }
}
