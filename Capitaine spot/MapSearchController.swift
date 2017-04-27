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

class MapSearchController:SearchViewController {
    
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
    let userAnnotation = UIImageView()
    var mapCenter:Variable<CLLocationCoordinate2D?> = Variable(nil)
    
    @IBOutlet weak var vIndicator: UIActivityIndicatorView!
    
    // Vue selectionnée
    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var medal1: UIMedal!
    @IBOutlet weak var medal2: UIMedal!
    @IBOutlet weak var medal3: UIMedal!
    @IBOutlet weak var medal4: UIMedal!
    
    
    @IBOutlet weak var hSize1: NSLayoutConstraint!
    @IBOutlet weak var hSize2: NSLayoutConstraint!
    
    var selectedSpot:AWSSpots?
    
    let disposeBag = DisposeBag()
    
    deinit {
        print("deinit MapSearchController")
    }
    
    func searchNC() -> SearchNavigationController {
        return self.navigationController as! SearchNavigationController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnBack.tintColor = UIColor().primary()
        btnBack.setImage(#imageLiteral(resourceName: "delete").withRenderingMode(.alwaysTemplate), for: .normal)
        btnMap.tintColor = UIColor().primary()
        btnMap.setImage(#imageLiteral(resourceName: "treasure").withRenderingMode(.alwaysTemplate), for: .normal)
        btnRecentre.tintColor = UIColor().primary()
        btnRecentre.setImage(#imageLiteral(resourceName: "pirate").withRenderingMode(.alwaysTemplate), for: .normal)
        
        tvAdress.unselectedStyle()
        tvAdress.layer.cornerRadius = 20
        tvAdress.delegate = self
        tvAdress.textAlignment = .left

        tvResult.estimatedRowHeight = 60
        tvResult.rowHeight = UITableViewAutomaticDimension
        
        vMap.delegate = self
        userAnnotation.translatesAutoresizingMaskIntoConstraints = false
        vMap.addSubview(userAnnotation)
        vMap.centerXAnchor.constraint(equalTo: userAnnotation.centerXAnchor).isActive = true
        vMap.centerYAnchor.constraint(equalTo: userAnnotation.centerYAnchor).isActive = true
        userAnnotation.selectedStyle()
        userAnnotation.widthAnchor.constraint(equalToConstant: 26).isActive = true
        userAnnotation.heightAnchor.constraint(equalToConstant: 26).isActive = true
        userAnnotation.layer.cornerRadius = 13
        
        searchNC().placeCoo.asObservable()
            .subscribe(onNext: {
                [weak self] coordonne in
                if let coordonne = coordonne {
                    self?.vMap.setCenter(coordonne, zoomLevel: 16, animated: self!.isAppear)
                    self?.userAnnotation.image = #imageLiteral(resourceName: "pirate").withRenderingMode(.alwaysTemplate)
                    //self?.userAnnotation.coordinate = coordonne
                }
            }).addDisposableTo(disposeBag)
        
        searchNC().result.asObservable()
            .subscribe(onNext:{
                [weak self] spots in
                if spots.count == 0 {return}
                let annotations = spots.map({
                    (spot:AWSSpots) -> MGLPointAnnotation in
                    let annotation = SpotAnnotation(spot: spot)
                    return annotation
                })
                self!.completeCell(spot:spots.first!)
                self?.vMap.addAnnotations(annotations)
            }).addDisposableTo(disposeBag)
        
        displayCell()
        
        transRect = btnMap.frame
        transBtn = btnMap
    }
    
    var isAppear = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isAppear {
            isAppear = true
            searchNC().searchResult.asObservable()
                .subscribe(onNext:{
                    [weak self] searching in
                    guard let searching = searching else {return}
                    self!.btnMap.isHidden = searching
                    self!.vIndicator.isHidden = !searching
                }).addDisposableTo(disposeBag)
            
            searchNC().reverse.asObservable()
                .subscribe(onNext:{
                    [weak self] tReverse in
                    if tReverse.count == 0 {
                        self?.htResult.priority = 750
                        self?.hMap.priority = 250
                    } else {
                        self?.htResult.priority = 250
                        self?.hMap.priority = 750
                    }
                    UIView.animate(withDuration: 0.5) {
                        self!.vStack.layoutIfNeeded()
                    }
                    self!.tvResult.reloadSections([0], with: .fade)
                }).addDisposableTo(disposeBag)
            
            mapCenter.asObservable()
                .debounce(1.0, scheduler: MainScheduler.instance)
                .subscribe(onNext:{
                    [weak self] center in
                    if let center = center {
                        self?.searchNC().forwardGeocoding(location: center)
                    }
                }).addDisposableTo(disposeBag)
        }
    }
    
    @IBAction func btnBackPressed(_ sender: Any) {
        searchNC().dismiss(animated: true, completion: {})
    }
    
    @IBAction func btnChangePressed(_ sender: Any) {
        searchNC().popViewController(animated: true)
    }
    
    @IBAction func vSpotPressed(_ sender: Any) {
        let spotStoryboard = UIStoryboard(name: "Spot", bundle: nil)
        let spotController = spotStoryboard.instantiateInitialViewController() as! SpotViewController
        spotController.spot = selectedSpot
        spotController.image = imgBack.image
        (self.navigationController as! SearchNavigationController).pushViewController(spotController, animated: true)
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
    
    func mapViewRegionIsChanging(_ mapView: MGLMapView) {
        mapCenter.value = mapView.centerCoordinate
        userAnnotation.image = #imageLiteral(resourceName: "ship").withRenderingMode(.alwaysTemplate)
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        guard let annotation = annotation as? SpotAnnotation, let spot = annotation.spot else { return }
        initCell()
        completeCell(spot:spot)
    }
    
    func initCell() {
        imgBack.image = nil
        medal1.image = nil
        medal2.image = nil
        medal3.image = nil
        medal4.image = nil
    }
    
    func completeCell(spot:AWSSpots) {
        
        self.selectedSpot = spot
        
        if let userDistance = spot.userDistance, userDistance > 1000 {
            let distanceInKMeters = userDistance/1000
            lblTitle.text = "(\(distanceInKMeters)km) \(spot._name!)"
        } else {
            lblTitle.text = "(\(spot.userDistance!)m) \(spot._name!)"
        }
        
        let descriptions = spot.userDescription.filter{$0.typeSpot.pic != nil}.sorted{$0.rVote > $1.rVote}
        
        medal1.image = descriptions.first!.typeSpot.pic!.withRenderingMode(.alwaysTemplate)
        medal1.num = descriptions.first!.rVote
        
        if descriptions.count > 1 {
            medal2.image = descriptions[1].typeSpot.pic!.withRenderingMode(.alwaysTemplate)
            medal2.num = descriptions[1].rVote
        }
        
        if descriptions.count > 2 {
            medal3.image = descriptions[2].typeSpot.pic!.withRenderingMode(.alwaysTemplate)
            medal3.num = descriptions[2].rVote
        }
        
        if descriptions.count > 3 {
            medal4.image = descriptions[3].typeSpot.pic!.withRenderingMode(.alwaysTemplate)
            medal4.num = descriptions[3].rVote
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
        
        medal1.unselectedStyle()
        medal2.unselectedStyle()
        medal3.unselectedStyle()
        medal4.unselectedStyle()
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
                    self.searchNC().forwardGeocoding(address: adress)
                }
            })
        textFieldDisposable.addDisposableTo(disposeBag)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textFieldDisposable.dispose()
    }
    
    @IBAction func btnRecentrePressed(_ sender: Any) {
        if searchNC().reverse.value.count > 0 {
            textFieldDisposable.dispose()
            searchNC().reverse.value = [MKPlacemark]()
        } else {
            tvAdress.endEditing(true)
            tvAdress.text = String()
            searchNC().place.value = User.current.place.value
            searchNC().placeCoo.value = User.current.location.value
        }
    }
}

// MARK: - TableView
extension MapSearchController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchNC().reverse.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as! SearchCell
        cell.place = searchNC().reverse.value[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchNC().place.value = searchNC().reverse.value[indexPath.row].addressDictionary!["City"] as? String
        searchNC().placeCoo.value = searchNC().reverse.value[indexPath.row].coordinate
        tvAdress.endEditing(true)
        searchNC().reverse.value = [MKPlacemark]()
    }
}

// MARK: - SubClass
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

// MGLPointAnnotation subclass
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

