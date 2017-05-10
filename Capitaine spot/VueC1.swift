//
//  VueC1.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 11/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class VueC1: VueC2 {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Spot.newSpot.reset()
        displayTopScreen()
    }
    
    @IBAction func AnimatePressed(_ sender: Any) {
        
        /*let vueC2 = SpotLocationViewController()
        vueC2.modalPresentationStyle = .overCurrentContext
        self.present(vueC2, animated: false, completion: nil)*/
    }
    
    private func displayTopScreen() {
        
        // Position
        tfSpot.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tfSpot)
        tfSpot.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        tfSpot.heightAnchor.constraint(equalToConstant: 40).isActive = true
        tfSpot.topAnchor.constraint(equalTo: self.view.topAnchor, constant:40).isActive = true
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(cancelButton)
        
        cancelButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant:10).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        cancelButton.centerYAnchor.constraint(equalTo: tfSpot.centerYAnchor).isActive = true
        
        valideButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(valideButton)
        
        valideButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant:-10).isActive = true
        valideButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        valideButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        valideButton.centerYAnchor.constraint(equalTo: tfSpot.centerYAnchor).isActive = true
        
        tfSpot.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant:10).isActive = true
        tfSpot.trailingAnchor.constraint(equalTo: valideButton.leadingAnchor, constant:-10).isActive = true
        
        // Attributes
        tfSpot.placeholder = NSLocalizedString("Ou êtes vous ?", comment: "Ou êtes vous ?")
        tfSpot.alpha = 0
        
        tfSpot.layer.cornerRadius = 20
        tfSpot.unselectedStyle()
        tfSpot.isEnabled = false
        
        valideButton.setBackgroundImage(#imageLiteral(resourceName: "ok"), for: .normal)
        valideButton.setBackgroundImage(#imageLiteral(resourceName: "ok_disabled"), for: .disabled)
        cancelButton.setBackgroundImage(#imageLiteral(resourceName: "nook"), for: .normal)
        
        valideButton.alpha = 0
        cancelButton.alpha = 0
        
        Spot.newSpot.title.asObservable()
            .subscribe(onNext: {
                [weak self] description in
                if description == String() {
                    self?.tfSpot.isHidden = true
                } else {
                    self?.tfSpot.text = description
                    self?.tfSpot.isHidden = false
                    self?.onTheGround.append(contentsOf: TypeSpot.spot.nextType)
                }
            }).addDisposableTo(disposableBag)
    }
}


