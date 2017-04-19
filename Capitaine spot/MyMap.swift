//
//  MyMap.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 11/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit
import Mapbox
import Darwin
import MapboxGeocoder
import RxCocoa
import RxSwift


class SpotLocationViewController:UIViewController, MGLMapViewDelegate {
    
    var map:MGLMapView!
    var circle:UIView!
    
    let cancelButton = UIButton()
    let valideButton = UIButton()
    let tfSpot = UITextField()
    var spotName:Variable<String?> = Variable(nil)
    
    var distance:CGFloat!
    let mapInvocation:Double = 0.5
    var mapSize:CGFloat!
    
    var placeLabels = [UIPlacemarkButton]()
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.width/2 + 60)
        distance = sqrt(pow(center.x - UIScreen.main.bounds.width, 2) + pow(center.y - UIScreen.main.bounds.height, 2))
        mapSize = 0.8*UIScreen.main.bounds.width
        
        circle = UIView(frame: CGRect(origin: center, size: CGSize.zero))
        circle.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        circle.backgroundColor = .white
        circle.layer.cornerRadius = 0
        circle.clipsToBounds = true
        view.addSubview(circle)
        
        map = MGLMapView(frame: CGRect(origin: center, size: CGSize.zero), styleURL: URL(string: "mapbox://styles/mapbox/light-v9"))
        map.delegate = self
        map.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        map.layer.cornerRadius = 0
        map.clipsToBounds = true
        map.showsUserLocation = true
        view.addSubview(map)
        
        Spot.newSpot.coordinate
            .asObservable()
            .subscribe(onNext: {
                description in
                if let coordinate = description {
                    self.map.setCenter(coordinate, zoomLevel: 16, animated: true)
                } else if let coordinate = Spot.getLastCoo() {
                    self.map.setCenter(coordinate, zoomLevel: 16, animated: true)
                }
            }).addDisposableTo(disposeBag)
        
        placeLabels.append(UIPlacemarkButton(map: map))
        placeLabels.append(UIPlacemarkButton(map: map))
        placeLabels.append(UIPlacemarkButton(map: map))
        placeLabels.append(UIPlacemarkButton(map: map))
        placeLabels.append(UIPlacemarkButton(map: map))
    }
    
    deinit {
        print("deinit SpotLocationViewController")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateCircleAppear()
    }
    
    private func animateCircleDisappear(withValidate validated:Bool) {
        
        cancelButton.animDisappear(withDuration: 0.1, delay: 0.05, completionBlock: {})
        valideButton.animDisappear(withDuration: 0.1, delay: 0.05, completionBlock: {})
        
        if !validated {
            tfSpot.animDisappear(withDuration: 0.1, delay: 0.05, completionBlock: {})
        }
        
        animateLabelsDisappears(withDuration: 0.1, delay: 0.05, completionBlock: {
            let circleInvocation = self.mapInvocation*Double(self.distance/self.mapSize)
            self.map.resizeCircleWithPulseAinmation(0, duration: self.mapInvocation, delay: circleInvocation - self.mapInvocation)
            self.circle.resizeCircleWithPulseAinmation(0, duration: circleInvocation, completionHandler: {
                self.tfSpot.isHidden = true
                self.cancelButton.isHidden = true
                self.valideButton.isHidden = true
                self.dismiss(animated: false, completion: nil)
            })
        })
    }
    
    private func animateCircleAppear() {
        
        map.resizeCircleWithPulseAinmation(mapSize, duration: mapInvocation)
        let circleInvocation = mapInvocation*Double(distance/mapSize)
        circle.resizeCircleWithPulseAinmation(distance*2, duration: circleInvocation, completionHandler: {
            self.initLabels()
            self.displayTopScreen()
            self.startSearchAround()
            self.startObserveMap()
        })
    }
    
    func initLabels() {
        var lastView:UIView = map!
        for lbl in placeLabels {
            lbl.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(lbl)
            lbl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            lbl.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.leadingAnchor, constant:10).isActive = true
            lbl.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant:10).isActive = true
            
            lbl.setTitleColor(UIColor().primary(), for: .normal)
            lbl.alpha = 0
            
            lastView = lbl
        }
    }
    
    private func displayTopScreen() {
        
        // Position
        tfSpot.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tfSpot)
        tfSpot.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        tfSpot.heightAnchor.constraint(equalToConstant: 40).isActive = true
        tfSpot.topAnchor.constraint(equalTo: self.view.topAnchor, constant:40).isActive = true
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(cancelButton)
        
        cancelButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant:10).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        cancelButton.centerYAnchor.constraint(equalTo: tfSpot.centerYAnchor).isActive = true
        
        valideButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(valideButton)
        
        valideButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant:-10).isActive = true
        valideButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        valideButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        valideButton.centerYAnchor.constraint(equalTo: tfSpot.centerYAnchor).isActive = true
        
        tfSpot.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant:10).isActive = true
        tfSpot.trailingAnchor.constraint(equalTo: valideButton.leadingAnchor, constant:-10).isActive = true
        
        // Attributes
        tfSpot.placeholder = NSLocalizedString("Ou êtes vous ?", comment: "Ou êtes vous ?")
        tfSpot.alpha = 0
        
        tfSpot.layer.cornerRadius = 20
        tfSpot.unselectedStyle()
        tfSpot.isEnabled = false
        
        valideButton.setBackgroundImage(#imageLiteral(resourceName: "ok"), for: .normal)
        valideButton.setBackgroundImage(#imageLiteral(resourceName: "ok_disabled"), for: .disabled)
        cancelButton.setBackgroundImage(#imageLiteral(resourceName: "nook"), for: .normal)
        
        valideButton.alpha = 0
        cancelButton.alpha = 0
        
        // Observables
        tfSpot.rx.text
            .asObservable()
            .subscribe(onNext: {
                description in
                self.spotName.value = description
            }).addDisposableTo(disposeBag)
        
        spotName.asObservable()
            .subscribe(onNext: {
                description in
                self.tfSpot.text = description
                if let description = description, description != String() {
                    self.valideButton.isEnabled = true
                } else {
                    self.valideButton.isEnabled = false
                }
            }).addDisposableTo(disposeBag)
        
        valideButton.rx.tap
            .asObservable()
            .subscribe(onNext: {
                description in
                self.disposeBag = DisposeBag()
                Spot.newSpot.title.value = self.spotName.value!
                Spot.newSpot.coordinate.value = self.map.selectedAnnotations.first!.coordinate
                self.animateCircleDisappear(withValidate: true)
            }).addDisposableTo(disposeBag)
        
        cancelButton.rx.tap
            .asObservable()
            .subscribe(onNext: {
                description in
                self.disposeBag = DisposeBag()
                self.animateCircleDisappear(withValidate: false)
            }).addDisposableTo(disposeBag)
        
        // Animation
        self.tfSpot.animAppear(withDuration: 0.3, delay: 0.0, completionBlock: {
            self.valideButton.animAppear(withDuration: 0.3, delay: 0.0, completionBlock:{})
            self.cancelButton.animAppear(withDuration: 0.3, delay: 0.0, completionBlock:{})
        })
    }
    
    func animateLabelsAppears(withDuration duration:TimeInterval=0.3, delay:TimeInterval=0.1, completionBlock:@escaping ()->()) {
        
        var i = 0.0
        for lbl in placeLabels {
            lbl.animAppear(withDuration: duration, delay: i*delay, completionBlock: completionBlock)
            i = i + 1
        }
    }
    
    func animateLabelsDisappears(withDuration duration:TimeInterval=0.3, delay:TimeInterval=0.1, completionBlock:@escaping ()->()) {
        
        var sync = 0
        var i = 0.0
        for lbl in placeLabels {
            lbl.animDisappear(withDuration: duration, delay: Double(placeLabels.count)*delay - i*delay, completionBlock: {
                sync = sync + 1
                if sync == self.placeLabels.count {
                    completionBlock()
                }
            })
            i = i + 1
        }
    }
    
    private func startSearchAround() {
        
        if searching {return}
        
        let options = ReverseGeocodeOptions(coordinate: map.centerCoordinate)
        options.maximumResultCount = 5
        options.allowedScopes = [.pointOfInterest]
        
        _ = Geocoder.shared.geocode(options) {
            (placemarks, attribution, error) in
            guard let placemarks = placemarks else {
                return
            }
            
            var i = 0
            for placemark in placemarks {
                
                self.placeLabels[i].addPlacemark(placemark: placemark)
                i = i + 1
            }
            self.animateLabelsAppears(completionBlock: {})
        }
    }
    
    var searching: Bool = false {
        didSet {
            if searching != oldValue  {
                if searching {
                    _ = self.map.selectedAnnotations.map({
                        (a:MGLAnnotation) in
                        self.map.deselectAnnotation(a, animated: false)
                    })
                    self.spotName.value = String()
                    self.animateLabelsDisappears(completionBlock: {})
                }
            }
        }
    }
    
    private func startObserveMap() {
        map.rx.mapViewRegionIsChanging
            .asObservable()
            .debounce(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                (description:MGLMapView) in
                self.searching = false
                self.startSearchAround()
            }).addDisposableTo(disposeBag)
        
        map.rx.regionWillChangeAnimated
            .asObservable()
            .subscribe(onNext: {
                (description:MGLMapView) in
                self.searching = true
            }).addDisposableTo(disposeBag)
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        self.spotName.value = annotation.title!
    }
}

class UIPlacemarkButton:UIButton {
    
    var placemark:GeocodedPlacemark?
    var annotation = MGLPointAnnotation()
    
    let disposeBag = DisposeBag()
    
    convenience init(map:MGLMapView) {
        self.init(frame:CGRect.zero)
        map.addAnnotation(annotation)
        self.rx.tap
            .asObservable()
            .subscribe(onNext: {
                description in
                map.selectAnnotation(self.annotation, animated: true)
                self.animSelect(withDuration: 0.3)
            }).addDisposableTo(disposeBag)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addPlacemark(placemark:GeocodedPlacemark) {
        self.placemark = placemark
        annotation.coordinate = placemark.location.coordinate
        annotation.title = placemark.name
        self.setTitle(placemark.name, for: .normal)
    }
    
    
}
