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
    @IBOutlet weak var vIndicator: UIActivityIndicatorView!
    
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
                    self.btnMap.isHidden = searching
                    self.vIndicator.isHidden = !searching
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
            return 0
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
        if indexPath.section == 2 {
            let cell = tableView.cellForRow(at: indexPath) as! SpotCell
            let spotStoryboard = UIStoryboard(name: "Spot", bundle: nil)
            let spotController = spotStoryboard.instantiateInitialViewController() as! SpotViewController
            spotController.spot = cell.spot
            spotController.image = cell.imgBack.image
            (self.navigationController as! SearchNavigationController).pushViewController(spotController, animated: true)
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
    
    @IBOutlet weak var medal1: UIMedal!
    @IBOutlet weak var medal2: UIMedal!
    @IBOutlet weak var medal3: UIMedal!
    @IBOutlet weak var medal4: UIMedal!
    
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
        
        medal1.unselectedStyle()
        medal2.unselectedStyle()
        medal3.unselectedStyle()
        medal4.unselectedStyle()
    }
    
    private func initCell() {
        imgBack.image = nil
        medal1.image = nil
        medal2.image = nil
        medal3.image = nil
        medal4.image = nil
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


