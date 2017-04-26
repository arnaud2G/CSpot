//
//  MapSearchController.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 26/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import CoreLocation
import MapboxGeocoder
import MapKit
import Mapbox

class MapSearchController:UIViewController {
    
    @IBOutlet weak var vStack: UIStackView!
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var tvAdress: UITextField!
    var textFieldDisposable:Disposable!
    @IBOutlet weak var btnMap: UIButton!
    @IBOutlet weak var btnRecentre: UIButton!
    
    @IBOutlet weak var tvResult: UITableView!
    @IBOutlet weak var htResult: NSLayoutConstraint!
    
    @IBOutlet weak var vMap: MGLMapView!
    @IBOutlet weak var hMap: NSLayoutConstraint!
    var userAnnotation = MGLPointAnnotation()
    
    @IBOutlet weak var vIndicator: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    let spotSearcher = AWSTableSpot()
    var result = [AWSSpots]()
    
    var reverse:Variable<[MKPlacemark]> = Variable([])
    var searchResult:Variable<Bool> = Variable(false)
    
    var place:Variable<String?> = Variable(nil)
    var placeCoo:Variable<CLLocationCoordinate2D?> = Variable(nil)
    
    let disposeBag = DisposeBag()
    
    deinit {
        print("deinit SearchViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnBack.tintColor = UIColor().primary()
        btnBack.setImage(#imageLiteral(resourceName: "delete").withRenderingMode(.alwaysTemplate), for: .normal)
        btnMap.tintColor = UIColor().primary()
        btnMap.setImage(#imageLiteral(resourceName: "beach").withRenderingMode(.alwaysTemplate), for: .normal)
        btnRecentre.tintColor = UIColor().primary()
        btnRecentre.setImage(#imageLiteral(resourceName: "pirate").withRenderingMode(.alwaysTemplate), for: .normal)
        
        tvAdress.unselectedStyle()
        tvAdress.layer.cornerRadius = 20
        tvAdress.delegate = self
        tvAdress.textAlignment = .left

        tvResult.estimatedRowHeight = 60
        tvResult.rowHeight = UITableViewAutomaticDimension
        
        //vMap.showsUserLocation = true
        //vMap.setCenter(User.current.location.value!, zoomLevel: 16, animated: false)
        vMap.delegate = self
        vMap.addAnnotation(userAnnotation)
        
        place.asObservable()
            .subscribe(onNext: {
                description in
                if let description = description {
                    self.spotSearcher.getClosestSpot(place: description)
                }
            }).addDisposableTo(disposeBag)
        
        placeCoo.asObservable()
            .subscribe(onNext: {
                coordonne in
                if let coordonne = coordonne {
                    self.vMap.setCenter(coordonne, zoomLevel: 16, animated: self.isAppear)
                    self.userAnnotation.coordinate = coordonne
                }
            }).addDisposableTo(disposeBag)
        
        spotSearcher.results.asObservable()
            .subscribe(onNext:{
                description in
                self.result = description.map({
                    spot in
                    spot.userDistance = Int(CLLocation(latitude: self.placeCoo.value!.latitude, longitude: self.placeCoo.value!.longitude).distance(from: CLLocation(latitude: spot._latitude as! CLLocationDegrees, longitude: spot._longitude as! CLLocationDegrees)))
                    return spot
                }).sorted{$0.userDistance < $1.userDistance}
            }).addDisposableTo(disposeBag)
        
        place.value = User.current.place.value
        placeCoo.value = User.current.location.value
    }
    
    var isAppear = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isAppear {
            isAppear = true
            searchResult.asObservable()
                .subscribe(onNext:{
                    searching in
                    self.indicator.isHidden = !searching
                    self.vIndicator.isHidden = !searching
                    UIView.animate(withDuration: 0.5) {
                        self.vStack.layoutIfNeeded()
                    }
                }).addDisposableTo(disposeBag)
            
            reverse.asObservable()
                .subscribe(onNext:{
                    tReverse in
                    if tReverse.count == 0 {
                        self.htResult.priority = 750
                        self.hMap.priority = 250
                    } else {
                        self.htResult.priority = 250
                        self.hMap.priority = 750
                    }
                    UIView.animate(withDuration: 0.5) {
                        self.vStack.layoutIfNeeded()
                    }
                }).addDisposableTo(disposeBag)
        }
    }
    
    func forwardGeocoding(address: String) {
        
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = address
        localSearchRequest.region = MKCoordinateRegion(center: User.current.location.value!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start {
            (localSearchResponse, error) -> Void in
            
            if let localSearchResponse = localSearchResponse, localSearchResponse.mapItems.count > 0 {
                self.reverse.value = localSearchResponse.mapItems.map{$0.placemark}
            } else {
                self.reverse.value = [MKPlacemark]()
            }
            self.tvResult.reloadSections([0], with: .fade)
        }
    }
    
    @IBAction func btnBackPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: {})
    }
}

//
// MGLAnnotationView subclass
class CustomAnnotationView: MGLAnnotationView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Force the annotation view to maintain a constant size when the map is tilted.
        scalesWithViewingDistance = false
        
        // Use CALayer’s corner radius to turn this view into a circle.
        layer.cornerRadius = frame.width / 2
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Animate the border width in/out, creating an iris effect.
        let animation = CABasicAnimation(keyPath: "borderWidth")
        animation.duration = 0.1
        layer.borderWidth = selected ? frame.width / 4 : 2
        layer.add(animation, forKey: "borderWidth")
    }
}

