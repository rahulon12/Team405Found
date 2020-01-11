//
//  Levels.swift
//  HackthonProject
//
//  Created by Rahul Narayanan on 1/11/20.
//  Copyright © 2020 Rahul Narayanan. All rights reserved.
//

import Foundation
import UIKit

enum GameMode {
    case seek
    case explore
    case learn
}

struct Level {
    var name: String
    var time: Float?
    var flowers: [String]?
    var image: UIImage
    var gameMode: GameMode
    
}
