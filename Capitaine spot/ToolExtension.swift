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
    print("Download Started : \(url)")
    getDataFromUrl(url: url) {
        (data, response, error)  in
        print("Download finished : \(error)")
        guard let data = data, error == nil else { completion(nil) ; return }
        completion(UIImage(data: data))
    }
}


