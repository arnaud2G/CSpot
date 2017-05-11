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
import CoreLocation
import MapboxGeocoder
import MapKit

class ListSearchController:SearchViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var tvAdress: UITextField!
    @IBOutlet weak var btnMap: UIButton!
    @IBOutlet weak var btnRecentre: UIButton!
    
    @IBOutlet weak var tvResult: UITableView!
    @IBOutlet weak var vIndicator: UIActivityIndicatorView!
    
    let disposeBag = DisposeBag()
    
    deinit {
        print("deinit SearchViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnBack.tintColor = UIColor().primary()
        btnBack.setImage(#imageLiteral(resourceName: "delete").withRenderingMode(.alwaysTemplate), for: .normal)
        btnMap.tintColor = UIColor().primary()
        btnMap.setImage(#imageLiteral(resourceName: "beach").withRenderingMode(.alwaysTemplate), for: .normal)
        btnRecentre.tintColor = UIColor().primary()
        btnRecentre.setImage(#imageLiteral(resourceName: "pirate").withRenderingMode(.alwaysTemplate), for: .normal)
        
        tvAdress.unselectedStyle()
        tvAdress.layer.cornerRadius = 20
        tvAdress.delegate = self
        tvAdress.textAlignment = .left
        
        tvResult.estimatedRowHeight = 120
        tvResult.rowHeight = UITableViewAutomaticDimension
        
        transRect = btnMap.frame
        transBtn = btnMap
    }
    
    var isAppear = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isAppear {
            isAppear = true
            Search.main.searchResult.asObservable()
                .subscribe(onNext:{
                    [weak self] searching in
                    guard let searching = searching else {return}
                    self?.btnMap.isHidden = searching
                    self?.vIndicator.isHidden = !searching
                }).addDisposableTo(disposeBag)
            
            Search.main.reverse.asObservable()
                .subscribe(onNext:{
                    [weak self] tReverse in
                    self?.tvResult.reloadSections([1], with: .fade)
                }).addDisposableTo(disposeBag)
            
            Search.main.result.asObservable()
                .subscribe(onNext:{
                    [weak self] spots in
                    self?.tvResult.reloadSections([2], with: .fade)
                }).addDisposableTo(disposeBag)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        } else if section == 1 {
            return Search.main.reverse.value.count
        } else {
            return Search.main.result.value.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as! SearchCell
            cell.place = Search.main.reverse.value[indexPath.row]
            return cell
        }
        
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SpotCell") as! SpotCell
            cell.spot = Search.main.result.value[indexPath.row]
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchingCell")!
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            Search.main.place.value = Search.main.reverse.value[indexPath.row].addressDictionary!["City"] as? String
            Search.main.placeCoo.value = Search.main.reverse.value[indexPath.row].coordinate
            tvAdress.endEditing(true)
            Search.main.reverse.value = [MKPlacemark]()
        }
        if indexPath.section == 2 {
            let cell = tableView.cellForRow(at: indexPath) as! SpotCell
            User.current.selectedSpot = cell.spot
            User.current.cSpotScreen.value = .spot
        }
    }
    
    var textFieldDisposable:Disposable!
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textFieldDisposable = textField.rx.text
            .debounce(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                adress in
                if let adress = adress {
                    Search.main.forwardGeocoding(address: adress)
                }
            })
        textFieldDisposable.addDisposableTo(disposeBag)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textFieldDisposable.dispose()
    }
    
    @IBAction func btnBackPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnRecentrePressed(_ sender: Any) {
        if Search.main.reverse.value.count > 0 {
            textFieldDisposable.dispose()
            Search.main.reverse.value = [MKPlacemark]()
        } else {
            tvAdress.endEditing(true)
            tvAdress.text = String()
            Search.main.place.value = User.current.place.value
            Search.main.placeCoo.value = User.current.location.value
        }
    }
}

class SpotCell:UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
        
        if let customView = Bundle.main.loadNibNamed("SpotView", owner: self, options: nil)!.first as? SpotView {
            
            customView.translatesAutoresizingMaskIntoConstraints = false
            customView.tag = 100
            contentView.addSubview(customView)
            contentView.centerXAnchor.constraint(equalTo: customView.centerXAnchor).isActive = true
            contentView.centerYAnchor.constraint(equalTo: customView.centerYAnchor).isActive = true
            contentView.trailingAnchor.constraint(equalTo: customView.trailingAnchor).isActive = true
            contentView.topAnchor.constraint(equalTo: customView.topAnchor, constant:-5).isActive = true
        }
    }
    
    private func initCell() {
        (contentView.viewWithTag(100) as! SpotView).initCell()
    }
    
    var spot:AWSSpots!{
        didSet {
            (contentView.viewWithTag(100) as! SpotView).initCell()
            (contentView.viewWithTag(100) as! SpotView).completeCell(spot: spot)
        }
    }
}

class SearchCell:UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
        
        lblName.textColor = UIColor().primary()
        lblName.setContentHuggingPriority(.infinity, for: .vertical)
    }
    
    var place:MKPlacemark!{
        didSet {
            lblName.text = self.place.stringAddress2
            layoutIfNeeded()
        }
    }
}


