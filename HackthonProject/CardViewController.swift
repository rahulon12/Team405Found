//
//  CardViewController.swift
//  HackthonProject
//
//  Created by Rahul Narayanan on 1/11/20.
//  Copyright © 2020 Rahul Narayanan. All rights reserved.
//

import UIKit

class CardViewController: UIViewController {

    @IBOutlet var handleArea: UIView!
    @IBOutlet var itemLabel: UILabel!
    @IBOutlet var challengeLabel: UILabel!
    
    var level: Level!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        switch level.gameMode {
        case .seek:
            let label = UILabel()
            label.text = "You have to find a \(level.flowers?.first ?? "?")"
            label.frame = CGRect(x: self.view.center.x-185, y: self.view.center.y-100, width: self.view.frame.width, height: 100)
            //label.center = self.view.center
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 25, weight: .heavy)
            self.view.addSubview(label)
            break
        default:
            break
        }
        
    }
    


    

}
