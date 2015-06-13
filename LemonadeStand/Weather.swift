//
//  Weather.swift
//  LemonadeStand
//
//  Created by James Hicks on 6/13/15.
//  Copyright (c) 2015 zorch!. All rights reserved.
//

import Foundation

enum Weather: String {
  case Cold = "Cold"
  case Mild = "Mild"
  case Warm = "Warm"
  
  static func randomize() -> Weather {
    switch arc4random_uniform(3) {
    case 0:
      return .Cold
    case 1:
      return .Mild
    case 2:
      return .Warm
    default:
      return .Mild
    }
  }
  
  func tomorrow() -> Weather {
    switch arc4random_uniform(2) {
    case 0:
      return self
    case 1:
      return Weather.randomize()
    default:
      return self
    }
  }
}