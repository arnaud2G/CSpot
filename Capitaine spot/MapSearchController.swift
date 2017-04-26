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
    
    static let userTitle = "CSPot-user"
    
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
    var userAnnotation = SpotAnnotation()
    
    @IBOutlet weak var vIndicator: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    // Vue selectionnée
    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgMedal1: UIImageView!
    @IBOutlet weak var imgMedal2: UIImageView!
    @IBOutlet weak var imgMedal3: UIImageView!
    @IBOutlet weak var imgMedal4: UIImageView!
    @IBOutlet weak var hSize1: NSLayoutConstraint!
    @IBOutlet weak var hSize2: NSLayoutConstraint!
    
    let spotSearcher = AWSTableSpot()
    var result:Variable<[AWSSpots]> = Variable([])
    
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
        
        vMap.delegate = self
        userAnnotation.title = MapSearchController.userTitle
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
                self.result.value = description.map({
                    spot in
                    spot.userDistance = Int(CLLocation(latitude: self.placeCoo.value!.latitude, longitude: self.placeCoo.value!.longitude).distance(from: CLLocation(latitude: spot._latitude as! CLLocationDegrees, longitude: spot._longitude as! CLLocationDegrees)))
                    return spot
                }).sorted{$0.userDistance < $1.userDistance}
            }).addDisposableTo(disposeBag)
        
        result.asObservable()
            .subscribe(onNext:{
                spots in
                if spots.count == 0 {return}
                let annotations = spots.map({
                    (spot:AWSSpots) -> MGLPointAnnotation in
                    let annotation = SpotAnnotation(spot: spot)
                    return annotation
                })
                self.completeCell(spot:spots.first!)
                self.vMap.addAnnotations(annotations)
            }).addDisposableTo(disposeBag)
        
        place.value = User.current.place.value
        placeCoo.value = User.current.location.value
        displayCell()
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

// MARK: - MapBox
extension MapSearchController: MGLMapViewDelegate {
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        // This example is only concerned with point annotations.
        guard let annotation = annotation as? SpotAnnotation else { return nil }
        
        // Use the point annotation’s longitude value (as a string) as the reuse identifier for its view.
        var reuseIdentifier:String!
        if annotation.title! == MapSearchController.userTitle {
            reuseIdentifier = annotation.title!
        } else {
            reuseIdentifier = "\(annotation.coordinate.longitude)"
        }
        
        // For better performance, always try to reuse existing annotations.
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        // If there’s no reusable annotation view available, initialize a new one.
        if annotationView == nil {
            annotationView = SpotAnnotationView(spot:annotation.spot ,reuseIdentifier: reuseIdentifier)
            annotationView!.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            
            // Set the annotation view’s background color to a value determined by its longitude.
            let hue = CGFloat(annotation.coordinate.longitude) / 100
            annotationView!.backgroundColor = UIColor(hue: hue, saturation: 0.5, brightness: 1, alpha: 1)
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return annotation.title! != MapSearchController.userTitle
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        guard let annotation = annotation as? SpotAnnotation, let spot = annotation.spot else { return }
        initCell()
        completeCell(spot:spot)
    }
    
    func initCell() {
        imgBack.image = nil
        imgMedal1.image = nil
        imgMedal2.image = nil
        imgMedal3.image = nil
        imgMedal4.image = nil
    }
    
    func completeCell(spot:AWSSpots) {
        
        if let userDistance = spot.userDistance, userDistance > 1000 {
            let distanceInKMeters = userDistance/1000
            lblTitle.text = "(\(distanceInKMeters)km) \(spot._name!)"
        } else {
            lblTitle.text = "(\(spot.userDistance!)m) \(spot._name!)"
        }
        
        let descriptions = spot.userDescription.filter{$0.typeSpot.pic != nil}.sorted{$0.rVote > $1.rVote}
        
        imgMedal1.image = descriptions.first!.typeSpot.pic!.withRenderingMode(.alwaysTemplate)
        
        if descriptions.count > 1 {
            imgMedal2.image = descriptions[1].typeSpot.pic!.withRenderingMode(.alwaysTemplate)
        }
        
        if descriptions.count > 2 {
            imgMedal3.image = descriptions[2].typeSpot.pic!.withRenderingMode(.alwaysTemplate)
        }
        
        if descriptions.count > 3 {
            imgMedal4.image = descriptions[3].typeSpot.pic!.withRenderingMode(.alwaysTemplate)
        }
        
        if let pictures = spot._pictureId, pictures.count > 0 {
            guard let url = AWSS3.convertToPublicURLRepository(url: pictures[Int.random(lower: 0, upper: pictures.count - 1)]) else {return}
            getImageFromUrl(url:url, completion: {
                image in
                DispatchQueue.main.async(execute: {
                    () -> Void in
                    if let image = image {
                        self.imgBack.image = image
                    }
                })
            })
        }
    }
    
    func displayCell() {
        
        imgMedal1.unselectedStyle()
        imgMedal2.unselectedStyle()
        imgMedal3.unselectedStyle()
        imgMedal4.unselectedStyle()
        
        imgMedal1.layer.cornerRadius = hSize1.constant/2
        imgMedal2.layer.cornerRadius = hSize2.constant/2
        imgMedal3.layer.cornerRadius = hSize2.constant/2
        imgMedal4.layer.cornerRadius = hSize2.constant/2
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

// MARK: - SubClass


//
// MGLAnnotationView subclass
class SpotAnnotationView: MGLAnnotationView {
    
    var spot:AWSSpots?
    
    convenience init(spot:AWSSpots?, reuseIdentifier: String?) {
        self.init(reuseIdentifier: reuseIdentifier)
        
        let imgPic = UIImageView()
        self.addSubview(imgPic)
        imgPic.translatesAutoresizingMaskIntoConstraints = false
        
        imgPic.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        imgPic.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        imgPic.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imgPic.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        imgPic.contentMode = .center
        
        if let spot = spot {
            self.spot = spot
            imgPic.image = spot.userDescription.first!.typeSpot.pic!.withRenderingMode(.alwaysTemplate)
        } else {
            imgPic.image = #imageLiteral(resourceName: "pirate").withRenderingMode(.alwaysTemplate)
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scalesWithViewingDistance = false
        layer.cornerRadius = frame.width / 2
        
        if isSelected {
            self.selectedStyle()
        } else {
            self.unselectedStyle()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        if spot == nil {
            super.setSelected(false, animated: false)
            return
        }
        
        super.setSelected(selected, animated: animated)
        if selected {
            self.selectedStyle()
        } else {
            self.unselectedStyle()
        }
    }
}

class SpotAnnotation: MGLPointAnnotation {
    var spot:AWSSpots?
    
    convenience init(spot:AWSSpots?) {
        self.init()
        guard let spot = spot else {return}
        self.spot = spot
        self.coordinate = CLLocationCoordinate2D(latitude: spot._latitude as! CLLocationDegrees, longitude: spot._longitude as! CLLocationDegrees)
        self.title = spot._name
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

