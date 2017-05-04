//
//  MaskViewController.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 04/05/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit
import Mapbox

class MaskViewController:UIViewController {
    
    @IBOutlet weak var vMap: MGLMapView!
    @IBOutlet weak var vMap2: MGLMapView!
    @IBOutlet weak var vMap3: MGLMapView!
    @IBOutlet weak var vMap4: MGLMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vMap.styleURL = URL(string: "mapbox://styles/mapbox/light-v9")
        vMap2.styleURL = URL(string: "mapbox://styles/mapbox/light-v9")
        vMap3.styleURL = URL(string: "mapbox://styles/mapbox/light-v9")
        vMap4.styleURL = URL(string: "mapbox://styles/mapbox/light-v9")
        
        let imgView = UIImageView()
        imgView.frame = CGRect(origin: CGPoint.zero, size: vMap.frame.size)
        imgView.contentMode = .scaleToFill
        imgView.image = #imageLiteral(resourceName: "script1")
        
        vMap.mask = imgView
        
        let imgView2 = UIImageView()
        imgView2.frame = CGRect(origin: CGPoint.zero, size: vMap.frame.size)
        imgView2.contentMode = .scaleToFill
        imgView2.image = #imageLiteral(resourceName: "script2")
        
        vMap2.mask = imgView2
        
        let imgView3 = UIImageView()
        imgView3.frame = CGRect(origin: CGPoint.zero, size: vMap.frame.size)
        imgView3.contentMode = .scaleToFill
        imgView3.image = #imageLiteral(resourceName: "script3")
        
        vMap3.mask = imgView3
        
        let imgView4 = UIImageView()
        imgView4.frame = CGRect(origin: CGPoint.zero, size: vMap.frame.size)
        imgView4.contentMode = .scaleToFill
        imgView4.image = #imageLiteral(resourceName: "script4")
        
        vMap4.mask = imgView4
    }
    
}
