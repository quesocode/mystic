//
//  ViewController.swift
//  CameraEngine2
//
//  Created by Remi Robert on 24/12/15.
//  Copyright © 2015 Remi Robert. All rights reserved.
//
func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

import UIKit
import FCFileManager
import AVFoundation
import CoreMotion

enum ModeCapture {
    case photo
    case video
    case gif
}

@objc class CameraViewController: UIViewController {

    let cameraEngine = CameraEngine()
    var currentMaxAccelX: Double = 0.0
    var currentMaxAccelY: Double = 0.0
    var currentMaxAccelZ: Double = 0.0
    var currentMaxRotX: Double = 0.0
    var currentMaxRotY: Double = 0.0
    var currentMaxRotZ: Double = 0.0
    var buttonSwitch: CameraSwitch!
    var buttonTrigger: CameraShutter!
    var buttonTorch: UIButton!
    var buttonFlash: CameraFlash!
    var accessView:UIView?
    var buttonAlbum: CameraAlbum!
    var buttonClose: CameraClose!
    var buttonSteady: CameraSteady!
    var buttonGrid: CameraGrid!
    var topBar: CameraBar!
    var bottomBar: CameraBar!
    var gridView: CameraGridView?
    var focalView: CameraFocalPoint?
    var buttonSessionPresset: UIButton!
    var buttonModeCapture: UIButton!
    var labelModeCapture: UILabel!
    var labelDuration: UILabel!
    var rotationView: UIView!
    var rotationLevel: UIView!
    var rotationLeft: UIView!
    var rotationRight: UIView!
    var photoFrame: CGRect = CGRect.zero
    var saveOriginal: Bool = false
    let motionManager = CMMotionManager()
    fileprivate var currentModeCapture: ModeCapture = .photo
    fileprivate var frames = Array<UIImage>()
    weak var delegate:AnyObject?
    var finished: ((UIImage?, CameraViewController?) -> Void)?
    var close: ((CameraViewController?) -> Void)?
    var album: ((CameraViewController?) -> Void)?

    var build: ((UIView?, CameraViewController?) -> Void)?
    
    @IBAction func changeModeCapture(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "Mode capture", message: "Change the capture mode photo / video", preferredStyle: UIAlertControllerStyle.actionSheet)

        alertController.addAction(UIAlertAction(title: "Photo", style: UIAlertActionStyle.default, handler: { (_) -> Void in
            self.labelModeCapture.text = "Photo"
            self.labelDuration.isHidden = true
            self.currentModeCapture = .photo
        }))
        
        alertController.addAction(UIAlertAction(title: "Video", style: UIAlertActionStyle.default, handler: { (_) -> Void in
            self.labelModeCapture.text = "Video"
            self.currentModeCapture = .video
        }))
        
