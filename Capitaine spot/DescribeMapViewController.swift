//
//  DescribeMapViewController.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 10/05/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit
import Mapbox
import Darwin
import MapboxGeocoder
import RxCocoa
import RxSwift


class DescribeMapViewController:UIViewController, MGLMapViewDelegate {
    
    // Top view
    @IBOutlet weak var btnUncheckPressed: UIButton!
    @IBOutlet weak var btnCheckPressed: UIButton!
    @IBOutlet weak var tfWhereAreU: UITextField!
    
    // Middle view
    @IBOutlet weak var mapView: MGLMapView!
    
    // Bottom view
    @IBOutlet weak var lbl1: UILabel!
    @IBOutlet weak var lbl2: UILabel!
    @IBOutlet weak var lbl3: UILabel!
    @IBOutlet weak var lbl4: UILabel!
    @IBOutlet weak var lbl5: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mapSize = UIScreen.main.bounds.width - 20
        
        mapView.styleURL = URL(string: "mapbox://styles/mapbox/light-v9")
        mapView.delegate = self
        mapView.layer.cornerRadius = mapSize/2
        mapView.clipsToBounds = true
        mapView.showsUserLocation = true
        view.addSubview(mapView)
        
        mapView.setCenter(User.current.location.value!, zoomLevel: 16, animated: true)
    }
    
}
