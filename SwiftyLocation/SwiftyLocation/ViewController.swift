//
//  ViewController.swift
//  SwiftyLocation
//
//  Created by Chris Hu on 2017/12/5.
//  Copyright © 2017年 com.icetime. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var lbLongitude: UILabel = {
        let lb: UILabel = UILabel(frame:CGRect(x: 50,
                                               y: 50,
                                               width: 200,
                                               height: 50))
        lb.textColor = UIColor.black
        lb.textAlignment = .center
        return lb
    }()
    
    lazy var lbLatitude: UILabel = {
        let lb: UILabel = UILabel(frame:CGRect(x: 50,
                                               y: 150,
                                               width: 200,
                                               height: 50))
        lb.textColor = UIColor.black
        lb.textAlignment = .center
        return lb
    }()
    
    lazy var lbAltitude: UILabel = {
        let lb: UILabel = UILabel(frame:CGRect(x: 50,
                                               y: 250,
                                               width: 200,
                                               height: 50))
        lb.textColor = UIColor.black
        lb.textAlignment = .center
        return lb
    }()
    
    lazy var lbAddress: UILabel = {
        let lb: UILabel = UILabel(frame:CGRect(x: 50,
                                               y: 350,
                                               width: 200,
                                               height: 50))
        lb.textColor = UIColor.black
        lb.textAlignment = .center
        return lb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.addSubview(self.lbLongitude)
        self.view.addSubview(self.lbLatitude)
        self.view.addSubview(self.lbAltitude)
        self.view.addSubview(self.lbAddress)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        SwiftyLocation.shared.delegate = self
        SwiftyLocation.shared.startLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        SwiftyLocation.shared.delegate = nil
        SwiftyLocation.shared.stopLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: SwiftyLocationDelegate {
    func SwiftyLocationDidUpdateLocation(_ csLocation: CSLocation) {
        print(SwiftyLocation.shared.currentCsLocation)
        
        self.lbLongitude.text = "\(csLocation.location.coordinate.longitude)"
        self.lbLatitude.text = "\(csLocation.location.coordinate.latitude)"
        self.lbAltitude.text = "\(csLocation.location.altitude)"
        self.lbAddress.text = csLocation.desc
    }
}

