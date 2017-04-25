//
//  SearchNavigationController.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 24/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import CoreLocation
import MapboxGeocoder
import MapKit

class SearchViewController:UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var tvAdress: UITextField!
    @IBOutlet weak var btnMap: UIButton!
    @IBOutlet weak var btnRecentre: UIButton!
    
    @IBOutlet weak var tvResult: UITableView!
    
    let spotSearcher = AWSTableSpot()
    var result = [AWSSpots]()
    var reverse = [MKPlacemark]()
    
    var searchResult:Bool = true
    
    var place:Variable<String?> = Variable(nil)
    var placeCoo:CLLocationCoordinate2D?
    
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
        
        tvResult.estimatedRowHeight = 100
        tvResult.rowHeight = UITableViewAutomaticDimension
        
        place.asObservable()
            .subscribe(onNext: {
                description in
                if let description = description {
                    self.searchResult = true
                    self.spotSearcher.getClosestSpot(place: description)
                }
            }).addDisposableTo(disposeBag)
        
        
        spotSearcher.results.asObservable()
            .subscribe(onNext:{
                description in
                self.searchResult = false
                self.result = description.map({
                    spot in
                    spot.userDistance = Int(CLLocation(latitude: self.placeCoo!.latitude, longitude: self.placeCoo!.longitude).distance(from: CLLocation(latitude: spot._latitude as! CLLocationDegrees, longitude: spot._longitude as! CLLocationDegrees)))
                    return spot
                }).sorted{$0.userDistance < $1.userDistance}
                self.tvResult.reloadSections([0,2], with: .fade)
            }).addDisposableTo(disposeBag)
        
        self.place.value = User.current.place.value
        self.placeCoo = User.current.location.value
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if searchResult {
                return 1
            } else {
                return 0
            }
        } else if section == 1 {
            return reverse.count
        } else {
            return result.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as! SearchCell
            cell.place = reverse[indexPath.row]
            return cell
        }
        
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SpotCell") as! SpotCell
            cell.spot = result[indexPath.row]
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchingCell")!
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            self.place.value = reverse[indexPath.row].addressDictionary!["City"] as? String
            self.placeCoo = reverse[indexPath.row].coordinate
            tvAdress.endEditing(true)
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
                self.reverse = localSearchResponse.mapItems.map{$0.placemark}
            } else {
                self.reverse = [MKPlacemark]()
            }
            
            self.searchResult = false
            self.tvResult.reloadSections([0,1], with: .fade)
        }
    }
    
    var textFieldDisposable:Disposable!
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textFieldDisposable = textField.rx.text
            .debounce(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                adress in
                if let adress = adress {
                    self.searchResult = adress != String()
                    self.tvResult.reloadSections([0], with: .fade)
                    self.forwardGeocoding(address: adress)
                }
            })
        textFieldDisposable.addDisposableTo(disposeBag)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textFieldDisposable.dispose()
        reverse = [MKPlacemark]()
        tvResult.beginUpdates()
        tvResult.reloadSections([0,1], with: .fade)
        tvResult.endUpdates()
    }
    
    @IBAction func btnBackPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: {})
    }
    @IBAction func btnRecentrePressed(_ sender: Any) {
        tvAdress.endEditing(true)
        tvAdress.text = String()
        self.place.value = User.current.place.value
        self.placeCoo = User.current.location.value
        self.searchResult = true
        self.tvResult.reloadSections([0], with: .fade)
    }
}

class SpotCell:UITableViewCell {
    
    let size1:CGFloat = 100
    let size2:CGFloat = 60
    
    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var imgMedal1: UIImageView!
    @IBOutlet weak var imgMedal2: UIImageView!
    @IBOutlet weak var imgMedal3: UIImageView!
    @IBOutlet weak var imgMedal4: UIImageView!
    
    @IBOutlet weak var hMedal1: NSLayoutConstraint!
    @IBOutlet weak var hMedal2: NSLayoutConstraint!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        hMedal1.constant = size1
        hMedal2.constant = size2
        
        imgMedal1.unselectedStyle()
        imgMedal2.unselectedStyle()
        imgMedal3.unselectedStyle()
        imgMedal4.unselectedStyle()
        
        imgMedal1.layer.cornerRadius = size1/2
        imgMedal2.layer.cornerRadius = size2/2
        imgMedal3.layer.cornerRadius = size2/2
        imgMedal4.layer.cornerRadius = size2/2
    }
    
    private func initCell() {
        imgBack.image = nil
        imgMedal1.image = nil
        imgMedal2.image = nil
        imgMedal3.image = nil
        imgMedal4.image = nil
    }
    
    var spot:AWSSpots!{
        didSet {
            
            initCell()
            
            if let userDistance = self.spot.userDistance, userDistance > 1000 {
                let distanceInKMeters = userDistance/1000
                lblTitle.text = "(\(distanceInKMeters)km) \(self.spot._name!)"
            } else {
                lblTitle.text = "(\(self.spot.userDistance!)m) \(self.spot._name!)"
            }
            
            let descriptions = self.spot.userDescription.filter{$0.typeSpot.pic != nil}.sorted{$0.rVote > $1.rVote}
            
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
            
            if let pictures = self.spot._pictureId, pictures.count > 0 {
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
    }
}

class SearchCell:UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblName.setContentHuggingPriority(.infinity, for: .vertical)
    }
    
    var place:MKPlacemark!{
        didSet {
            lblName.text = self.place.stringAddress2
            layoutIfNeeded()
        }
    }
}


