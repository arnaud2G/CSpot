//
//  TestViewController.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 26/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit

class TestViewController: UIViewController {
    deinit {
        print("deinit TestViewController")
    }
    
    func searchNC() -> SearchNavigationController {
        return self.navigationController as! SearchNavigationController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btnBack = UIButton(frame: CGRect(x: 200, y: 200, width: 200, height: 200))
        btnBack.setTitle("Back", for: .normal)
        btnBack.setTitleColor(.blue, for: .normal)
        btnBack.addTarget(self, action: #selector(self.back(sender:)), for: .touchUpInside)
        
        self.view.addSubview(btnBack)
    }
    
    func back(sender:UIButton) {
        self.navigationController!.dismiss(animated: true, completion: nil)
    }
}
