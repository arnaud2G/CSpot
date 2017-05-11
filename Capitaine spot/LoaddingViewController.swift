//
//  LoaddingViewController.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 11/05/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit

enum CSPotMess: CustomStringConvertible {
    
    case Fail(NSError,Bool)
    case Succeed(String,Bool)
    
    var description: String {
        switch self {
        case .Fail(let error, _):
            if let mess = error.userInfo["NSLocalizedDescription"] as? String {
                return mess
            } else if let mess = error.userInfo["message"] as? String {
                return mess
            }
            fatalError("Le cas suivant n'est pas traité : \(error.userInfo)")
        case .Succeed(let message, _):
            return message
        }
    }
    
    var toRoot: Bool {
        switch self {
        case .Fail(_, let bool):
            return bool
        case .Succeed(_, let bool):
            return bool
        }
    }
}

class LoaddingViewController:UIViewController, CAAnimationDelegate {
    
    deinit {
        print("deinit LoaddingViewController")
        NotificationCenter.default.removeObserver(myNotif)
    }
    
    var message:String = NSLocalizedString("Chargement...", comment: "Chargement...")
    var timer:Timer?
    var myNotif:AnyObject!
    
    @IBOutlet weak var lblWait: UILabel!
    @IBOutlet weak var vTop: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hRef = UIScreen.main.bounds.size.height
        let wRef = UIScreen.main.bounds.size.width
        let hBez = hRef*950/667
        let xBez = wRef*150/375
        let yBez = hRef*150/667
        
        // Habillade de la vue
        let circleMaskPathFinal = UIBezierPath(ovalIn: CGRect(x: xBez-(hBez/2), y: yBez-(hBez/2), width: hBez, height: hBez))
        let maskLayer = CAShapeLayer()
        maskLayer.path = circleMaskPathFinal.cgPath
        vTop.layer.mask = maskLayer
        
        // Message d'attente
        lblWait.text = message
        lblWait.textColor = .white
        
        // Gestion des messages
        myNotif = NotificationCenter.default.addObserver(forName: CSpotNotif.message.name, object: nil, queue: OperationQueue.main, using: {
            [weak self] (note: Notification) -> Void in
            guard let cSPotMess = note.object as? CSPotMess else {return}
            self?.recievedMessage(cSPotMess: cSPotMess)
        })
        
        /*let toto = CSPotMess.Fail("Cooooooolllll")
        print(toto)
        
        switch toto {
        case .Fail(let message):
            print("Type fail")
        case .Succeed(let message):
            print("Type Succeed")
        }*/
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        sendShip()
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.sendShip), userInfo: nil, repeats: true)
    }
    
    func sendShip() {
        
        // Calcul de la courbe
        let y1 = Double.random(min: 100, max: Double(UIScreen.main.bounds.size.height) - 100)
        let x1 = -60.0
        let y2 = Double.random(min: 100, max: Double(UIScreen.main.bounds.size.height) - 100)
        let x2 = Double(UIScreen.main.bounds.size.width) + 60
        
        
        let a = (y2 - y1)/(x2 - x1)
        let b = y1 - a*x1
        
        let xA = Double(UIScreen.main.bounds.width) / 3
        let xB = 2 * Double(UIScreen.main.bounds.width) / 3
        
        var yA = xA*a + b
        var yB = xB*a + b
        
        let offSet = Double.random(min: -200.0, max: 200.0)
        yA = yA + offSet
        yB = yB - offSet
        let path = UIBezierPath()
        path.move(to: CGPoint(x: x1,y: y1))
        path.addCurve(to: CGPoint(x: x2, y: y2), controlPoint1: CGPoint(x: xA, y: yA), controlPoint2: CGPoint(x: xB, y: yB))
        
        let anim = CAKeyframeAnimation(keyPath: "position")
        anim.path = path.cgPath
        anim.rotationMode = kCAAnimationRotateAuto
        anim.duration = 5.0
        
        // Création du beateau
        let ship = UIImageView()
        ship.frame = CGRect(x: x1, y: y1, width: 60, height: 60)
        ship.image = #imageLiteral(resourceName: "ship").withRenderingMode(.alwaysTemplate)
        ship.tintColor = .white
        self.view.addSubview(ship)
        
        // On ajoute l'animation au bateau
        ship.layer.add(anim, forKey: "animate position along path")
    }
    
    var toRoot = false
    private func recievedMessage(cSPotMess:CSPotMess) {
        
        self.toRoot = cSPotMess.toRoot
        
        let vError = ErrorView(message: cSPotMess.description)
        vError.translatesAutoresizingMaskIntoConstraints = false
        vError.btnOk.addTarget(self, action: #selector(self.btnOkPressed(sender:)), for: .touchUpInside)
        
        self.view.addSubview(vError)
        vError.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        vError.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        vError.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.leadingAnchor, constant:20).isActive = true
    }
    
    func btnOkPressed(sender:UIButton) {
        if let timer = self.timer {timer.invalidate()}
        if toRoot {
            self.navigationController?.popToRootViewController(animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
