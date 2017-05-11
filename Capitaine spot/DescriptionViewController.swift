//
//  DescriptionViewController.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 10/05/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class DescriptionViewController: UIViewController {
    
    // Arrière plan
    @IBOutlet weak var imgSpot: UIImageView!
    
    // Top view
    @IBOutlet weak var btnUncheck: UIButton!
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var tfWhereAreU: UITextField!
    
    // Paramètres des comportements
    var animator: UIDynamicAnimator!
    var gravity:UIFieldBehavior!
    var collision:UICollisionBehavior?
    let behavior = UIDynamicItemBehavior()
    
    // Gestion des descripteurs
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
            var newVals = onTheSelection.filter{!oldValue.contains($0)}.map{$0.nextType}.flatMap{$0}.filter{!onTheGround.contains($0)}
            newVals = Array(Set(newVals))
            onTheGround.append(contentsOf: newVals)
            
            var delVals = onTheGround.filter{!(onTheSelection.map{$0.nextType}.flatMap{$0}).contains($0)}.filter{!TypeSpot.spot.nextType.contains($0)}
            delVals = Array(Set(delVals))
            _ = delVals.map({
                type in
                if let index = onTheGround.index(of: type) {
                    onTheGround.remove(at: index)
                }
            })
            
            if onTheSelection.count > 0 {
                btnCheck.isEnabled = true
                btnCheck.selectedStyle()
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6.0, options: .curveEaseIn, animations: {
                    self.btnCheck.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                })
            } else {
                btnCheck.isEnabled = false
                btnCheck.unselectedStyle()
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6.0, options: .curveEaseIn, animations: {
                    self.btnCheck.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                })
            }
        }
    }

    let disposableBag = DisposeBag()

    deinit {
        print("deinit DescriptionViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgSpot.image = Spot.newSpot.picture.value!
        displayTop()
        
        setupAnimator()
        setupObserver()
        
        onTheGround.append(contentsOf: TypeSpot.spot.nextType)
    }
    
    private func setupAnimator() {
        
        // Init
        animator = UIDynamicAnimator(referenceView: view)
        
        // Gravité
        gravity = UIFieldBehavior.radialGravityField(position: self.view.center)
        gravity.falloff = 0.1
        gravity.strength = 1.7
        self.animator.addBehavior(gravity)
        
        // Comportement
        behavior.elasticity = 0.1
        behavior.density = 1
        behavior.allowsRotation = false
        animator.addBehavior(behavior)
    }
    
    private func setupObserver() {
        
        // Si on ajoute des ellipse il faut les configurer
        ellipseInTheGround.asObservable().subscribe(onNext:{
                [weak self] description in
                self?.defineBehavior(items: description)
            }).addDisposableTo(disposableBag)
        
        // Gestion de la selection des ellipse
        Spot.newSpot.descriptions.asObservable().subscribe(onNext: {
                [weak self] (description:[TypeSpot]) in
                self?.onTheSelection = description
                _ = self?.ellipseInTheGround.value.filter{description.contains($0.type)}.map({
                    ellipse in
                    ellipse.describe = true
                })
            }).addDisposableTo(disposableBag)
    }
    
    private func displayTop() {
        
        tfWhereAreU.layer.cornerRadius = 20
        tfWhereAreU.unselectedStyle()
        tfWhereAreU.isEnabled = false
        tfWhereAreU.text = Spot.newSpot.title.value
        
        btnCheck.unselectedStyle()
        btnCheck.layer.cornerRadius = 20
        btnCheck.setImage(#imageLiteral(resourceName: "ship").withRenderingMode(.alwaysTemplate), for: .normal)
        btnCheck.addTarget(self, action: #selector(self.btnCheckPressed(sender:)), for: .touchUpInside)
        
        btnUncheck.unselectedStyle()
        btnUncheck.layer.cornerRadius = 20
        btnUncheck.setImage(#imageLiteral(resourceName: "skull").withRenderingMode(.alwaysTemplate), for: .normal)
        btnUncheck.addTarget(self, action: #selector(self.btnUncheckPressed(sender:)), for: .touchUpInside)
    }
    
    func btnUncheckPressed(sender:UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func btnCheckPressed(sender:UIButton) {
        Spot.newSpot.descriptions.value = onTheSelection
        User.current.cSpotScreen.value = .loadding
        AWSS3.uploadDataWithCompletion({
            error in
            if let error = error as NSError? {
                NotificationCenter.default.post(name: CSpotNotif.message.name, object: CSPotMess.Fail(error,false))
                return
            }
            AWSTableDescribe.insertNewSpotWithCompletionHandler(){
                error, awsDescribe in
                if let error = error as NSError? {
                    NotificationCenter.default.post(name: CSpotNotif.message.name, object: CSPotMess.Fail(error,false))
                    return
                }
                CDDescribe.addDescribe(descriptions: self.onTheSelection, describe: awsDescribe)
                NotificationCenter.default.post(name: CSpotNotif.message.name, object: CSPotMess.Succeed("Le lieu a été correctement partagé",true))
            }
        })
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
            behavior.addItem(view)
        })
    }
    
    private func setupNewValue(newVals:[TypeSpot]) {
        let newViews = newVals.map({
            (type:TypeSpot) -> SpotEllipse in
            
            let randomP = randomOutsidePosition()
            
            let newView = SpotEllipse(frame: CGRect(x: randomP.x, y: randomP.y, width: 75, height: 75))
            self.view.addSubview(newView)
            
            newView.describe = onTheSelection.contains(type)
            
            setupButton(sender: newView, type:type)
            
            return newView
        })
        
        ellipseInTheGround.value.append(contentsOf: newViews)
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
            behavior.removeItem(delView)
        })
    }
    
    private func setupButton(sender:SpotEllipse, type:TypeSpot) {
        sender.type = type
        sender.rx.tap.asObservable().subscribe(onNext: {
                [weak self] description in
                if let index = self!.onTheSelection.index(of: type) {
                    self?.onTheSelection.remove(at: index)
                    sender.describe = false
                } else {
                    self?.onTheSelection.append(type)
                    sender.describe = true
                }
            }).addDisposableTo(disposableBag)
    }
}
