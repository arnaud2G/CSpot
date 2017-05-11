//
//  DescribeMapViewController.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 10/05/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit
import Mapbox
import Darwin
import MapboxGeocoder
import RxCocoa
import RxSwift

class DescribeMapViewController:UIViewController, MGLMapViewDelegate {
    
    // Top view
    @IBOutlet weak var btnUncheck: UIButton!
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var btnToCenter: UIButton!
    @IBOutlet weak var tfWhereAreU: UITextField!
    
    // Middle view
    @IBOutlet weak var mapView: MGLMapView!
    
    // Bottom view
    @IBOutlet weak var lbl1: UIPlacemarkButton!
    @IBOutlet weak var lbl2: UIPlacemarkButton!
    @IBOutlet weak var lbl3: UIPlacemarkButton!
    @IBOutlet weak var lbl4: UIPlacemarkButton!
    @IBOutlet weak var lbl5: UIPlacemarkButton!
    
    // Paramètres
    var spot:Variable<GeocodedPlacemark?> = Variable(nil)
    
    var disposeBag = DisposeBag()
    
    deinit {
        print("deinit DescribeMapViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayTop()
        displayMap()
        displayLbl()
        
        startObserve()
    }
    
    private func startObserve() {
        mapView.rx.mapViewRegionIsChanging
            .asObservable()
            .debounce(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                [weak self] (description:MGLMapView) in
                self?.searching = false
                self?.startSearchAround()
            }).addDisposableTo(disposeBag)
        
        mapView.rx.regionWillChangeAnimated
            .asObservable()
            .subscribe(onNext: {
                [weak self] (description:MGLMapView) in
                self?.searching = true
            }).addDisposableTo(disposeBag)
        
        spot.asObservable().subscribe(onNext:{
            [weak self] spot in
            self?.btnCheck.isEnabled = spot != nil
            if spot == nil {
                self?.btnCheck.unselectedStyle()
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6.0, options: .curveEaseIn, animations: {
                    self?.btnCheck.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                })
            } else {
                self?.btnCheck.selectedStyle()
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6.0, options: .curveEaseIn, animations: {
                    self?.btnCheck.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                })
            }
            self?.tfWhereAreU.text = spot?.name ?? String()
            
        }).addDisposableTo(disposeBag)
    }
    
    private func startSearchAround() {
        
        if searching {return}
        
        let tmpTabl:[UIPlacemarkButton] = [lbl1,lbl2,lbl3,lbl4,lbl5]
        let options = ReverseGeocodeOptions(coordinate: mapView.centerCoordinate)
        options.maximumResultCount = 5
        options.allowedScopes = [.pointOfInterest]
        
        _ = Geocoder.shared.geocode(options) {
            (placemarks, attribution, error) in
            guard let placemarks = placemarks else {
                return
            }
            
            var i = 0
            for placemark in placemarks {
                tmpTabl[i].addPlacemark(placemark: placemark)
                i = i + 1
            }
        }
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    var searching: Bool = false {
        didSet {
            let tmpTabl:[UIPlacemarkButton] = [lbl1,lbl2,lbl3,lbl4,lbl5]
            if searching != oldValue  {
                if searching {
                    _ = mapView.selectedAnnotations.map({
                        (a:MGLAnnotation) in
                        mapView.deselectAnnotation(a, animated: false)
                    })
                    spot.value = nil
                    _ = tmpTabl.map{$0.placemark = nil}
                }
            }
        }
    }
    
    private func displayMap() {
        
        let mapSize = UIScreen.main.bounds.width - 20
        mapView.styleURL = URL(string: "mapbox://styles/mapbox/light-v9")
        mapView.delegate = self
        mapView.layer.cornerRadius = mapSize/2
        mapView.clipsToBounds = true
        mapView.showsUserLocation = true
        mapView.setCenter(User.current.location.value!, zoomLevel: 16, animated: true)
    }
    
    private func displayTop() {
        
        tfWhereAreU.placeholder = NSLocalizedString("Ou êtes vous ?", comment: "Ou êtes vous ?")
        
        tfWhereAreU.layer.cornerRadius = 20
        tfWhereAreU.unselectedStyle()
        tfWhereAreU.isEnabled = false
        
        btnToCenter.setImage(#imageLiteral(resourceName: "pirate").withRenderingMode(.alwaysTemplate), for: .normal)
        btnToCenter.tintColor = UIColor().primary()
        
        btnCheck.unselectedStyle()
        btnCheck.layer.cornerRadius = 20
        btnCheck.setImage(#imageLiteral(resourceName: "ship").withRenderingMode(.alwaysTemplate), for: .normal)
        btnCheck.addTarget(self, action: #selector(self.btnCheckPressed(sender:)), for: .touchUpInside)
        
        btnUncheck.unselectedStyle()
        btnUncheck.layer.cornerRadius = 20
        btnUncheck.setImage(#imageLiteral(resourceName: "skull").withRenderingMode(.alwaysTemplate), for: .normal)
        btnUncheck.addTarget(self, action: #selector(self.btnUncheckPressed(sender:)), for: .touchUpInside)
    }
    
    func btnUncheckPressed(sender:UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func btnCheckPressed(sender:UIButton) {
        Spot.newSpot.title.value = self.spot.value!.name
        Spot.newSpot.coordinate = self.spot.value!.location.coordinate
        Spot.newSpot.adress = self.spot.value!.stringAddress
        Spot.newSpot.place = self.spot.value!.addressDictionary!["city"] as! String
        Spot.newSpot.spotId.value = "\(self.spot.value!.name):\(Spot.newSpot.place)"
        User.current.cSpotScreen.value = .description
    }
    
    private func displayLbl() {
        
        let tmpTabl:[UIPlacemarkButton] = [lbl1,lbl2,lbl3,lbl4,lbl5]
        
        for lbl in tmpTabl {
            lbl.setTitleColor(UIColor().primary(), for: .normal)
            lbl.alpha = 0
            lbl.addMap(map: mapView)
            lbl.addDelay(delay: 0.1*Double(tmpTabl.index(of: lbl)!))
            lbl.addTarget(self, action: #selector(self.lblPressed(sender:)), for: .touchUpInside)
        }
    }
    
    func lblPressed(sender:UIPlacemarkButton) {
        mapView.selectAnnotation(sender.annotation, animated: true)
        sender.animSelect(withDuration: 0.3)
        spot.value = sender.placemark
    }
}


class UIPlacemarkButton:UIButton {
    
    var placemark:GeocodedPlacemark? {
        didSet {
            guard let delay = delay else {return}
            if placemark == nil {
                self.animDisappear(withDuration: 0.3, delay: delay, completionBlock: {})
            } else {
                self.animAppear(withDuration: 0.3, delay: delay, completionBlock: {})
            }
        }
    }
    var annotation = MGLPointAnnotation()
    var delay:TimeInterval?
    
    let disposeBag = DisposeBag()
    
    convenience init(map:MGLMapView) {
        self.init(frame:CGRect.zero)
        map.addAnnotation(annotation)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addMap(map:MGLMapView) {
        map.addAnnotation(annotation)
    }
    
    func addDelay(delay:TimeInterval) {
        self.delay = delay
    }
    
    func addPlacemark(placemark:GeocodedPlacemark) {
        self.placemark = placemark
        annotation.coordinate = placemark.location.coordinate
        annotation.title = placemark.name
        
        self.setTitle(placemark.name, for: .normal)
    }
}

extension GeocodedPlacemark {
    
    var stringAddress : String {
        get {
            var address = String()
            guard let addressdictionary = self.addressDictionary else {
                return address
            }
            address = address + (addressdictionary["street"] as? String ?? "") + ","
            address = address + (addressdictionary["postalCode"] as? String ?? "") + " "
            address = address + (addressdictionary["city"] as? String ?? "")
            
            return address
        }
    }
}


