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

class VueC2: UIViewController {
    
    let btnSize:CGFloat = 60
    let cancelButton = UIButton()
    let valideButton = UIButton()
    let tfSpot = UITextField()
    
    var animator: UIDynamicAnimator!
    var gravity:UIFieldBehavior!
    var collision:UICollisionBehavior?
    
    let disposableBag = DisposeBag()
    @IBOutlet weak var imgPic: UIImageView!
    @IBOutlet weak var vPic: UIView!
    
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
            
            if onTheSelection.count > 0 {
                self.valideButton.isEnabled = true
            } else {
                self.valideButton.isEnabled = false
            }
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
        
        displayTopScreen()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let vueC2 = SpotLocationViewController()
        vueC2.modalPresentationStyle = .overCurrentContext
        self.present(vueC2, animated: false, completion: {})
    }
    
    private func displayTopScreen() {
        
        // Position
        tfSpot.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tfSpot)
        tfSpot.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        tfSpot.heightAnchor.constraint(equalToConstant: 40).isActive = true
        tfSpot.topAnchor.constraint(equalTo: self.view.topAnchor, constant:40).isActive = true
        tfSpot.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant:60).isActive = true
        tfSpot.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant:-60).isActive = true
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(cancelButton)
        
        cancelButton.trailingAnchor.constraint(equalTo: self.view.centerXAnchor, constant:-10).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant:-40).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: btnSize).isActive = true
        cancelButton.widthAnchor.constraint(equalTo: cancelButton.heightAnchor).isActive = true
        
        valideButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(valideButton)
        
        valideButton.leadingAnchor.constraint(equalTo: self.view.centerXAnchor, constant:10).isActive = true
        valideButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant:-40).isActive = true
        valideButton.heightAnchor.constraint(equalToConstant: btnSize).isActive = true
        valideButton.widthAnchor.constraint(equalTo: valideButton.heightAnchor).isActive = true
        
        // Attributes
        tfSpot.placeholder = NSLocalizedString("Ou êtes vous ?", comment: "Ou êtes vous ?")
        
        tfSpot.layer.cornerRadius = 20
        tfSpot.unselectedStyle()
        tfSpot.isEnabled = false
        
        valideButton.setBackgroundImage(#imageLiteral(resourceName: "ok"), for: .normal)
        valideButton.setBackgroundImage(#imageLiteral(resourceName: "ok_disabled"), for: .disabled)
        valideButton.isEnabled = false
        cancelButton.setBackgroundImage(#imageLiteral(resourceName: "nook"), for: .normal)
        
        valideButton.addTarget(self, action: #selector(self.valideDescription(sender:)), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(self.cancelDescription(sender:)), for: .touchUpInside)
        
        imgPic.image = Spot.newSpot.picture.value
        self.vPic.isHidden = true
        self.cancelButton.isHidden = true
        self.valideButton.isHidden = true
        self.tfSpot.isHidden = true
        
        Spot.newSpot.title.asObservable()
            .subscribe(onNext: {
                description in
                if description == String() {
                    self.tfSpot.isHidden = true
                } else {
                    self.tfSpot.text = description
                    self.tfSpot.isHidden = false
                    self.onTheGround.append(contentsOf: TypeSpot.spot.nextType)
                    self.vPic.isHidden = false
                    self.cancelButton.isHidden = false
                    self.valideButton.isHidden = false
                }
            }).addDisposableTo(disposableBag)
    }
    
    func valideDescription(sender:UIButton) {
        Spot.newSpot.descriptions = onTheSelection
        print(Spot.newSpot.picture.value)
        print(Spot.newSpot.coordinate)
        print(Spot.newSpot.adress)
        print(Spot.newSpot.title.value)
        print(Spot.newSpot.place)
        print(Spot.newSpot.descriptions)
        self.dismiss(animated: true, completion: nil)
    }
    
    func cancelDescription(sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
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
}


