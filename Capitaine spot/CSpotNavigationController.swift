//
//  CSpotNavigationController.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 10/05/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

enum CSpotScreen:String {
    case menu, camera, description, location, test, loadding, search, spot
}

class CSpotNavigationController: UINavigationController, UINavigationControllerDelegate {
    
    let disposeBag = DisposeBag()
    
    var myCamera:MyCamera?
    
    deinit {
        print("deinit DescriptionNavigationController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        User.current.cSpotScreen.asObservable()
            .distinctUntilChanged({
                val1, val2 -> Bool in
                return val1.rawValue == val2.rawValue
            }).subscribe(onNext:{
                [weak self] cSpotScreen in
                switch User.current.cSpotScreen.value {
                case .test:
                    let story = UIStoryboard(name: "Loadding", bundle: nil)
                    let vc = story.instantiateInitialViewController()
                    self?.pushViewController(vc!, animated: true)
                case .loadding:
                    let story = UIStoryboard(name: "Loadding", bundle: nil)
                    let vc = story.instantiateInitialViewController()
                    self?.pushViewController(vc!, animated: true)
                case .menu:
                    self?.myCamera = MyCamera()
                case .camera:
                    self?.pushViewController(self!.myCamera!, animated: true)
                case .location:
                    let myMapStoryboard = UIStoryboard(name: "MyMap", bundle: nil)
                    let myMapVC = myMapStoryboard.instantiateInitialViewController()
                    self?.pushViewController(myMapVC!, animated: true)
                case .description:
                    let descriptionStoryboard = UIStoryboard(name: "Description", bundle: nil)
                    let descriptionVC = descriptionStoryboard.instantiateInitialViewController()
                    self?.pushViewController(descriptionVC!, animated: true)
                case .search:
                    // On prend la position actuelle pour la première recherche
                    Search.main.firstSearch()
                    let searchStoryboard = UIStoryboard(name: "Search", bundle: nil)
                    let searchVC = searchStoryboard.instantiateInitialViewController()
                    self?.pushViewController(searchVC!, animated: true)
                case .spot:
                    let spotStoryboard = UIStoryboard(name: "Spot", bundle: nil)
                    let spotController = spotStoryboard.instantiateInitialViewController() as! SpotViewController
                    self?.pushViewController(spotController, animated: true)
                }
        }).addDisposableTo(disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !User.current.localize() {
            User.current.updateLocationEnabled()
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch User.current.cSpotScreen.value {
        case .spot(_):
            return nil
        default:
            return CSPostAnimator()
        }
    }
}


