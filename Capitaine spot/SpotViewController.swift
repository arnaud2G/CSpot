 //
//  ProfilViewController.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 27/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit
import MapKit
 
 class SpotViewController: UIViewController {
    
    @IBOutlet weak var vBack: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBAction func btnBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var vInfo: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblAdress: UILabel!
    
    @IBOutlet weak var btnGPS: UIButton!
    @IBAction func btnGPSPressed(_ sender: Any) {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: spot._latitude as! CLLocationDegrees, longitude: spot._longitude as! CLLocationDegrees), addressDictionary:nil))
        mapItem.name = spot._name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking])
    }
    
    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var vDescription: UIView!
    
    var spot:AWSSpots!
    
    var animator:UIDynamicAnimator!
    
    deinit {
        print("deinit SpotViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // On attribu le spot
        spot = User.current.selectedSpot!
        
        // graphique
        vBack.backgroundColor = UIColor().secondary()
        btnBack.setImage(#imageLiteral(resourceName: "delete").withRenderingMode(.alwaysTemplate), for: .normal)
        btnBack.tintColor = UIColor().primary()
        
        vInfo.backgroundColor = UIColor().primary()
        lblTitle.textColor = UIColor().secondary()
        lblAdress.textColor = UIColor().secondary()
        btnGPS.setImage(#imageLiteral(resourceName: "ship").withRenderingMode(.alwaysTemplate), for: .normal)
        btnGPS.tintColor = UIColor().secondary()
        
        // Info
        vDescription.backgroundColor = UIColor().secondaryPopUp()
        if let pictures = spot._pictureId, pictures.count > 0 {
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
        
        lblTitle.text = spot._name
        lblAdress.text = spot._adress.replacingOccurrences(of: ",", with: "\n")
        
        // Description
        animator = UIDynamicAnimator(referenceView: vDescription)
        let gravity = UIFieldBehavior.radialGravityField(position: CGPoint(x: (self.vDescription.frame.width)/2, y: (self.vDescription.frame.height)/2))
        gravity.falloff = 0.2
        animator.addBehavior(gravity)
        
        let behavior = UIDynamicItemBehavior()
        behavior.elasticity = 0.2
        behavior.density = 3
        behavior.allowsRotation = false
        animator.addBehavior(behavior)
        
        let sum = CGFloat(spot.userDescription.map{$0.rVote/100}.reduce(0, +))
        let totSize = 0.8*self.vDescription.frame.width*self.vDescription.frame.height
        let sizeByVote = sqrt(totSize/sum)
        
        let ellipses = spot.userDescription.map({
            (description:DescriptionSpot) -> SpotEllipse in
            
            let rVote = Double(description.rVote)/100.0
            let offsetX:CGFloat = CGFloat(Double.random(min: -1/(rVote*rVote), max: 1/(rVote*rVote)))
            let offsetY:CGFloat = CGFloat(Double.random(min: -1/(rVote*rVote), max: 1/(rVote*rVote)))
            
            var size = sizeByVote * CGFloat(rVote)
            size = max(size, 40.0)
            let center = CGPoint(x: (self.vDescription.frame.width - size)/2 + offsetX, y: (self.vDescription.frame.height - size)/2 + offsetY)
            
            let newView = SpotEllipse(frame: CGRect(origin: center, size: CGSize(width: size, height: size)))
            newView.type = description.typeSpot
            self.vDescription.addSubview(newView)
            gravity.addItem(newView)
            behavior.addItem(newView)
            
            return newView
        })
        
        let collision = UICollisionBehavior(items: ellipses)
        animator.addBehavior(collision)
    }
 }
