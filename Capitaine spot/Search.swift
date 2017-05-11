//
//  Search.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 11/05/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import RxSwift

import CoreLocation
import MapKit

class Search {
    
    static let main = Search()
    
    let spotSearcher = AWSTableSpot()
    var result:Variable<[AWSSpots]> = Variable([])
    
    var reverse:Variable<[MKPlacemark]> = Variable([])
    var searchResult:Variable<Bool?> = Variable(nil)
    
    var place:Variable<String?> = Variable(nil)
    var placeCoo:Variable<CLLocationCoordinate2D?> = Variable(nil)
    
    let disposeBag = DisposeBag()
    
    init() {
        
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
    }
    
    func reset() {
        
        result.value = []
        reverse.value = []
        
        searchResult.value = nil
        
        place.value = nil
        placeCoo.value = nil
    }
    
    func firstSearch() {
        place.value = User.current.place.value
        placeCoo.value = User.current.location.value
    }
    
    func forwardGeocoding(address: String) {
        
        if address == String() {self.reverse.value = [MKPlacemark]() ; return}
        
        self.searchResult.value = true
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = address
        localSearchRequest.region = MKCoordinateRegion(center: placeCoo.value!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
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
    
    func forwardGeocoding(location: CLLocationCoordinate2D) {
        
        self.searchResult.value = true
        
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(CLLocation(latitude: location.latitude, longitude: location.longitude), completionHandler: {
            [weak self] (placemarks, error) -> Void in
            
            self?.searchResult.value = false
            
            guard let placemarks = placemarks, let placemark = placemarks.first, let dico = placemark.addressDictionary, let city = dico["City"] as? String else {
                // TODO ERREUR
                print("On ne trouve pas de ville pour ces coordonnées")
                return
            }
            
            self?.placeCoo.value = location
            self?.place.value = city
        })
    }
}
