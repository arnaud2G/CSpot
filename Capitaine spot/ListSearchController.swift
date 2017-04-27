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

class ListSearchController:SearchViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var tvAdress: UITextField!
    @IBOutlet weak var btnMap: UIButton!
    @IBOutlet weak var btnRecentre: UIButton!
    
    @IBOutlet weak var tvResult: UITableView!
    
    let disposeBag = DisposeBag()
    
    deinit {
        print("deinit SearchViewController")
    }
    
    func searchNC() -> SearchNavigationController {
        return self.navigationController as! SearchNavigationController
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
                    searching in
                    guard let searching = searching else {return}
                    self.tvResult.reloadSections([0], with: .fade)
                    self.btnMap.isEnabled = !searching
                }).addDisposableTo(disposeBag)
            
            searchNC().reverse.asObservable()
                .subscribe(onNext:{
                    tReverse in
                    self.tvResult.reloadSections([1], with: .fade)
                }).addDisposableTo(disposeBag)
            
            searchNC().result.asObservable()
                .subscribe(onNext:{
                    spots in
                    self.tvResult.reloadSections([2], with: .fade)
                }).addDisposableTo(disposeBag)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if let searching = searchNC().searchResult.value, searching {
                return 1
            } else {
                return 0
            }
        } else if section == 1 {
            return searchNC().reverse.value.count
        } else {
            return searchNC().result.value.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as! SearchCell
            cell.place = searchNC().reverse.value[indexPath.row]
            return cell
        }
        
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SpotCell") as! SpotCell
            cell.spot = searchNC().result.value[indexPath.row]
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchingCell")!
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            searchNC().place.value = searchNC().reverse.value[indexPath.row].addressDictionary!["City"] as? String
            searchNC().placeCoo.value = searchNC().reverse.value[indexPath.row].coordinate
            tvAdress.endEditing(true)
            self.searchNC().reverse.value = [MKPlacemark]()
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
                self.searchNC().reverse.value = localSearchResponse.mapItems.map{$0.placemark}
            } else {
                self.searchNC().reverse.value = [MKPlacemark]()
            }
        }
    }
    
    var textFieldDisposable:Disposable!
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
    
    @IBAction func btnBackPressed(_ sender: Any) {
        searchNC().dismiss(animated: true, completion: {})
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
    
    @IBAction func btnChangePressed(_ sender: Any) {
        let searchStoryboard = UIStoryboard(name: "Search", bundle: nil)
        let mapSearchController = searchStoryboard.instantiateViewController(withIdentifier: "MapSearchController")
        (self.navigationController as! SearchNavigationController).pushViewController(mapSearchController, animated: true)
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

