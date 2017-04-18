//
//  DynamicsFall.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 10/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class GroundView: UIView {
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .ellipse
    }
}

class DynamicsFallViewController: UIViewController {
    
    var animator: UIDynamicAnimator!
    var categoryTable = [DynamicsBall]()
    
    let disposeBag = DisposeBag()
    let selectedTable: Variable<[DynamicsBall]> = Variable([])
    
    var shape = -1
    var sequence = [CategoryName.type, CategoryName.avecQui, CategoryName.ambiance]
    
    let size:CGFloat = 80
    
    var path:UIBezierPath!
    
    var gv:DynamicsBall!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .green
        
        let rect = UIScreen.main.bounds
        
        gv = DynamicsBall(frame: CGRect(x: 0, y: rect.size.height-200, width: rect.size.width, height: 200))
        //gv.layer.cornerRadius = UIScreen.main.bounds.size.width/2
        gv.layer.cornerRadius = 50
        gv.backgroundColor = .blue
        self.view.addSubview(gv)
        
        categoryTable.append(gv)
        
        /*let snapButton = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        self.view.addSubview(snapButton)
        var snapFrame = snapButton.frame
        var innerFrame = CGRect(x: snapFrame.minX + 10, y: snapFrame.minY + 10, width: snapFrame.width - 20, height: snapFrame.height - 20)
        
        let maskLayer = CAShapeLayer()
        var circlePath = UIBezierPath(roundedRect: innerFrame, cornerRadius: innerFrame.width)
        maskLayer.path = circlePath.cgPath
        maskLayer.fillColor = UIColor.clear.cgColor
        
        let shutterOverlay = UIView()
        shutterOverlay.frame = innerFrame
        shutterOverlay.backgroundColor = .blue
        shutterOverlay.layer.addSublayer(maskLayer)
        
        self.view.addSubview(shutterOverlay)
        //self.view.layer.addSublayer(maskLayer)*/
        
        //let rect = CGRect(x: 100, y: 100, width: 100, height: 100)
        /*let mask = UIView(frame: rect)
        mask.alpha = 1
        mask.backgroundColor = .red
        mask.layer.cornerRadius = rect.height / 2
        self.view.mask = mask*/
        
        /*let radius = rect.size.width
        path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height), cornerRadius: 0)
        //let circlePath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 2 * radius, height: 2 * radius), cornerRadius: radius)
        let circlePath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.width), byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: self.view.bounds.size.width/2, height: 50))
        path.append(circlePath)
        path.usesEvenOddFillRule = true
        
        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = kCAFillRuleEvenOdd
        fillLayer.fillColor = UIColor.red.cgColor
        fillLayer.opacity = 0.5
        view.layer.addSublayer(fillLayer)*/
        
        //self.view.layer.cornerRadius = 100
        
        Spot.newSpot.reset()
        animator = UIDynamicAnimator(referenceView:self.view)
        
        setupDynamicsFallObserver()
    }
    
    /*var loadding = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if shape == -1 {
            shape = shape + 1
            sendNextWave()
        }
    }*/
    
    private func setupDynamicsBallObserver(sender:DynamicsBall) {
        /*Spot.newSpot.descriptions.asObservable()
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
            }).addDisposableTo(disposeBag)*/
        
        sender.rx.tap.subscribe({
            event in
            switch event {
            case .next:
                if Spot.newSpot.addDescription(newDescription: sender.myDescription!) {
                    sender.backgroundColor = .blue
                    
                    let instantaneousPush: UIPushBehavior = UIPushBehavior(items: [sender], mode: .instantaneous)
                    instantaneousPush.setAngle( CGFloat(Double.random(min: -Double.pi, max: 0.0)) , magnitude: 10);
                    self.animator.addBehavior(instantaneousPush)
                } else {
                    sender.backgroundColor = .red
                }
            default:
                return
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
            let newBox = DynamicsBall(center: center, size:size, description:desc)
            self.view.addSubview(newBox)
            categoryTable.append(newBox)
            self.setupDynamicsBallObserver(sender:newBox)
        })
        createBehavior()
    }
    
    private func randomCenter() -> CGPoint {
        let minX:Double = Double(self.view.frame.origin.x + self.size)
        let maxX:Double = Double(self.view.frame.origin.x + self.gv.frame.size.width - self.size)
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
        behavior.allowsRotation = false
        animator.addBehavior(behavior)
    }
}

class DynamicsBall: UIButton {
    
    var mySize:CGFloat!
    var myCenter:CGPoint!
    
    var myDescription:DescribeName?
    
    convenience init(center:CGPoint, size:CGFloat, description:DescribeName) {
        
        self.init(center:center, size:size)
        
        self.layer.cornerRadius = size/2
        
        self.mySize = size
        self.myCenter = center
        self.myDescription = description
        
        if let image = description.pic {
            self.setImage(image, for: .normal)
        } else {
            self.setTitle(description.localizedString, for: .normal)
            self.imageView!.contentMode = .scaleAspectFill
        }
    }
    
    convenience init(center:CGPoint, size:CGFloat) {
        
        self.init(frame: CGRect(origin: CGPoint(x: center.x-size/2, y: center.y-size/2), size: CGSize(width: size, height: size)))
        
        self.layer.cornerRadius = size/2
        
        self.mySize = size
        self.myCenter = center
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .red
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.borderWidth = 1
    }
    
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .ellipse
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}





