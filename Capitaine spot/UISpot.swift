//
//  UISpot.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 19/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit

class Ellipse: UIButton {
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .ellipse
    }
}

class SpotEllipse: Ellipse {
    
    //var behavior:UIDynamicItemBehavior?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = frame.size.width / 2
        
        self.unselectedStyle()
        
        /*behavior = UIDynamicItemBehavior(items: [self])
        behavior!.elasticity = 0.2
        behavior!.density = 3
        behavior!.allowsRotation = false*/
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var describe:Bool = false {
        didSet {
            if describe {
                self.selectedStyle()
            } else {
                self.unselectedStyle()
            }
        }
    }
    
    var type:TypeSpot!{
        didSet {
            if let pic = self.type.pic {
                self.setImage(pic.withRenderingMode(.alwaysTemplate), for: .normal)
            } else {
                self.setTitle(self.type.localizedString, for: .normal)
            }
        }
    }
}
