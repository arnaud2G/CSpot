//
//  MyCamera.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 10/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import AVFoundation
import UIKit
import RxCocoa
import RxSwift

class MyCamera:UIViewController, AVCapturePhotoCaptureDelegate {
    
    var session: AVCaptureSession?
    var stillImageOutput: AVCapturePhotoOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var image:Variable<UIImage?> = Variable(nil)
    var flashMode:Variable<AVCaptureFlashMode?> = Variable(.auto)
    
    let disposeBag = DisposeBag()
    
    deinit {
        print("deinit MyCamera")
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        
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
        
        displayCameraFunction()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func displayCameraFunction() {
        
        // Image de fond
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(imgView)
        imgView.contentMode = .scaleAspectFill
        imgView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        imgView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        imgView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        imgView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        // Bouton back
        let btnBack = UIButton()
        btnBack.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(btnBack)
        btnBack.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant:20).isActive = true
        btnBack.topAnchor.constraint(equalTo: self.view.topAnchor, constant:20).isActive = true
        btnBack.widthAnchor.constraint(equalToConstant: 40).isActive = true
        btnBack.heightAnchor.constraint(equalToConstant: 40).isActive = true
        btnBack.layer.cornerRadius = 20
        btnBack.unselectedStyle()
        btnBack.setImage(#imageLiteral(resourceName: "skull-filled").withRenderingMode(.alwaysTemplate), for: .normal)
        btnBack.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        btnBack.rx.tap.subscribe(onNext:{
            [weak self] tap in
            self?.dismiss(animated: true, completion: nil)
        }).addDisposableTo(disposeBag)
        
        // Bouton flash
        let btnFlash = UIButton()
        btnFlash.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(btnFlash)
        btnFlash.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant:-20).isActive = true
        btnFlash.topAnchor.constraint(equalTo: self.view.topAnchor, constant:20).isActive = true
        btnFlash.widthAnchor.constraint(equalToConstant: 40).isActive = true
        btnFlash.heightAnchor.constraint(equalToConstant: 40).isActive = true
        btnFlash.layer.cornerRadius = 20
        btnFlash.unselectedStyle()
        btnFlash.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        btnFlash.rx.tap.subscribe(onNext:{
            [weak self] tap in
            self?.flashMode.value = nil
        }).addDisposableTo(disposeBag)
        
        // Boutons pick flash
        let btnFlash1 = UIButton()
        btnFlash1.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(btnFlash1)
        btnFlash1.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant:-20).isActive = true
        btnFlash1.topAnchor.constraint(equalTo: self.view.topAnchor, constant:20).isActive = true
        btnFlash1.widthAnchor.constraint(equalToConstant: 40).isActive = true
        btnFlash1.heightAnchor.constraint(equalToConstant: 40).isActive = true
        btnFlash1.layer.cornerRadius = 20
        btnFlash1.unselectedStyle()
        btnFlash1.setImage(#imageLiteral(resourceName: "flash_auto").withRenderingMode(.alwaysTemplate), for: .normal)
        btnFlash1.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        btnFlash1.rx.tap.subscribe(onNext:{
            [weak self] tap in
            self?.flashMode.value = .auto
        }).addDisposableTo(disposeBag)
        
        let btnFlash2 = UIButton()
        btnFlash2.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(btnFlash2)
        btnFlash2.rightAnchor.constraint(equalTo: btnFlash1.leftAnchor, constant:-10).isActive = true
        btnFlash2.topAnchor.constraint(equalTo: self.view.topAnchor, constant:20).isActive = true
        btnFlash2.widthAnchor.constraint(equalToConstant: 40).isActive = true
        btnFlash2.heightAnchor.constraint(equalToConstant: 40).isActive = true
        btnFlash2.layer.cornerRadius = 20
        btnFlash2.unselectedStyle()
        btnFlash2.setImage(#imageLiteral(resourceName: "flash_on").withRenderingMode(.alwaysTemplate), for: .normal)
        btnFlash2.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        btnFlash2.rx.tap.subscribe(onNext:{
            [weak self] tap in
            self?.flashMode.value = .on
        }).addDisposableTo(disposeBag)
        
        let btnFlash3 = UIButton()
        btnFlash3.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(btnFlash3)
        btnFlash3.rightAnchor.constraint(equalTo: btnFlash2.leftAnchor, constant:-10).isActive = true
        btnFlash3.topAnchor.constraint(equalTo: self.view.topAnchor, constant:20).isActive = true
        btnFlash3.widthAnchor.constraint(equalToConstant: 40).isActive = true
        btnFlash3.heightAnchor.constraint(equalToConstant: 40).isActive = true
        btnFlash3.layer.cornerRadius = 20
        btnFlash3.unselectedStyle()
        btnFlash3.setImage(#imageLiteral(resourceName: "flash_off").withRenderingMode(.alwaysTemplate), for: .normal)
        btnFlash3.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        btnFlash3.rx.tap.subscribe(onNext:{
            [weak self] tap in
            self?.flashMode.value = .off
        }).addDisposableTo(disposeBag)
        
        // Bouton d'envoi
        let btnTakePic = UIButton()
        btnTakePic.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(btnTakePic)
        btnTakePic.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        btnTakePic.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant:-30).isActive = true
        btnTakePic.heightAnchor.constraint(equalToConstant: 80).isActive = true
        btnTakePic.widthAnchor.constraint(equalToConstant: 80).isActive = true
        btnTakePic.layer.cornerRadius = 40
        btnTakePic.layer.borderWidth = 10
        btnTakePic.layer.borderColor = UIColor().primary().cgColor
        btnTakePic.backgroundColor = UIColor().secondaryPopUp()
        btnTakePic.clipsToBounds = true
        btnTakePic.tintColor = UIColor().secondary()
        btnTakePic.addTarget(self, action: #selector(self.takePic(sender:)), for: .touchUpInside)
        
        // Bouton d'envoi
        let btnValidePic = UIButton()
        btnValidePic.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(btnValidePic)
        btnValidePic.centerYAnchor.constraint(equalTo: btnTakePic.centerYAnchor).isActive = true
        btnValidePic.centerXAnchor.constraint(equalTo: btnFlash.centerXAnchor).isActive = true
        btnValidePic.widthAnchor.constraint(equalToConstant: 60).isActive = true
        btnValidePic.heightAnchor.constraint(equalToConstant: 60).isActive = true
        btnValidePic.layer.cornerRadius = 30
        btnValidePic.unselectedStyle()
        btnValidePic.setImage(#imageLiteral(resourceName: "ship").withRenderingMode(.alwaysTemplate), for: .normal)
        btnValidePic.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        btnValidePic.rx.tap.subscribe(onNext:{
            tap in
            Spot.newSpot.picture.value = self.image.value
            let transitionStoryboard = UIStoryboard(name: "Transition", bundle: nil)
            let vueC1 = transitionStoryboard.instantiateInitialViewController()
            self.navigationController?.pushViewController(vueC1!, animated: false)
            
        }).addDisposableTo(disposeBag)
        
        image.asObservable().subscribe(onNext:{
            image in
            if let image = image {
                imgView.image = image
                btnTakePic.backgroundColor = UIColor().primary()
                btnTakePic.setImage(#imageLiteral(resourceName: "restart").withRenderingMode(.alwaysTemplate), for: .normal)
                btnValidePic.isHidden = false
            } else {
                imgView.image = nil
                btnTakePic.backgroundColor = UIColor().secondaryPopUp()
                btnTakePic.setImage(nil, for: .normal)
                btnValidePic.isHidden = true
            }
        }).addDisposableTo(disposeBag)
        
        flashMode.asObservable().subscribe(onNext:{
            flashMode in
            if let flashMode = flashMode {
                btnFlash1.isHidden = true
                btnFlash2.isHidden = true
                btnFlash3.isHidden = true
                btnFlash.isHidden = false
                switch flashMode {
                case .auto:
                    btnFlash.setImage(#imageLiteral(resourceName: "flash_auto").withRenderingMode(.alwaysTemplate), for: .normal)
                case .on:
                    btnFlash.setImage(#imageLiteral(resourceName: "flash_on").withRenderingMode(.alwaysTemplate), for: .normal)
                case .off:
                    btnFlash.setImage(#imageLiteral(resourceName: "flash_off").withRenderingMode(.alwaysTemplate), for: .normal)
                }
            } else {
                btnFlash.isHidden = true
                btnFlash1.isHidden = false
                btnFlash2.isHidden = false
                btnFlash3.isHidden = false
            }
        }).addDisposableTo(disposeBag)
    }
    
    let imfView = UIImageView(image: #imageLiteral(resourceName: "restart").withRenderingMode(.alwaysTemplate))
    func takePic(sender:UIButton) {
        
        if image.value == nil {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6.0, options: .curveEaseIn, animations: {
                sender.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            })
            
            let settingsForMonitoring = AVCapturePhotoSettings()
            if let flashMode = flashMode.value {
                settingsForMonitoring.flashMode = flashMode
            } else {
                settingsForMonitoring.flashMode = .auto
            }
            settingsForMonitoring.isHighResolutionPhotoEnabled = false
            stillImageOutput?.capturePhoto(with: settingsForMonitoring, delegate: self)
        } else {
            image.value = nil
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6.0, options: .beginFromCurrentState, animations: {
                sender.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            })
        }
    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        print("didFinishProcessingPhotoSampleBuffer")
        if let photoSampleBuffer = photoSampleBuffer {
            let photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
            self.image.value = UIImage(data: photoData!)
        }
    }
}
