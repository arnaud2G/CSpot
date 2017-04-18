//
//  DescriptionFall.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 10/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class DescriptionFall {
    
    var animatedView:UIView!
    
    var animator: UIDynamicAnimator!
    var categoryTable = [DynamicsBall]()
    
    let disposeBag = DisposeBag()
    let selectedTable: Variable<[DynamicsBall]> = Variable([])
    
    var shape = 0
    var sequence = [CategoryName.type, CategoryName.avecQui, CategoryName.ambiance]
    
    let size:CGFloat = 80
    
    init(animatedView:UIView) {
        self.animatedView = animatedView
        
        Spot.newSpot.reset()
        animator = UIDynamicAnimator(referenceView:self.animatedView)
        
        //sendNextWave()
        
        setupDynamicsFallObserver()
    }
    
    /*override func viewDidLoad() {
        super.viewDidLoad()
        
        Spot.newSpot.initNewSpot()
        animator = UIDynamicAnimator(referenceView:self.view)
        
        setupDynamicsFallObserver()
    }*/
    
    /*override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if shape == -1 {
            shape = shape + 1
            sendNextWave()
        }
    }*/
    
    private func setupDynamicsBallObserver(sender:DynamicsBall) {
        Spot.newSpot.descriptions.asObservable()
            .subscribe(onNext: {
                descriptions in
                if descriptions.contains(sender.myDescription!) {
                    sender.backgroundColor = .blue
                    
                    let instantaneousPush: UIPushBehavior = UIPushBehavior(items: [sender], mode: .instantaneous)
                    instantaneousPush.setAngle( CGFloat(Double.random(min: -Double.pi, max: 0.0)) , magnitude: 5);
                    self.animator.addBehavior(instantaneousPush)
                } else {
                    sender.backgroundColor = .red
                }
            }).addDisposableTo(disposeBag)
    }
    
    private func setupDynamicsFallObserver() {
        Spot.newSpot.descriptions.asObservable()
            .subscribe(onNext: {
                descriptions in
                // On peut vérifier qu'il ne s'agit pas d'une annulation ici
                self.shape = self.shape + 1
                self.sendNextWave()
            }).addDisposableTo(disposeBag)
    }
    
    func sendNextWave() {
        if shape >= sequence.count {
            return
        }
        let wave = sequence[shape].describe
        _ = wave.map({
            (desc:DescribeName) in
            let center = randomCenter()
            print(center)
            let newBox = DynamicsBall(center: center, size:size, description:desc)
            newBox.setTitle(desc.localizedString, for: .normal)
            self.animatedView.addSubview(newBox)
            categoryTable.append(newBox)
            self.setupDynamicsBallObserver(sender:newBox)
        })
        createBehavior()
    }
    
    private func randomCenter() -> CGPoint {
        let minX:Double = Double(self.animatedView.frame.origin.x + self.size)
        let maxX:Double = Double(self.animatedView.frame.origin.x + self.animatedView.frame.size.width - self.size)
        let randomX = Double.random(min: minX,max: maxX)
        return CGPoint(x: randomX, y: 50)
    }
    
    private func createBehavior() {
        
        animator.removeAllBehaviors()
        
        let colider = UICollisionBehavior(items: categoryTable)
        colider.translatesReferenceBoundsIntoBoundary = true
        animator.addBehavior(colider)
        
        let gravity = UIGravityBehavior(items: categoryTable)
        gravity.gravityDirection = CGVector(dx: 0.0, dy: 0.8)
        gravity.magnitude = 0.7
        animator.addBehavior(gravity)
        
        let behavior = UIDynamicItemBehavior(items: categoryTable)
        behavior.elasticity = 0.2
        behavior.density = 3
        animator.addBehavior(behavior)
    }
}

