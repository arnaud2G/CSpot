//
//  AWSS3.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 21/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import AWSMobileHubHelper

class AWSS3 {
    
    static let publicURL = "https://s3.amazonaws.com/capitainespots-userfiles-mobilehub-1128628836/public/"
    static let doubleDot = "%3A"
    
    static func convertToPublicURLRepository(url:String) -> URL? {
        let convertUrl = "\(publicURL)\(url.replacingOccurrences(of: ":", with: AWSS3.doubleDot))"
        return URL(string: convertUrl)
    }
    
    static func uploadDataWithCompletion(_ completionHandler: @escaping (_ error: Error?) -> Void) {
        
        guard let picture = Spot.newSpot.picture.value, let id = Spot.newSpot.pictureId else {completionHandler(nil) ; return}
        
        let manager = AWSUserFileManager.defaultUserFileManager()
        
        print(picture.size)
        
        let data = UIImageJPEGRepresentation(picture.resized(toWidth: 1200)!, 0.5)!
        let key = "public/\(id)"
        
        let localContent = manager.localContent(with: data, key: key)
        localContent.uploadWithPin(
            onCompletion: false,
            progressBlock: {
                (content: AWSLocalContent, progress: Progress) -> Void in
                print(progress.fractionCompleted)
        },completionHandler: {
            (content: AWSLocalContent?, error: Error?) -> Void in
            completionHandler(error)
        })
    }
}
