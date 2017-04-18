//
//  VueC2.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 11/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//
import UIKit
import CoreMotion

import RxCocoa
import RxSwift

class Ellipse: UIButton {
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .ellipse
    }
}

class SpotEllipse: Ellipse {
    
    var behavior:UIDynamicItemBehavior!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = frame.size.width / 2
        
        self.unselectedStyle()
        
        behavior = UIDynamicItemBehavior(items: [self])
        behavior.elasticity = 0.2
        behavior.density = 3
        behavior.allowsRotation = false
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

class VueC2: UIViewController {
    
    var animator: UIDynamicAnimator!
    var gravity:UIFieldBehavior!
    var collision:UICollisionBehavior?
    
    let disposableBag = DisposeBag()
    
    
    let ellipseInTheGround: Variable<[SpotEllipse]> = Variable([])
    var onTheGround = [TypeSpot]() {
        didSet {
            let newVals = onTheGround.filter{!oldValue.contains($0)}
            setupNewValue(newVals: newVals)
            
            let delVals = oldValue.filter{!onTheGround.contains($0)}
            setupDelValue(newVals: delVals)
        }
    }
    var onTheSelection = [TypeSpot]() {
        didSet {
            let newVals = onTheSelection.filter{!oldValue.contains($0)}.map{$0.nextType}.flatMap{$0}.filter{!onTheGround.contains($0)}
            onTheGround.append(contentsOf: newVals)
            
            let delVals = onTheGround.filter{!(onTheSelection.map{$0.nextType}.flatMap{$0}).contains($0)}.filter{!TypeSpot.spot.nextType.contains($0)}
            _ = delVals.map({
                type in
                if let index = onTheGround.index(of: type) {
                    onTheGround.remove(at: index)
                }
            })
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        animator = UIDynamicAnimator(referenceView: view)
        gravity = UIFieldBehavior.radialGravityField(position: self.view.center)
        gravity.falloff = 0.2
        self.animator.addBehavior(gravity)
        
        ellipseInTheGround
            .asObservable()
            .subscribe(onNext:{
                description in
                self.defineBehavior(items: description)
            }).addDisposableTo(disposableBag)
    }
    
    private func defineBehavior(items:[Ellipse]) {
        
        if let collision = collision {
            self.animator.removeBehavior(collision)
        }
        
        collision = UICollisionBehavior(items: items)
        self.animator.addBehavior(collision!)
        
        _ = items.map({
            view in
            gravity.addItem(view)
        })
    }
    
    private func setupNewValue(newVals:[TypeSpot]) {
        let newViews = newVals.map({
            (type:TypeSpot) -> SpotEllipse in
            
            let randomP = randomOutsidePosition()
            
            let newView = SpotEllipse(frame: CGRect(x: randomP.x, y: randomP.y, width: 75, height: 75))
            self.view.addSubview(newView)
            
            setupButton(sender: newView, type:type)
            
            return newView
        })
        
        ellipseInTheGround.value.append(contentsOf: newViews)
    }
    
    private func randomOutsidePosition() -> CGPoint {
        
        var randomX:Double!
        if Double.random(min: -1.0, max: 1.0) > 0 {
            randomX = Double.random(min: -75.0, max: 0.0)
        } else {
            randomX = Double.random(min: Double(UIScreen.main.bounds.size.width), max: Double(UIScreen.main.bounds.size.width) + 75.0)
        }
        
        var randomY:Double!
        if Double.random(min: -1.0, max: 1.0) > 0 {
            randomY = Double.random(min: -75.0, max: 0.0)
        } else {
            randomY = Double.random(min: Double(UIScreen.main.bounds.size.height), max: Double(UIScreen.main.bounds.size.height) + 75.0)
        }
        
        return CGPoint(x: randomX, y: randomY)
    }
    
    private func setupDelValue(newVals:[TypeSpot]) {
        
        let delViews = ellipseInTheGround.value.filter{newVals.contains($0.type)}
        _ = delViews.map({
            delView in
            ellipseInTheGround.value.remove(at: ellipseInTheGround.value.index(of: delView)!)
            if let index = self.onTheSelection.index(of: delView.type) {
                self.onTheSelection.remove(at: index)
            }
            delView.leaveAndRemove(withDuration: 0.3, toPoint: randomOutsidePosition())
            gravity.removeItem(delView)
            animator.removeBehavior(delView.behavior)
        })
    }
    
    private func setupButton(sender:SpotEllipse, type:TypeSpot) {
        sender.type = type
        sender.rx.tap
            .asObservable()
            .subscribe(onNext: {
                description in
                if let index = self.onTheSelection.index(of: type) {
                    self.onTheSelection.remove(at: index)
                    sender.describe = false
                } else {
                    self.onTheSelection.append(type)
                    sender.describe = true
                }
        }).addDisposableTo(disposableBag)
        animator.addBehavior(sender.behavior)
    }
    @IBAction func btnPressed(_ sender: Any) {
        print(onTheSelection)
    }
}


