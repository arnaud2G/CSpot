//
//  SearchNavigationController.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 26/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit

import RxCocoa
import RxSwift

import CoreLocation
import MapKit

class SearchNavigationController:UINavigationController {
    
    deinit {
        print("deinit SearchNavigationController")
    }
    
    static let SegueToChangeDisplay = "SegueToChangeDisplay"
    
    var result:Variable<[AWSSpots]> = Variable([])
    
    let spotSearcher = AWSTableSpot()
    
    var reverse:Variable<[MKPlacemark]> = Variable([])
    var searchResult:Variable<Bool?> = Variable(nil)
    
    var place:Variable<String?> = Variable(nil)
    var placeCoo:Variable<CLLocationCoordinate2D?> = Variable(nil)
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        place.asObservable()
            .subscribe(onNext: {
                [weak self] description in
                if let description = description {
                    self?.searchResult.value = true
                    self!.spotSearcher.getClosestSpot(place: description)
                }
            }).addDisposableTo(disposeBag)
        
        spotSearcher.results.asObservable()
            .subscribe(onNext:{
                [weak self] description in
                self?.searchResult.value = false
                self?.result.value = description.map({
                    spot in
                    spot.userDistance = Int(CLLocation(latitude: self!.placeCoo.value!.latitude, longitude: self!.placeCoo.value!.longitude).distance(from: CLLocation(latitude: spot._latitude as! CLLocationDegrees, longitude: spot._longitude as! CLLocationDegrees)))
                    return spot
                }).sorted{$0.userDistance < $1.userDistance}
            }).addDisposableTo(disposeBag)
        
        place.value = User.current.place.value
        placeCoo.value = User.current.location.value
    }
    
    func forwardGeocoding(address: String) {
        
        if address == String() {self.reverse.value = [MKPlacemark]() ; return}
        
        self.searchResult.value = true
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = address
        localSearchRequest.region = MKCoordinateRegion(center: User.current.location.value!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start {
            (localSearchResponse, error) -> Void in
            
            self.searchResult.value = false
            if let localSearchResponse = localSearchResponse, localSearchResponse.mapItems.count > 0 {
                self.reverse.value = localSearchResponse.mapItems.map{$0.placemark}
            } else {
                self.reverse.value = [MKPlacemark]()
            }
        }
    }
}