        alertController.addAction(UIAlertAction(title: "GIF", style: UIAlertActionStyle.default, handler: { (_) -> Void in
            self.labelModeCapture.text = "GIF"
            self.currentModeCapture = .gif
            self.frames.removeAll()
            self.labelDuration.text = "5"
        }))

        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func changeDetectionMode(_ sender: AnyObject) {
        let detectionCompatible = self.cameraEngine.compatibleDetectionMetadata()
        
        let alertController = UIAlertController(title: "Metadata Detection", message: "Change the metadata detection type", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        for currentDetectionMode in detectionCompatible {
            alertController.addAction(UIAlertAction(title: currentDetectionMode.description(), style: UIAlertActionStyle.default, handler: { (_) -> Void in
                self.cameraEngine.metadataDetection = currentDetectionMode
            }))
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func changeFocusCamera(_ sender: AnyObject) {
        let focusCompatible = self.cameraEngine.compatibleCameraFocus()
        
        let alertController = UIAlertController(title: "Camera focus", message: "Change the focus camera mode, compatible with yours device", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        for currentFocusMode in focusCompatible {
            alertController.addAction(UIAlertAction(title: currentFocusMode.description(), style: UIAlertActionStyle.default, handler: { (_) -> Void in
                self.cameraEngine.cameraFocus = currentFocusMode
            }))
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func changePressetCameraPhoto() {
        let pressetCompatible = self.cameraEngine.compatibleSessionPresset()
        
        let alertController = UIAlertController(title: "Session presset", message: "Change the presset of the session, compatible with yours device", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        for currentPresset in pressetCompatible {
            alertController.addAction(UIAlertAction(title: currentPresset.foundationPreset(), style: UIAlertActionStyle.default, handler: { (_) -> Void in
                self.cameraEngine.sessionPresset = currentPresset
            }))
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func changePressetVideoEncoder() {
        let pressetCompatible = self.cameraEngine.compatibleVideoEncoderPresset()
        
        let alertController = UIAlertController(title: "Video encoder presset", message: "Change the video encoder presset, to change the resolution of the ouput video.", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        for currentPresset in pressetCompatible {
            alertController.addAction(UIAlertAction(title: currentPresset.description(), style: UIAlertActionStyle.default, handler: { (_) -> Void in
                self.cameraEngine.videoEncoderPresset = currentPresset
            }))
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func changePressetSession(_ sender: AnyObject) {
        switch self.currentModeCapture {
        case .photo, .gif: self.changePressetCameraPhoto()
        case .video: self.changePressetVideoEncoder()
        }
    }
    
    @IBAction func changeTorchMode(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "Torch mode", message: "Change the torch mode", preferredStyle: UIAlertControllerStyle.actionSheet)

        alertController.addAction(UIAlertAction(title: "On", style: UIAlertActionStyle.default, handler: { (_) -> Void in
            self.cameraEngine.torchMode = .on
        }))
        alertController.addAction(UIAlertAction(title: "Off", style: UIAlertActionStyle.default, handler: { (_) -> Void in
            self.cameraEngine.torchMode = .off
        }))
        alertController.addAction(UIAlertAction(title: "Auto", style: UIAlertActionStyle.default, handler: { (_) -> Void in
            self.cameraEngine.torchMode = .auto
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func changeFlashMode(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "Flash mode", message: "Change the flash mode", preferredStyle: UIAlertControllerStyle.actionSheet)

        alertController.addAction(UIAlertAction(title: "On", style: UIAlertActionStyle.default, handler: { (_) -> Void in
            self.cameraEngine.flashMode = .on
        }))
        alertController.addAction(UIAlertAction(title: "Off", style: UIAlertActionStyle.default, handler: { (_) -> Void in
            self.cameraEngine.flashMode = .off
        }))
        alertController.addAction(UIAlertAction(title: "Auto", style: UIAlertActionStyle.default, handler: { (_) -> Void in
            self.cameraEngine.flashMode = .auto
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func captureVideo() {
        if self.cameraEngine.isRecording == false {
            guard let url = CameraEngineFileManager.documentPath("video.mp4") else {
                return
            }
            
            self.cameraEngine.startRecordingVideo(url, blockCompletion: { (url, error) -> (Void) in
                
//                let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("previewController")
                
                CameraEngineFileManager.saveVideo(url!, blockCompletion: { (success, error) -> (Void) in
                    //print("error saving video : \(error)")
                })
                
//                (controller as! PreviewViewController).media = Media.Video(url: url!)
//                self.presentViewController(controller, animated: true, completion: nil)
            })
        }
        else {
            self.cameraEngine.stopRecordingVideo()
        }
    }
    
    fileprivate func capturePhoto() {
        self.buttonTrigger.isEnabled=false
        self.cameraEngine.capturePhoto { (image: UIImage?, error: NSError?) -> (Void) in
            DispatchQueue.main.async(execute: { () -> Void in
                if let image = image {
                    
                    if self.currentModeCapture == .gif {
                        self.frames.append(image)
                        if (self.frames.count == 5) {
                            guard let url = CameraEngineFileManager.documentPath("animated.gif") else {
                                return
                            }
                            self.cameraEngine.createGif(url, frames: self.frames, delayTime: 0.1, completionGif: { (success, url) -> (Void) in

                            })
                            return
                        }

                    }
                    else {
                        if self.saveOriginal == true
                        {
                            CameraEngineFileManager.savePhoto(image, blockCompletion: { (success, error) -> (Void) in
                                if(error != nil) {
                                    self.buttonTrigger.isEnabled=true
                                    print("error save image : \(String(describing: error))")
                                    return
                                }
                                self.finished?(image,self)
                            })
                        }
                        else
                        {
                            self.finished?(image, self)
                        }

                    }
                }
            })
        }
    }
    
    @IBAction func capturePhoto(_ sender: AnyObject) {
        switch self.currentModeCapture {
        case .photo, .gif: self.capturePhoto()
        case .video: self.captureVideo()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = event!.allTouches!.first {
            let position = touch.location(in: self.view)
            if self.topBar.frame.contains(position) || self.bottomBar.frame.contains(position) { return; }
            self.cameraEngine.focus(position)
            if self.focalView == nil {
                let w = CGFloat(66.0)
                self.focalView = CameraFocalPoint.init(frame: CGRect(x: position.x - w*0.5, y: position.y - w*0.5, width: w, height: w))
                self.focalView?.alpha=0.0
                self.focalView?.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                self.view.addSubview(self.focalView!)
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
                    self.focalView?.transform = CGAffineTransform.identity
                    self.focalView?.alpha = 1.0
                }, completion: { (f) in
                    delay(2.5)
                    {
                        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                            self.focalView?.alpha = 0;
                            }, completion: { (f2) in
                                self.focalView?.removeFromSuperview()
                                self.focalView = nil
                        })
                    }
                })
            }
            else
            {
                self.focalView?.alpha=0.0
                self.focalView?.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                self.focalView!.center = position
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
                    self.focalView?.transform = CGAffineTransform.identity
                    self.focalView?.alpha = 1.0
                    }, completion: { (f) in
                        delay(2.5)
                        {
                            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                                self.focalView?.alpha = 0;
                                }, completion: { (f2) in
                                    self.focalView?.removeFromSuperview()
                                    self.focalView = nil
                            })
                        }
                })
                
            }
        }
    }
    func toggleFlash(_ sender: CameraFlash?)
    {
        var state:UIImagePickerControllerCameraFlashMode = (sender?.flashMode)!
        var f:AVCaptureFlashMode = .auto
        switch(state)
        {
            case .off:
                state = .auto
                f = .auto
                break
            case .on:
                state = .off
                f = .off
                break
            default:
                state = .on
                f = .on
                break;
        }
        self.cameraEngine.flashMode = f
        sender?.flashMode = state
    }
    func toggleFlashMode(_ state: UIImagePickerControllerCameraFlashMode)
    {
        if state == .off {
            self.cameraEngine.flashMode = .off
        }
        else if state == .on {
            self.cameraEngine.flashMode = .on
        }
        else if state == .auto {
            self.cameraEngine.flashMode = .auto
        }
        
    }
    @IBAction func switchCamera(_ sender: AnyObject) {
        self.cameraEngine.switchCurrentDevice()
    }
    func toggleGrid(_ sender: AnyObject?)
    {
        if self.gridView==nil
        {
            self.gridView = CameraGridView.init(frame: CGRect(x: 0, y: self.topBar.frame.size.height, width: self.view.frame.size.width, height: self.view.frame.size.height - self.topBar.frame.size.height - self.bottomBar.frame.size.height))
            self.gridView?.alpha=0.0
            self.view.insertSubview(self.gridView!, belowSubview: self.topBar)
            UIView.animate(withDuration: 0.15, animations: {
                self.gridView?.alpha=1.0
            })
        }
        else
        {
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveLinear, animations: {
                    self.gridView?.alpha=0.0
                }, completion: { (f) in
                    self.gridView?.removeFromSuperview()
                    self.gridView=nil
            })
            
        }
    }
    func toggleSteady(_ sender: CameraSteady?)
    {
        if self.rotationView.superview != nil {
            self.rotationView.removeFromSuperview()
        }
        else
        {
            self.view.addSubview(self.rotationView)
        }
    }
    func album(_ sender: AnyObject?)
    {
        album?(self)
    }
    func close(_ sender: AnyObject?)
    {
        close?(self)
    }
    override func viewDidLayoutSubviews() {
        let layer = self.cameraEngine.previewLayer
        layer?.frame = self.view.bounds
        self.view.layer.insertSublayer(layer!, at: 0)
        self.view.layer.masksToBounds = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.buttonTrigger.isEnabled=true
    }
    override func loadView() {
        
        let nview = UIView.init(frame: UIScreen.main.bounds)
        nview.backgroundColor = UIColor.black
        self.buttonTrigger = CameraShutter.init(frame: CGRect(x: 0.0, y: nview.frame.size.height-60.0-25.0, width: 60.0, height: 60.0));
        self.buttonTrigger.center = CGPoint(x: nview.frame.size.width*0.5, y: self.buttonTrigger.center.y)
        self.buttonTrigger.addTarget(self, action: #selector(CameraViewController.capturePhoto(_:)), for: .touchUpInside)
        self.topBar = CameraBar.init(frame: CGRect(x: 0, y: 0, width: nview.frame.size.width, height: 70.0))
        self.topBar.effect = UIBlurEffect.init(style: UIBlurEffectStyle.dark)
        self.topBar.contentView.backgroundColor = UIColor.init(red: 20.0/255.0, green: 20.0/255.0, blue: 18.0/255.0, alpha: 0.33)
        self.buttonFlash = CameraFlash.init(frame: CGRect(x: (70.0-54.0)/2.0, y: (70.0-54.0)/2.0, width: 54.0, height: 54.0))
        self.buttonFlash.addTarget(self, action: #selector(CameraViewController.toggleFlash(_:)), for: .touchUpInside)
        self.topBar.contentView.addSubview(self.buttonFlash)
        self.buttonSwitch = CameraSwitch.init(frame: CGRect(x: self.topBar.frame.size.width-((70.0-54.0)/2.0) - 54.0, y: (70.0-54.0)/2.0, width: 54.0, height: 54.0))
        self.buttonSwitch.addTarget(self, action: #selector(CameraViewController.switchCamera(_:)), for: .touchUpInside)
        self.topBar.contentView.addSubview(self.buttonSwitch)
        self.buttonGrid = CameraGrid.init(frame: CGRect(x: self.topBar.frame.size.width/2.0 - 54.0/2.0 - 63.0, y: (70.0-54.0)/2.0, width: 54.0, height: 54.0))
        self.buttonGrid.addTarget(self, action: #selector(CameraViewController.toggleGrid(_:)), for: .touchUpInside)
        self.buttonSteady = CameraSteady.init(frame: CGRect(x: self.topBar.frame.size.width/2.0 - 54.0/2.0 + 63.0, y: (70.0-54.0)/2.0, width: 54.0, height: 54.0))
        self.buttonSteady.addTarget(self, action: #selector(CameraViewController.toggleSteady(_:)), for: .touchUpInside)
        self.topBar.contentView.addSubview(self.buttonGrid)
        self.topBar.contentView.addSubview(self.buttonSteady)

        self.bottomBar = CameraBar.init(frame: CGRect(x: 0, y: nview.frame.size.height-110.0, width: nview.frame.size.width, height: 110.0));
        self.bottomBar.effect = UIBlurEffect.init(style: UIBlurEffectStyle.dark)
        self.bottomBar.contentView.backgroundColor = UIColor.init(red: 20.0/255.0, green: 20.0/255.0, blue: 18.0/255.0, alpha: 0.33)

        self.buttonClose = CameraClose.init(frame: CGRect(x: 41.0, y: (110.0-46.0)/2.0, width: 46.0, height: 46.0))
        self.buttonClose.addTarget(self, action: #selector(CameraViewController.close(_:)), for: .touchUpInside)
        self.bottomBar.contentView.addSubview(self.buttonClose)
        self.buttonAlbum = CameraAlbum.init(frame: CGRect(x: self.bottomBar.frame.size.width-41.0 - 54.0, y: (110.0-54.0)/2.0, width: 54.0, height: 54.0))
        self.buttonAlbum.addTarget(self, action: #selector(CameraViewController.album(_:)), for: .touchUpInside)
        self.bottomBar.contentView.addSubview(self.buttonAlbum)
        nview.addSubview(self.topBar)
        nview.addSubview(self.bottomBar)
        nview.addSubview(self.buttonTrigger)
        let c = CGPoint(x: nview.frame.size.width*0.5, y: nview.frame.size.height*0.5)
        self.rotationView = UIView.init(frame: CGRect(x: 0, y: (nview.frame.size.height-self.bottomBar.frame.size.height - self.topBar.frame.size.height)*0.5 + self.topBar.frame.size.height - 1.5, width: nview.frame.size.width, height: 3.0))
        let rleft = UIView.init(frame: CGRect(x: 0, y: 0, width: ((nview.frame.size.width - 300)/2.0)-15.0, height: self.rotationView.frame.size.height))
        let rright = UIView.init(frame: CGRect(x: nview.frame.size.width - ((nview.frame.size.width - 300)/2.0)+15.0, y: 0, width: ((nview.frame.size.width - 300)/2.0)-15.0, height: self.rotationView.frame.size.height))
        self.photoFrame.size.height = nview.frame.size.height-self.bottomBar.frame.size.height - self.topBar.frame.size.height
        self.photoFrame.size.width = nview.frame.size.width
        self.photoFrame.origin.y = self.topBar.frame.size.height
        self.rotationLevel = UIView.init(frame: CGRect(x: c.x-150, y: self.rotationView.frame.size.height/2.0 - 0.5 , width: 300, height: 1.0))
        self.rotationLevel.backgroundColor = UIColor.white
        rleft.backgroundColor = self.rotationLevel.backgroundColor
        rright.backgroundColor = self.rotationLevel.backgroundColor
        self.rotationLeft = rleft
        self.rotationRight = rright
        self.rotationView.addSubview(self.rotationLevel)
        self.rotationView.addSubview(rleft)
        self.rotationView.addSubview(rright)
        self.build?(nview, self)
        self.build = nil
        
        self.view = nview

    }
    func requestPermission(_ complete: @escaping (_ status: PHAuthorizationStatus) -> ()){
        let currentStatus = PHPhotoLibrary.authorizationStatus()
        switch currentStatus {
        case .authorized:
            complete(.authorized)
            break
        //handle authorized status
        case .denied:
            complete(.denied)
            break
        case .restricted:
            complete(.restricted)
            break
        //handle denied status
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization() { (status2) -> Void in
                complete(status2)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        
//        
//        requestPermission { (status) in
//            
//            let cameraMediaType = AVMediaTypeVideo
//            var wasDenied:Bool = false
//            var wasRestricted:Bool = false
//            switch status {
//                
//            // The client is authorized to access the hardware supporting a media type.
//            case .Authorized:
//                break
//                
//                // The client is not authorized to access the hardware for the media type. The user cannot change
//            // the client's status, possibly due to active restrictions such as parental controls being in place.
//            case .Restricted:
//                wasRestricted = true
//                break
//                
//            // The user explicitly denied access to the hardware supporting a media type for the client.
//            case .Denied:
//                wasDenied = true
//                break
//                
//            // Indicates that the user has not yet made a choice regarding whether the client can access the hardware.
//            case .NotDetermined:
//                // Prompting user for the permission to use the camera.
//                AVCaptureDevice.requestAccessForMediaType(cameraMediaType) { granted in
//                    
//                }
//            }
//            
//            if(wasDenied || wasRestricted)
//            {
//                let spacing:CGFloat = 20;
//                let access:UIView = UIView.init(frame: CGRectWH(self.view.bounds, self.view.bounds.size.width, self.view.bounds.size.height - self.topBar.frame.size.height - self.bottomBar.frame.size.height))
//                let iconTypeInt = MysticInt(MysticIconType.Alert.rawValue)
//
//                let iconType = NSNumber.init(unsignedInt:iconTypeInt)
//                let iconView = UIImageView.init(frame: CGRectMake(0,0,70,70))
//                MysticImage.image(iconType, size: CGSizeMake(60,60), color: UIColor.init(red: 0.87, green: 0.56, blue: 0.22, alpha: 1.0))
//                iconView.contentMode = .Center;
//                let titleLabel:UILabel = UILabel.init(frame: CGRectMake(0, 0, 200, 60))
//                let msgLabel = UILabel.init(frame: CGRectMake(0, 0, self.view.bounds.size.width - 60, 200))
//                msgLabel.numberOfLines = 0;
//                
//                let btn:MysticButton = MysticButton(MysticAttrString.string("OPEN SETTINGS", style: MysticStringStyleAccessButton), action: { (_) in
//                    UIApplication.sharedApplication().openURL(NSURL.init(string: UIApplicationOpenSettingsURLString)!)
//                })
//                let title:String = wasDenied ? "CAMERA ACCESS DENIED" : "CAMERA RESTRICTED"
//                let descrpition = wasDenied ? "Bummer...\n\nYou need to allow Mystic access\nto your photos before you can\nchoose one to edit. \n\nTap OPEN SETTINGS below\nand turn Photos on." : "Hmm... for some weird reason access to your photo library is restricted?\n\nTap OPEN SETTINGS below\nand turn Photos on."
//                
//                titleLabel.attributedText =  MysticAttrString.string(title, style:MysticStringStyleAccessTitle).attrString
//                msgLabel.attributedText = MysticAttrString.string(descrpition, style:MysticStringStyleAccessDescription).attrString
//                titleLabel.sizeToFit()
//                msgLabel.sizeToFit()
//                btn.sizeToFit()
//                access.addSubview(iconView)
//                access.addSubview(titleLabel)
//                access.addSubview(msgLabel)
//                access.addSubview(btn)
//                
//                var accessSize = titleLabel.frame.size
//                accessSize.width = max(max(CGRectGetWidth(titleLabel.frame), CGRectGetWidth(msgLabel.frame)), CGRectGetWidth(btn.frame))
//                accessSize.height += (spacing*CGFloat(access.subviews.count))
//                accessSize.height += CGRectGetHeight(iconView.frame) + CGRectGetHeight(titleLabel.frame) + CGRectGetHeight(msgLabel.frame) + CGRectGetHeight(btn.frame)
//                iconView.center = CGPointAddY(MCenterOfRect(access.bounds), -accessSize.height/2)
//                titleLabel.frame = CGRectOffset(titleLabel.frame, 0,CGRectGetMaxY(iconView.frame) + spacing*1.5)
//                let messageFrame = CGRectOffset(msgLabel.frame, 0,CGRectGetMaxY(titleLabel.frame) + spacing)
//                msgLabel.frame = CGRectWH(messageFrame, min(CGRectGetWidth(messageFrame), CGRectInset(access.bounds, spacing*2, 0).size.width), CGRectGetHeight(messageFrame))
//                
//                btn.frame = CGRectOffset(CGRectInset(btn.frame, -spacing/1.5,-spacing/3), 0, CGRectGetMaxY(msgLabel.frame) + spacing*3)
//                MBorder(btn, UIColor.init(red: 0.91, green: 0.34, blue: 0.42, alpha: 1.0), 1.5)
//                btn.layer.cornerRadius = CGRectGetHeight(btn.frame)/2
//                titleLabel.center = CGPointX(titleLabel.center, iconView.center.x)
//                msgLabel.center = CGPointX(msgLabel.center, iconView.center.x)
//                btn.center = CGPointX(btn.center, iconView.center.x)
//                self.view.addSubview(access)
//                self.accessView = access
//                return
//            }
        
            
            self.cameraEngine.startSession()
            self.cameraEngine.sessionPresset = .photo
            self.cameraEngine.cameraFocus = .autoFocus
        self.motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler:
                {
                    (deviceMotion, error) -> Void in
                    
                    if(error == nil) {
                        if self.rotationView?.superview != nil {
                            let rotate = atan2((deviceMotion?.gravity.x)!, (deviceMotion?.gravity.y)!)-Double.pi
                            if rotate > -0.02 || rotate < -6.26 {
                                self.rotationLevel.backgroundColor = UIColor.green
                            }
                            else {
                                self.rotationLevel.backgroundColor = UIColor.white
                                
                            }
                            
                            self.rotationRight.backgroundColor = self.rotationLevel.backgroundColor
                            self.rotationLeft.backgroundColor = self.rotationLevel.backgroundColor
                            
                            self.rotationLevel.transform = CGAffineTransform(rotationAngle: CGFloat(rotate))
                        }
                    } else {
                        //handle the error
                    }
        })
            
//                    
//            self.motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {(motion: CMDeviceMotion?, error:NSError?) in
//                if self.rotationView?.superview != nil {
//                    let rotate = atan2((motion?.gravity.x)!, (motion?.gravity.y)!)-M_PI
//                    if rotate > -0.02 || rotate < -6.26 {
//                        self.rotationLevel.backgroundColor = UIColor.green
//                    }
//                    else {
//                        self.rotationLevel.backgroundColor = UIColor.white
//                        
//                    }
//                    
//                    self.rotationRight.backgroundColor = self.rotationLevel.backgroundColor
//                    self.rotationLeft.backgroundColor = self.rotationLevel.backgroundColor
//                    
//                    self.rotationLevel.transform = CGAffineTransform(rotationAngle: CGFloat(rotate))
//                }
//            } as! CMDeviceMotionHandler)
//        }
        
        
    }
}

