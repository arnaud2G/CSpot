//
//  ViewController.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 07/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import RxSwift
import RxCocoa

class MenuViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var lblT1: UILabel!
    @IBOutlet weak var lblT2: UILabel!
    @IBOutlet weak var lblT3: UILabel!
    
    @IBOutlet weak var btnLogout: UIButton!
    
    @IBOutlet weak var btnTop: BtnMedal!
    @IBOutlet weak var btnBottom: BtnMedal!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "woodtexture"))
        
        btnLogout.setImage(#imageLiteral(resourceName: "skull").withRenderingMode(.alwaysTemplate), for: .normal)
        btnLogout.selectedStyle()
        btnLogout.layer.cornerRadius = 15
        
        lblT1.textColor = UIColor().secondary()
        lblT2.textColor = UIColor().secondary()
        lblT3.textColor = UIColor().secondary()
        
        User.current.connected
            .asObservable()
            .subscribe(onNext:{
                description in
                if description {
                    self.btnLogout.isHidden = false
                } else {
                    self.btnLogout.isHidden = true
                }
            }).addDisposableTo(disposeBag)
        
        btnTop.layer.cornerRadius = btnTop.frame.height/2
        btnTop.clipsToBounds = true
        btnTop.unselectedStyle()
        btnTop.setImage(#imageLiteral(resourceName: "treasure-map").withRenderingMode(.alwaysTemplate), for: .normal)
        
        btnBottom.layer.cornerRadius = btnBottom.frame.height/2
        btnBottom.clipsToBounds = true
        btnBottom.unselectedStyle()
        
        User.current.connected
            .asObservable()
            .subscribe(onNext:{
                description in
                if description {
                    self.btnBottom.setImage(#imageLiteral(resourceName: "spyglass").withRenderingMode(.alwaysTemplate), for: .normal)
                } else {
                    self.btnBottom.setImage(#imageLiteral(resourceName: "pirate").withRenderingMode(.alwaysTemplate), for: .normal)
                }
            }).addDisposableTo(disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        User.current.cSpotScreen.value = .menu
        if User.current.connected.value {
            btnBottom.medalStyle(image: #imageLiteral(resourceName: "pirate"), text: "Utilise la longue vue pour décrire le spot !", delay: 1.5)
        } else {
            btnBottom.medalStyle(image: #imageLiteral(resourceName: "pirate"), text: "Connecte toi pour utiliser la longue vue !", delay: 1.5)
        }
        btnTop.medalStyle(image: #imageLiteral(resourceName: "pirate"), text: "Utilise la map pour trouver un bon spot !", delay:3.5)
    }
    
    @IBAction func btnTopPressed(_ sender: Any) {
        let loginStoryboard = UIStoryboard(name: "Search", bundle: nil)
        let loginController = loginStoryboard.instantiateInitialViewController()
        present(loginController!, animated: false)
    }
    
    @IBAction func btnBottomPressed(_ sender: Any) {
        if User.current.connected.value {
            User.current.cSpotScreen.value = .camera
        } else {
            let loginStoryboard = UIStoryboard(name: "SignIn", bundle: nil)
            let loginController = loginStoryboard.instantiateInitialViewController()
            present(loginController!, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnLogoutPressed(_ sender: Any) {
        
        if (AWSIdentityManager.default().isLoggedIn) {
            AWSIdentityManager.default().logout(completionHandler: {
                (result: Any?, error: Error?) in
                if let error = error {
                    print("error lors de la deconexion : \(error)")
                } else if let result = result {
                    print("retour de la deconnexion : \(result)")
                }
            })
        }
    }
    
    /*let transition = PopAnimator()
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = true
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = false
        return transition
    }*/
}


class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning, CAAnimationDelegate {
    
    let duration = 1.0
    var presenting = true
    var originFrame = CGRect.zero
    
    var dismissCompletion: (()->Void)?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        if presenting {
            animatePresent(using: transitionContext)
        } else {
            animateDismiss(using: transitionContext)
        }
    }
    
    weak var transitionContext: UIViewControllerContextTransitioning!
    
    private func animatePresent(using transitionContext: UIViewControllerContextTransitioning) {
        
        //2
        let containerView = transitionContext.containerView
        let menuViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! MenuViewController
        let presentedViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        
        //3
        containerView.addSubview(presentedViewController!.view)
        
        // Size
        let lWidth = UIScreen.main.bounds.size.width/2
        let lHeight = UIScreen.main.bounds.size.height/2
        
        let rayon = sqrt((lWidth*lWidth)+(lHeight*lHeight))
        
        //4
        let circleMaskPathInitial = UIBezierPath(ovalIn: menuViewController.btnBottom.frame)
        let circleMaskPathFinal = UIBezierPath(ovalIn: CGRect(x: lWidth - rayon, y: lHeight - rayon, width: 2*rayon, height: 2*rayon))
        //5
        let maskLayer = CAShapeLayer()
        maskLayer.path = circleMaskPathFinal.cgPath
        presentedViewController!.view.layer.mask = maskLayer
        
        //6
        let maskLayerAnimation = CASpringAnimation(keyPath: "path")
        maskLayerAnimation.damping = 6
        maskLayerAnimation.initialVelocity = 1
        maskLayerAnimation.fromValue = circleMaskPathInitial.cgPath
        maskLayerAnimation.toValue = circleMaskPathFinal.cgPath
        maskLayerAnimation.duration = self.transitionDuration(using: transitionContext)
        maskLayerAnimation.delegate = self
        maskLayer.add(maskLayerAnimation, forKey: "path")
    }
    
    private func animateDismiss(using transitionContext: UIViewControllerContextTransitioning) {
        
        //2
        let presentedViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let menuViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! MenuViewController
        
        //3
        //
        
        // Size
        let lWidth = UIScreen.main.bounds.size.width/2
        let lHeight = UIScreen.main.bounds.size.height/2
        
        let rayon = sqrt((lWidth*lWidth)+(lHeight*lHeight))
        
        //4
        let circleMaskPathFinal = UIBezierPath(ovalIn: CGRect(origin: menuViewController.btnBottom.center, size: CGSize.zero))
        let circleMaskPathInitial = UIBezierPath(ovalIn: CGRect(x: lWidth - rayon, y: lHeight - rayon, width: 2*rayon, height: 2*rayon))
        //5
        let maskLayer = CAShapeLayer()
        maskLayer.path = circleMaskPathFinal.cgPath
        presentedViewController!.view.layer.mask = maskLayer
        
        //6
        let maskLayerAnimation = CABasicAnimation(keyPath: "path")
        maskLayerAnimation.fromValue = circleMaskPathInitial.cgPath
        maskLayerAnimation.toValue = circleMaskPathFinal.cgPath
        maskLayerAnimation.duration = 0.2
        maskLayerAnimation.delegate = self
        maskLayer.add(maskLayerAnimation, forKey: "path")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.transitionContext.completeTransition(true)
    }
}

