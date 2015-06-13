//
//  Customer.swift
//  LemonadeStand
//
//  Created by James Hicks on 6/13/15.
//  Copyright (c) 2015 zorch!. All rights reserved.
//

import Foundation

struct Customer {
  var tastePreference = 0.0
  
  init() {
    tastePreference = Double(arc4random()) / Double(UInt32.max)
  }
  
  func considerLemonade(acidity:Double) -> Bool {
    var willBuy = false
    
    if acidity > 1 && tastePreference <= 0.4 {
      willBuy = true
    } else if acidity < 1 && tastePreference > 0.6 {
      willBuy = true
    } else if acidity == 1 && tastePreference > 0.4 && tastePreference <= 0.6 {
      willBuy = true
    }
    
    return willBuy
  }
}