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

class SearchViewController:UIViewController {
    var transRect:CGRect!
    var transBtn:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

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
    @IBOutlet weak var contentView: UIView!
    
    var selectedSpot:AWSSpots?
    
    let disposeBag = DisposeBag()
    
    deinit {
        print("deinit MapSearchController")
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
        vMap.zoomLevel = 16
        
        let imgView3 = UIImageView()
        imgView3.frame = CGRect(origin: CGPoint.zero, size: vMap.frame.size)
        imgView3.contentMode = .scaleToFill
        imgView3.image = #imageLiteral(resourceName: "script3")
        
        vMap.mask = imgView3
        
        userAnnotation.selectedStyle()
        userAnnotation.widthAnchor.constraint(equalToConstant: 26).isActive = true
        userAnnotation.heightAnchor.constraint(equalToConstant: 26).isActive = true
        userAnnotation.layer.cornerRadius = 13
        
        displayCell()
        
        Search.main.placeCoo.asObservable()
            .subscribe(onNext: {
                [weak self] coordonne in
                if let coordonne = coordonne {
                    self?.vMap.setCenter(coordonne, zoomLevel: self!.vMap.zoomLevel, animated: self!.isAppear)
                    self?.userAnnotation.image = #imageLiteral(resourceName: "pirate").withRenderingMode(.alwaysTemplate)
                }
            }).addDisposableTo(disposeBag)
        
        Search.main.result.asObservable()
            .subscribe(onNext:{
                [weak self] spots in
                if spots.count == 0 {return}
                let annotations = spots.map({
                    (spot:AWSSpots) -> MGLPointAnnotation in
                    let annotation = SpotAnnotation(spot: spot)
                    return annotation
                })
                let spotView = self?.contentView.viewWithTag(100) as! SpotView
                self?.selectedSpot = spots.first!
                spotView.completeCell(spot:spots.first!)
                self?.vMap.addAnnotations(annotations)
            }).addDisposableTo(disposeBag)
        
        transRect = btnMap.frame
        transBtn = btnMap
    }
    
    var isAppear = false
    override func viewDidAppear(_ animated: Bool) {
        
        if !isAppear {
            isAppear = true
            Search.main.searchResult.asObservable()
                .subscribe(onNext:{
                    [weak self] searching in
                    guard let searching = searching else {return}
                    self!.btnMap.isHidden = searching
                    self!.vIndicator.isHidden = !searching
                }).addDisposableTo(disposeBag)
            
            Search.main.reverse.asObservable()
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
                .debounce(0.5, scheduler: MainScheduler.instance)
                .subscribe(onNext:{
                    center in
                    if let center = center {
                        Search.main.forwardGeocoding(location: center)
                    }
                }).addDisposableTo(disposeBag)
        }
    }
    
    @IBAction func btnBackPressed(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func btnChangePressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func vSpotPressed(_ sender: Any) {
        guard let selectedSpot = selectedSpot else {return}
        User.current.selectedSpot = selectedSpot
        User.current.cSpotScreen.value = .spot
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
        self.selectedSpot = spot
        let spotView = contentView.viewWithTag(100) as! SpotView
        spotView.initCell()
        spotView.completeCell(spot:spot)
    }
    
    func displayCell() {
        
        if let customView = Bundle.main.loadNibNamed("SpotView", owner: self, options: nil)!.first as? SpotView {
            
            customView.translatesAutoresizingMaskIntoConstraints = false
            customView.tag = 100
            contentView.addSubview(customView)
            contentView.centerXAnchor.constraint(equalTo: customView.centerXAnchor).isActive = true
            contentView.centerYAnchor.constraint(equalTo: customView.centerYAnchor).isActive = true
            contentView.trailingAnchor.constraint(equalTo: customView.trailingAnchor).isActive = true
            contentView.topAnchor.constraint(equalTo: customView.topAnchor).isActive = true
        }
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
                    Search.main.forwardGeocoding(address: adress)
                }
            })
        textFieldDisposable.addDisposableTo(disposeBag)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textFieldDisposable.dispose()
    }
    
    @IBAction func btnRecentrePressed(_ sender: Any) {
        if Search.main.reverse.value.count > 0 {
            textFieldDisposable.dispose()
            Search.main.reverse.value = [MKPlacemark]()
        } else {
            tvAdress.endEditing(true)
            tvAdress.text = String()
            Search.main.place.value = User.current.place.value
            Search.main.placeCoo.value = User.current.location.value
        }
    }
}

// MARK: - TableView
extension MapSearchController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Search.main.reverse.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as! SearchCell
        cell.place = Search.main.reverse.value[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Search.main.place.value = Search.main.reverse.value[indexPath.row].addressDictionary!["City"] as? String
        Search.main.placeCoo.value = Search.main.reverse.value[indexPath.row].coordinate
        tvAdress.endEditing(true)
        Search.main.reverse.value = [MKPlacemark]()
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

