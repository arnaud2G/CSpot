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

class SearchViewController:UIViewController {
    var transRect:CGRect!
    var transBtn:UIButton!
}

class SearchNavigationController:UINavigationController, UINavigationControllerDelegate {
    
    deinit {
        print("deinit SearchNavigationController")
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SearchTransitionAnimator()
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
        
        self.delegate = self
        
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

class SearchTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning, CAAnimationDelegate {
    
    weak var transitionContext: UIViewControllerContextTransitioning!
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        //1
        self.transitionContext = transitionContext
        
        //2
        let containerView = transitionContext.containerView
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! SearchViewController
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! SearchViewController
        
        //3
        containerView.addSubview(toViewController.view)
        
        //4
        let circleMaskPathInitial = UIBezierPath(ovalIn: CGRect(origin: fromViewController.transBtn.center, size: CGSize(width: 0, height: 0)))
        
        let extremePoint = CGPoint(x: fromViewController.transBtn.center.x, y: fromViewController.transBtn.center.y - toViewController.view.bounds.height)
        
        let radius = sqrt((extremePoint.x*extremePoint.x) + (extremePoint.y*extremePoint.y))
        let circleMaskPathFinal = UIBezierPath(ovalIn: CGRect(x: 150 - radius, y: 150 - radius, width: 2*radius, height: 2*radius))
        
        //5
        let maskLayer = CAShapeLayer()
        maskLayer.path = circleMaskPathFinal.cgPath
        toViewController.view.layer.mask = maskLayer
        
        //6
        let maskLayerAnimation = CABasicAnimation(keyPath: "path")
        maskLayerAnimation.fromValue = circleMaskPathInitial.cgPath
        maskLayerAnimation.toValue = circleMaskPathFinal.cgPath
        maskLayerAnimation.duration = self.transitionDuration(using: transitionContext)
        maskLayerAnimation.delegate = self
        maskLayer.add(maskLayerAnimation, forKey: "path")
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        print("Stop")
        self.transitionContext.completeTransition(true)
    }
}
