//
//  DynamicsBall.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 07/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit

protocol DynamicsBallGround {
    
    var dynamicViewTable:[DynamicsBallView]! {get}
    var animator:UIDynamicAnimator! {get}
    
    func createBehavior()
    func removeBehavior()
}

class DynamicsBallViewController: UIViewController, DynamicsBallGround {
    
    var animator: UIDynamicAnimator!
    var dynamicViewTable: [DynamicsBallView]!
    @IBOutlet weak var vGround: UIView!
    
    @IBOutlet weak var h4: NSLayoutConstraint!
    @IBOutlet weak var h3: NSLayoutConstraint!
    @IBOutlet weak var h2: NSLayoutConstraint!
    @IBOutlet weak var h1: NSLayoutConstraint!
    
    @IBOutlet weak var v1: UIView!
    @IBOutlet weak var v2: UIView!
    @IBOutlet weak var v3: UIView!
    @IBOutlet weak var v4: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animator = UIDynamicAnimator(referenceView:vGround)
        dynamicViewTable = [DynamicsBallView]()
        
        let x0 = UIScreen.main.bounds.size.width / 2
        let rayon = CGFloat(x0*0.4)
        
        displayCible(rayon: rayon)
        
        for i in 0..<4 {
            let alphaC = Double(45+90*(i))*Double.pi/Double(180)
            let newBoxC = addBox(center: CGPoint(x: x0, y: x0), alpha: alphaC, rayon: rayon)
            newBoxC.addTarget(self, action: #selector(self.ballPressed(sender:)), for: .touchUpInside)
            dynamicViewTable.append(newBoxC)
            
            let alphaL = Double(45+90*(i)-23)*Double.pi/Double(180)
            let newBoxL = addBox(center: CGPoint(x: x0, y: x0), alpha: alphaL, rayon: rayon)
            newBoxL.addTarget(self, action: #selector(self.ballPressed(sender:)), for: .touchUpInside)
            dynamicViewTable.append(newBoxL)
            
            let alphaR = Double(45+90*(i)+23)*Double.pi/Double(180)
            let newBoxR = addBox(center: CGPoint(x: x0, y: x0), alpha: alphaR, rayon: rayon)
            newBoxR.addTarget(self, action: #selector(self.ballPressed(sender:)), for: .touchUpInside)
            dynamicViewTable.append(newBoxR)
        }
        
        vGround.layer.borderWidth = 1.0
        vGround.layer.borderColor = UIColor.gray.cgColor
        
    }
    
    private func displayCible(rayon:CGFloat) {
        
        let coef1:CGFloat = 1
        let size1 = 2*rayon*coef1*CGFloat(sin(Double(10)*Double.pi/Double(180)))
        
        let coef2:CGFloat = 1.3
        let size2 = 2*rayon*coef2*CGFloat(sin(Double(10)*Double.pi/Double(180)))
        
        let coef3:CGFloat = 1.6
        let size3 = 2*rayon*coef3*CGFloat(sin(Double(10)*Double.pi/Double(180)))
        
        h1.constant = (rayon - size1/2)*2
        h2.constant = (rayon*1.3 - size2/2)*2
        h3.constant = (rayon*1.6 - size3/2)*2
        h4.constant = (rayon*1.6 + size3/2)*2
        
        v1.layer.cornerRadius = (rayon - size1/2)
        v2.layer.cornerRadius = (rayon*1.3 - size2/2)
        v3.layer.cornerRadius = (rayon*1.6 - size3/2)
        v4.layer.cornerRadius = (rayon*1.6 + size3/2)
    }
    
    func ballPressed(sender:UIButton) {
        
    }
    
    func addBox(center:CGPoint, alpha:Double, rayon:CGFloat) -> DynamicsBallView {
        
        let newBox = DynamicsBallView(center: center, alpha: alpha, rayon: rayon)
        newBox.delegate = self
        vGround.addSubview(newBox)
        return newBox
    }
    
    func removeBehavior() {
        
        animator.removeAllBehaviors()
    }
    
    func createBehavior() {
        
        animator.removeAllBehaviors()
        
        let colider = UICollisionBehavior(items: dynamicViewTable)
        colider.translatesReferenceBoundsIntoBoundary = true
        animator.addBehavior(colider)
        
        let gravity = UIGravityBehavior(items: dynamicViewTable)
        gravity.gravityDirection = CGVector(dx: 0.0, dy: 0.8)
        gravity.magnitude = 0.7
        animator.addBehavior(gravity)
        
        //let behavior = UIDynamicItemBehavior(items: dynamicViewTable)
        //behavior.elasticity = 1
        //behavior.density = 3
        //animator.addBehavior(behavior)
    }
}

class DynamicsBallView: UIButton {
    
    var mySize:CGFloat!
    var myAlpha:Double!
    var myRayon:CGFloat!
    var myCenter:CGPoint!
    var myCoef:CGFloat = 1
    var delegate:DynamicsBallGround?
    
    convenience init(center:CGPoint, alpha:Double, rayon:CGFloat) {
        
        let coef:CGFloat = 1
        
        let xOrigin = center.x + rayon*coef*CGFloat(cos(alpha))
        let yOrigin = center.y + rayon*coef*CGFloat(sin(alpha))
        
        let size = 2*rayon*coef*CGFloat(sin(Double(10)*Double.pi/Double(180)))
        
        self.init(frame: CGRect(origin: CGPoint(x: xOrigin-size/2, y: yOrigin-size/2), size: CGSize(width: size, height: size)))
        self.layer.cornerRadius = size/2
        self.mySize = size
        self.myAlpha = alpha
        self.myRayon = rayon
        self.myCenter = center
        self.myCoef = coef
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
    
    func snapToCenter(inAnimator animator:UIDynamicAnimator) {
        let snap = UISnapBehavior(item: self, snapTo: CGPoint(x: 200, y: 200))
        animator.addBehavior(snap)
    }
    
    func dynamicsBallViewPressed() {
        myCoef = myCoef + 0.3
        
        let xOrigin = myCenter.x + myRayon*myCoef*CGFloat(cos(myAlpha))
        let yOrigin = myCenter.y + myRayon*myCoef*CGFloat(sin(myAlpha))
        
        let size = 2*myRayon*myCoef*CGFloat(sin(Double(10)*Double.pi/Double(180)))
        self.mySize = size
        
        UIView.animate(withDuration: 0.5, animations: {
            void in
            self.frame = CGRect(origin: CGPoint(x: xOrigin-size/2, y: yOrigin-size/2), size: CGSize(width: size, height: size))
            self.layer.cornerRadius = size/2
        })
    }
    
    override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            if newValue {
                dynamicsBallViewPressed()
            }
            super.isHighlighted = newValue
        }
    }
}
