//
//  MedalBtn.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 27/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit

class BtnMedal:UIButton {
    
    var timer1:Timer?
    var timer2:Timer?
    
    var initImg:UIImage?
    var initText:String?
    
    var initEdgeImg:UIEdgeInsets!
    var initEdgeText:UIEdgeInsets!
    
    var initAligmentText:NSTextAlignment!
    var initFontText:UIFont!
    
    func disabledMedal(disabled:Bool) {
        
        if disabled {
            
            if let timer1 = timer1 {
                timer1.invalidate()
            }
            
            if let timer2 = timer2 {
                timer2.invalidate()
            }
            
            self.imageEdgeInsets = self.initEdgeImg
            self.titleEdgeInsets = self.initEdgeText
            
            if let initImg = self.initImg {
                self.setImage(initImg.withRenderingMode(.alwaysTemplate), for: .normal)
            } else {
                self.setImage(nil, for: .normal)
            }
            self.setTitle(self.initText, for: .normal)
            
            if self.initText != nil {
                self.titleLabel?.textAlignment = self.initAligmentText!
                self.titleLabel?.font = self.initFontText!
            }
        }
    }
    
    func medalStyle(image:UIImage?, text:String?, delay:TimeInterval) {
        
        initImg = self.image(for: .normal)
        initText = self.title(for: .normal)
        
        initEdgeImg = self.imageEdgeInsets
        initEdgeText = self.titleEdgeInsets
        
        initAligmentText = self.titleLabel?.textAlignment
        initFontText = self.titleLabel?.font
        
        var nextEdgeImg:UIEdgeInsets
        var nextEdgeText:UIEdgeInsets
        if image == nil || text == nil {
            nextEdgeImg = UIEdgeInsets.zero
            nextEdgeText = UIEdgeInsets.zero
        } else {
            nextEdgeImg = UIEdgeInsets(top: 0, left: self.frame.size.width/2 - image!.size.width/2, bottom: self.frame.size.height/2, right: 0)
            nextEdgeText = UIEdgeInsets(top: 0, left: -image!.size.width/2, bottom: -10, right: image!.size.width/2)
        }
        
        timer1 = Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: {
            timer1 in
            
            UIView.transition(with: self, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                
                self.imageEdgeInsets = nextEdgeImg
                self.titleEdgeInsets = nextEdgeText
                
                self.titleLabel?.textAlignment = .center
                self.titleLabel?.font = self.titleLabel?.font.withSize(20)
                
                if let image = image {
                    self.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
                } else {
                    self.setImage(nil, for: .normal)
                }
                self.setTitle(text, for: .normal)
                self.titleLabel?.numberOfLines = 0
            }) {
                ret in
                self.timer2 = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: {
                    timer2 in
                    
                    UIView.transition(with: self, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                        
                        self.imageEdgeInsets = self.initEdgeImg
                        self.titleEdgeInsets = self.initEdgeText
                        
                        if let initImg = self.initImg {
                            self.setImage(initImg.withRenderingMode(.alwaysTemplate), for: .normal)
                        } else {
                            self.setImage(nil, for: .normal)
                        }
                        self.setTitle(self.initText, for: .normal)
                        
                        if self.initText != nil {
                            self.titleLabel?.textAlignment = self.initAligmentText!
                            self.titleLabel?.font = self.initFontText!
                        }
                    })
                })
            }
        })
    }
}

class UIMedal:UIView {
    
    var timer1:Timer?
    
    var imgFace = UIImageView()
    var image:UIImage? {
        didSet{
            if imgFace.image != nil {
                startRotate()
            }
            imgFace.image = image
        }
    }
    
    var text = UILabel()
    var title:String? {
        didSet{
            text.text = title
        }
    }
    var num:Int? {
        didSet{
            text.text = "\(String(describing: num!))%"
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initMedal()
    }
    
    func initMedal() {
        
        self.layer.cornerRadius = frame.size.width/2
        imgFace.translatesAutoresizingMaskIntoConstraints = false
        imgFace.contentMode = .center
        self.addSubview(imgFace)
        
        self.leadingAnchor.constraint(equalTo: imgFace.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: imgFace.trailingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: imgFace.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: imgFace.bottomAnchor).isActive = true
        
        text.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(text)
        
        self.centerXAnchor.constraint(equalTo: text.centerXAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: text.centerYAnchor).isActive = true
        
        text.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        startRotate()
    }
    
    func startRotate() {
        
        if text.text == nil {return}
        
        if let timer1 = timer1 {
            timer1.invalidate()
        }
        
        var delay:TimeInterval = 3
        if let num = num {
            delay = TimeInterval(3*100/num)
        }
        
        timer1 = Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: {
            ret in
            
            UIView.transition(with: self, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                self.text.isHidden = false
                self.imgFace.isHidden = true
                
                self.timer1 = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: {
                    ret in
                    
                    UIView.transition(with: self, duration: 0.5, options: .transitionFlipFromRight, animations: {
                        self.text.isHidden = true
                        self.imgFace.isHidden = false
                    })
                })
            })
        })
    }
}
