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
    
    override func viewDidLoad() {
        
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
        
        // Gestion du bouton d'envoie de photo
        let btnAdd = UIButton()
        btnAdd.backgroundColor = UIColor().secondary()
        btnAdd.alpha = 1.0
        btnAdd.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(btnAdd)
        btnAdd.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant:-20).isActive = true
        btnAdd.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        btnAdd.heightAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width*90/414)).isActive = true
        btnAdd.heightAnchor.constraint(equalTo: btnAdd.widthAnchor).isActive = true
        btnAdd.layer.cornerRadius = (UIScreen.main.bounds.width*90/414)/2
        btnAdd.layer.borderColor = UIColor().primary().cgColor
        btnAdd.layer.borderWidth = 5
        
        btnAdd.addTarget(self, action: #selector(btnAddPressed), for: .touchUpInside)
        
        self.view.addSubview(imgView)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFill
        
        imgView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        imgView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        imgView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        imgView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    func btnAddPressed() {
        let settingsForMonitoring = AVCapturePhotoSettings()
        settingsForMonitoring.flashMode = .auto
        settingsForMonitoring.isAutoStillImageStabilizationEnabled = true
        settingsForMonitoring.isHighResolutionPhotoEnabled = false
        stillImageOutput?.capturePhoto(with: settingsForMonitoring, delegate: self)
    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didCapturePhotoForResolvedSettings resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("didCapturePhotoForResolvedSettings")
    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishCaptureForResolvedSettings resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        print("didFinishCaptureForResolvedSettings")
    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        print("didFinishProcessingPhotoSampleBuffer")
        if let photoSampleBuffer = photoSampleBuffer {
            let photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
            let image = UIImage(data: photoData!)
            imgView.image = image// UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        }
    }
    
}
