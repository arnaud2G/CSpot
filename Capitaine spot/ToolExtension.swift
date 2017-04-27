//
//  MyStructs.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 10/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit

// Enum
struct LocalizedString: ExpressibleByStringLiteral, Equatable {
    
    let v: String
    
    init(key: String) {
        self.v = NSLocalizedString(key, comment: "")
    }
    init(localized: String) {
        self.v = localized
    }
    init(stringLiteral value:String) {
        self.init(key: value)
    }
    init(extendedGraphemeClusterLiteral value: String) {
        self.init(key: value)
    }
    init(unicodeScalarLiteral value: String) {
        self.init(key: value)
    }
}

func ==(lhs:LocalizedString, rhs:LocalizedString) -> Bool {
    return lhs.v == rhs.v
}

func iterateEnum<T: Hashable>(_: T.Type) -> AnyIterator<T> {
    var i = 0
    return AnyIterator {
        let next = withUnsafeBytes(of: &i) { $0.load(as: T.self) }
        if next.hashValue != i { return nil }
        i += 1
        return next
    }
}

// Notification
protocol NotificationName {
    var name: Notification.Name { get }
}

extension RawRepresentable where RawValue == String, Self: NotificationName {
    var name: Notification.Name {
        get {
            return Notification.Name(self.rawValue)
        }
    }
}

enum CSpotNotif: String, NotificationName {
    case takePic, retakePic, validePic
}


func randomOutsidePosition() -> CGPoint {
    
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

extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
    URLSession.shared.dataTask(with: url) {
        (data, response, error) in
        completion(data, response, error)
        }.resume()
}

func getImageFromUrl(url: URL, completion: @escaping (_  image: UIImage?) -> Void) {
    getDataFromUrl(url: url) {
        (data, response, error)  in
        guard let data = data, error == nil else { completion(nil) ; return }
        completion(UIImage(data: data))
    }
}

extension UIButton {
    
    func medalStyle(image:UIImage?, text:String?) {
        
        let initImg = self.image(for: .normal)
        let initText = self.title(for: .normal)
        
        let initEdgeImg = self.imageEdgeInsets
        let initEdgeText = self.titleEdgeInsets
        
        let initAligmentText = self.titleLabel?.textAlignment
        let initFontText = self.titleLabel?.font
        
        var nextEdgeImg:UIEdgeInsets
        var nextEdgeText:UIEdgeInsets
        if image == nil || text == nil {
            nextEdgeImg = UIEdgeInsets.zero
            nextEdgeText = UIEdgeInsets.zero
        } else {
            nextEdgeImg = UIEdgeInsets(top: 0, left: self.frame.size.width/2 - image!.size.width/2, bottom: self.frame.size.height/2, right: 0)
            nextEdgeText = UIEdgeInsets(top: 0, left: -image!.size.width/2, bottom: -10, right: image!.size.width/2)
        }
        
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
            Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: {
                timer in
                
                UIView.transition(with: self, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                    
                    self.imageEdgeInsets = initEdgeImg
                    self.titleEdgeInsets = initEdgeText
                    
                    if let initImg = initImg {
                        self.setImage(initImg.withRenderingMode(.alwaysTemplate), for: .normal)
                    } else {
                        self.setImage(nil, for: .normal)
                    }
                    self.setTitle(initText, for: .normal)
                    
                    if initText != nil {
                        self.titleLabel?.textAlignment = initAligmentText!
                        self.titleLabel?.font = initFontText!
                    }
                })
            })
        }
    }
}


