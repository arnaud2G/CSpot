//
//  SearchNavigationController.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 24/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class SearchViewController:UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tvResult: UITableView!
    var result = [AWSSpots]()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tvResult.delegate = self
        tvResult.dataSource = self
        
        tvResult.estimatedRowHeight = 100
        tvResult.rowHeight = UITableViewAutomaticDimension
        
        AWSTableSpot.main.getClosestSpot(place: User.current.place.value!)
        AWSTableSpot.main.results.asObservable()
            .subscribe(onNext:{
                description in
                self.result = description
                self.tvResult.reloadData()
            }).addDisposableTo(disposeBag)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SpotCell") as! SpotCell
        cell.spot = result[indexPath.row]
        return cell
    }
}

class SpotCell:UITableViewCell {
    
    let size1:CGFloat = 100
    let size2:CGFloat = 60
    
    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var imgMedal1: UIImageView!
    @IBOutlet weak var imgMedal2: UIImageView!
    @IBOutlet weak var imgMedal3: UIImageView!
    @IBOutlet weak var imgMedal4: UIImageView!
    
    @IBOutlet weak var hMedal1: NSLayoutConstraint!
    @IBOutlet weak var hMedal2: NSLayoutConstraint!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        hMedal1.constant = size1
        hMedal2.constant = size2
        
        imgMedal1.unselectedStyle()
        imgMedal2.unselectedStyle()
        imgMedal3.unselectedStyle()
        imgMedal4.unselectedStyle()
        
        imgMedal1.layer.cornerRadius = size1/2
        imgMedal2.layer.cornerRadius = size2/2
        imgMedal3.layer.cornerRadius = size2/2
        imgMedal4.layer.cornerRadius = size2/2
    }
    
    private func initCell() {
        imgBack.image = nil
        imgMedal1.image = nil
        imgMedal2.image = nil
        imgMedal3.image = nil
        imgMedal4.image = nil
    }
    
    var spot:AWSSpots!{
        didSet {
            
            initCell()
            
            lblTitle.text = self.spot._name
            
            let descriptions = self.spot.userDescription.filter{$0.typeSpot.pic != nil}.sorted{$0.rVote > $1.rVote}
            
            imgMedal1.image = descriptions.first!.typeSpot.pic!.withRenderingMode(.alwaysTemplate)
            
            if descriptions.count > 1 {
                imgMedal2.image = descriptions[1].typeSpot.pic!.withRenderingMode(.alwaysTemplate)
            }
            
            if descriptions.count > 2 {
                imgMedal3.image = descriptions[2].typeSpot.pic!.withRenderingMode(.alwaysTemplate)
            }
            
            if descriptions.count > 3 {
                imgMedal4.image = descriptions[3].typeSpot.pic!.withRenderingMode(.alwaysTemplate)
            }
            
            if let pictures = self.spot._pictureId, pictures.count > 0 {
                guard let url = AWSS3.convertToPublicURLRepository(url: pictures[Int.random(lower: 0, upper: pictures.count - 1)]) else {return}
                getImageFromUrl(url:url, completion: {
                    image in
                    DispatchQueue.main.async(execute: {
                        () -> Void in
                        if let image = image {
                            self.imgBack.image = image
                        }
                    })
                })
            }
        }
    }
}


