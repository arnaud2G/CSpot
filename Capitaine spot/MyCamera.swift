//
//  MyCamera.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 10/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import AVFoundation
import UIKit

class MyCamera:UIViewController, AVCapturePhotoCaptureDelegate {
    
    var session: AVCaptureSession?
    var stillImageOutput: AVCapturePhotoOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    let imgView = UIImageView()
    
    deinit {
        print("deinit MyCamera")
        NotificationCenter.default.removeObserver(notifTakePic)
        NotificationCenter.default.removeObserver(notifValidePic)
    }
    
    var notifTakePic: AnyObject!
    var notifValidePic: AnyObject!
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        
        notifTakePic = NotificationCenter.default.addObserver(forName: CSpotNotif.takePic.name, object: nil, queue: OperationQueue.main, using: {
            (note: Notification) -> Void in
            self.takePic()
        })
        
        notifValidePic = NotificationCenter.default.addObserver(forName: CSpotNotif.validePic.name, object: nil, queue: OperationQueue.main, using: {
            (note: Notification) -> Void in
            self.validePic()
        })
        
        self.modalPresentationStyle = .overCurrentContext
        
        session = AVCaptureSession()
        session!.sessionPreset = AVCaptureSessionPresetPhoto
        
        let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let error1 as NSError {
            error = error1
            input = nil
            print(error!.localizedDescription)
        }
        
        if error == nil && session!.canAddInput(input) {
            session!.addInput(input)
        }
        
        stillImageOutput = AVCapturePhotoOutput()
        
        if session!.canAddOutput(stillImageOutput) {
            session!.addOutput(stillImageOutput)
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
            videoPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
            self.view.layer.addSublayer(videoPreviewLayer!)
            session!.startRunning()
        }
        
        videoPreviewLayer!.frame = UIScreen.main.bounds
        
        self.view.addSubview(imgView)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFill
        
        imgView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        imgView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        imgView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        imgView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func takePic() {
        let settingsForMonitoring = AVCapturePhotoSettings()
        settingsForMonitoring.flashMode = .auto
        settingsForMonitoring.isAutoStillImageStabilizationEnabled = true
        settingsForMonitoring.isHighResolutionPhotoEnabled = false
        stillImageOutput?.capturePhoto(with: settingsForMonitoring, delegate: self)
    }
    
    private func validePic() {
        Spot.newSpot.picture.value = imgView.image
    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        print("didFinishProcessingPhotoSampleBuffer")
        if let photoSampleBuffer = photoSampleBuffer {
            let photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
            let image = UIImage(data: photoData!)
            imgView.image = image
        }
    }
}
