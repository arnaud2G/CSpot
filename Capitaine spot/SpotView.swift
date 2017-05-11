//
//  SpotView.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 11/05/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit

class SpotView: UIView {
    
    @IBOutlet weak var imgBack: UIImageView!
    
    @IBOutlet weak var medal1: UIMedal!
    
    @IBOutlet weak var medal2: UIMedal!
    @IBOutlet weak var medal3: UIMedal!
    @IBOutlet weak var medal4: UIMedal!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("ADecoder")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("ADecoder")
    }
    
    override func layoutSubviews() {
        
        let imgView3 = UIImageView()
        imgView3.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width-20, height: 110))
        imgView3.contentMode = .scaleToFill
        imgView3.image = #imageLiteral(resourceName: "script4")
        
        imgBack.mask = imgView3
        
        medal1.layer.cornerRadius = medal1.frame.size.width/2
        medal2.layer.cornerRadius = medal2.frame.size.width/2
        medal3.layer.cornerRadius = medal3.frame.size.width/2
        medal4.layer.cornerRadius = medal4.frame.size.width/2
        
        medal1.unselectedStyle()
        medal2.unselectedStyle()
        medal3.unselectedStyle()
        medal4.unselectedStyle()
        
        lblTitle.textColor = UIColor().secondary()
    }
    
    func initCell() {
        medal1.image = nil
        medal2.image = nil
        medal3.image = nil
        medal4.image = nil
    }
    
    func completeCell(spot:AWSSpots) {
        
        if let userDistance = spot.userDistance, userDistance > 1000 {
            let distanceInKMeters = userDistance/1000
            lblTitle.text = "(\(distanceInKMeters)km) \(spot._name!)"
        } else {
            lblTitle.text = "(\(spot.userDistance!)m) \(spot._name!)"
        }
        
        let descriptions = spot.userDescription.filter{$0.typeSpot.pic != nil}.sorted{$0.rVote > $1.rVote}
        
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
    }
}
