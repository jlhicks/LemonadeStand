//
//  ViewController.swift
//  LemonadeStand
//
//  Created by James Hicks on 6/10/15.
//  Copyright (c) 2015 zorch!. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  // Lemonade stand inventory UI
  @IBOutlet weak var moneyLabel: UILabel!
  @IBOutlet weak var lemonsLabel: UILabel!
  @IBOutlet weak var iceCubesLabel: UILabel!
  
  // Purchase supplies UI
  @IBOutlet weak var purchaseLemonsStepper: UIStepper!
  @IBOutlet weak var purchaseLemonsLabel: UILabel!
  @IBOutlet weak var purchaseIceCubesStepper: UIStepper!
  @IBOutlet weak var purchaseIceCubesLabel: UILabel!
  
  // Lemonade recipe UI
  @IBOutlet weak var mixLemonsStepper: UIStepper!
  @IBOutlet weak var mixLemonsLabel: UILabel!
  @IBOutlet weak var mixIceCubesStepper: UIStepper!
  @IBOutlet weak var mixIceCubesLabel: UILabel!
  
  // Weather report UI
  @IBOutlet weak var weatherImageView: UIImageView!
  
  // Business costs
  let kCostOfLemon = 2
  let kCostOfIceCube = 1
  
  // Starting conditions
  let kStartingCash = 10
  let kStartingLemons = 1
  let kStartingIceCubes = 1
  
  // Cash and inventory
  var cashOnHand = 0
  var lemons = 0
  var iceCubes = 0
  
  // Purchase orders
  var lemonsToPurchase = 0
  var iceCubesToPurchase = 0
  
  // Recipe proportions
  var lemonsToMix = 0
  var iceCubesToMix = 0
  
  // Externalities
  var weather = Weather.Mild
  
  // Daily stats
  var lemonadeAcidity = 0.0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    cashOnHand = kStartingCash
    lemons = kStartingLemons
    iceCubes = kStartingIceCubes
    updateDashboard()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func purchaseLemonsStepperChanged(sender: UIStepper) {
    lemonsToPurchase = Int(sender.value)
    if lemonsToPurchase * kCostOfLemon > cashOnHand - iceCubesToPurchase * kCostOfIceCube {
      lemonsToPurchase = (cashOnHand - iceCubesToPurchase * kCostOfIceCube) / kCostOfLemon
      sender.value = Double(lemonsToPurchase)
    }
    if lemonsToMix > lemons + lemonsToPurchase {
      lemonsToMix = lemons + lemonsToPurchase
      mixLemonsStepper.value = Double(lemonsToMix)
    }
    updateDashboard()
  }
  
  @IBAction func purchaseIceCubesStepperChanged(sender: UIStepper) {
    iceCubesToPurchase = Int(sender.value)
    if iceCubesToPurchase * kCostOfIceCube > cashOnHand - lemonsToPurchase * kCostOfLemon {
      iceCubesToPurchase = (cashOnHand - lemonsToPurchase * kCostOfLemon) / kCostOfIceCube
      sender.value = Double(iceCubesToPurchase)
    }
    if iceCubesToMix > iceCubes + iceCubesToPurchase {
      if iceCubesToMix > iceCubes + iceCubesToPurchase {
        iceCubesToMix = iceCubes + iceCubesToPurchase
        mixIceCubesStepper.value = Double(iceCubesToMix)
      }
    }
    updateDashboard()
  }

  @IBAction func mixLemonsStepperChanged(sender: UIStepper) {
    lemonsToMix = Int(sender.value)
    if lemonsToMix > lemons + lemonsToPurchase {
      lemonsToMix = lemons + lemonsToPurchase
      sender.value = Double(lemonsToMix)
    }
    lemonadeAcidity = Double(lemonsToMix) / Double(iceCubesToMix)
    updateDashboard()
  }

  @IBAction func mixIceCubesStepperChanged(sender: UIStepper) {
    iceCubesToMix = Int(sender.value)
    if iceCubesToMix > iceCubes + iceCubesToPurchase {
      iceCubesToMix = iceCubes + iceCubesToPurchase
      sender.value = Double(iceCubesToMix)
    }
    lemonadeAcidity = Double(lemonsToMix) / Double(iceCubesToMix)
    updateDashboard()
  }

  @IBAction func startDay() {
    var customers:[Customer] = []
    
    // Bookkeeping for supplies
    cashOnHand -= lemonsToPurchase * kCostOfLemon
    cashOnHand -= iceCubesToPurchase * kCostOfIceCube
    lemons += lemonsToPurchase - lemonsToMix
    iceCubes += iceCubesToPurchase - iceCubesToMix
    
    weather = weather.tomorrow()
    println("Weather: \(weather.rawValue)")
    var customerCount = Int(arc4random_uniform(10))
    switch weather {
    case .Cold:
      customerCount -= 3
    case .Mild:
      customerCount += 0
    case .Warm:
      customerCount += 4
    }
    
    if customerCount < 0 {
      customerCount = 0
    }
    
    for i in 0...customerCount {
      customers.append(Customer())
    }
    
    if lemonsToMix != 0 && iceCubesToMix != 0 {
      for (customerNumber, customer) in enumerate(customers) {
        if customer.considerLemonade(lemonadeAcidity) {
          println("Customer \(customerNumber): acidity \(lemonadeAcidity)  preference \(customer.tastePreference)  Paid!")
          cashOnHand++
        } else {
          println("Customer \(customerNumber): acidity \(lemonadeAcidity)  preference \(customer.tastePreference)  No match, no revenue.")
        }
      }
    } else {
      println("No lemonade today.")
    }
    
    // Reset the UI for the next day.
    lemonsToMix = 0
    iceCubesToMix = 0
    lemonsToPurchase = 0
    iceCubesToPurchase = 0
    weatherImageView.image = UIImage(named: weather.rawValue)

    updateDashboard()
    
    // Are we out of cash?
    if cashOnHand == 0 && lemons == 0 && iceCubes == 0 {
      var alert = UIAlertController(title: "Bankrupt!", message: "You have run out of money and supplies, and your stand is in foreclosure.", preferredStyle: UIAlertControllerStyle.Alert)
      alert.addAction(UIAlertAction(title: "Reset Game", style: UIAlertActionStyle.Default, handler: nil))
      self.presentViewController(alert, animated: true, completion: nil)
      self.cashOnHand = self.kStartingCash
      self.lemons = self.kStartingLemons
      self.iceCubes = self.kStartingIceCubes
      weather = .Mild
      self.updateDashboard()
    }
  }
  
  func updateDashboard() {
    moneyLabel.text = "$\(cashOnHand)"
    lemonsLabel.text = "\(lemons) Lemon" + (lemons == 1 ? "" : "s")
    iceCubesLabel.text = "\(iceCubes) Ice Cube" + (iceCubes == 1 ? "" : "s")
    purchaseLemonsLabel.text = "\(lemonsToPurchase)"
    purchaseLemonsStepper.value = Double(lemonsToPurchase)
    purchaseIceCubesLabel.text = "\(iceCubesToPurchase)"
    purchaseIceCubesStepper.value = Double(iceCubesToPurchase)
    mixLemonsLabel.text = "\(lemonsToMix)"
    mixLemonsStepper.value = Double(lemonsToMix)
    mixIceCubesLabel.text = "\(iceCubesToMix)"
    mixIceCubesStepper.value = Double(iceCubesToMix)
    weatherImageView.image = UIImage(named: weather.rawValue)
  }
}

