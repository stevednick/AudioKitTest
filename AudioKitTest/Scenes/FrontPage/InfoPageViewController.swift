//
//  InfoPageViewController.swift
//  Farkas
//
//  Created by Stephen Nicholls on 17/03/2020.
//  Copyright © 2020 Stephen Nicholls. All rights reserved.
//

import Foundation

import UIKit
import WebKit

class InfoPageViewController: UIViewController {

  @IBOutlet weak var webView: WKWebView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let htmlPath = Bundle.main.path(forResource: "BullsEye", ofType: "html") {
      let url = URL(fileURLWithPath: htmlPath)
      let request = URLRequest(url: url)
      webView.load(request)
    }
  }
  
  @IBAction func close() {
    dismiss(animated: true, completion: nil)
  }
}