// MARK: - MapBox
extension MapSearchController: MGLMapViewDelegate {
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        // This example is only concerned with point annotations.
        guard annotation is MGLPointAnnotation else {
            return nil
        }
        
        // Use the point annotation’s longitude value (as a string) as the reuse identifier for its view.
        let reuseIdentifier = "\(annotation.coordinate.longitude)"
        
        // For better performance, always try to reuse existing annotations.
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        // If there’s no reusable annotation view available, initialize a new one.
        if annotationView == nil {
            annotationView = CustomAnnotationView(reuseIdentifier: reuseIdentifier)
            annotationView!.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            
            // Set the annotation view’s background color to a value determined by its longitude.
            let hue = CGFloat(annotation.coordinate.longitude) / 100
            annotationView!.backgroundColor = UIColor(hue: hue, saturation: 0.5, brightness: 1, alpha: 1)
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
}

// MARK: - TextFiled
extension MapSearchController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textFieldDisposable = textField.rx.text
            .debounce(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                adress in
                if let adress = adress {
                    self.forwardGeocoding(address: adress)
                }
            })
        textFieldDisposable.addDisposableTo(disposeBag)
    }
    
    /*func textFieldDidEndEditing(_ textField: UITextField) {
     textFieldDisposable.dispose()
     reverse.value = [MKPlacemark]()
     tvResult.beginUpdates()
     tvResult.reloadSections([0], with: .fade)
     tvResult.endUpdates()
     }*/
    @IBAction func btnRecentrePressed(_ sender: Any) {
        if reverse.value.count > 0 {
            textFieldDisposable.dispose()
            reverse.value = [MKPlacemark]()
        } else {
            tvAdress.endEditing(true)
            tvAdress.text = String()
            self.place.value = User.current.place.value
            self.placeCoo.value = User.current.location.value
        }
    }
}

// MARK: - TableView
extension MapSearchController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reverse.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as! SearchCell
        cell.place = reverse.value[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.place.value = reverse.value[indexPath.row].addressDictionary!["City"] as? String
        self.placeCoo.value = reverse.value[indexPath.row].coordinate
        tvAdress.endEditing(true)
        textFieldDisposable.dispose()
        reverse.value = [MKPlacemark]()
    }
}

