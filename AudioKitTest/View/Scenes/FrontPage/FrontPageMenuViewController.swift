//
//  FrontPageMenuViewController.swift
//  Farkas
//
//  Created by Stephen Nicholls on 16/03/2020.
//  Copyright © 2020 Stephen Nicholls. All rights reserved.
//

import UIKit
import FirebaseAnalytics

enum Game: Int {
    case standard
    case challenge
    case blitz
    case listeningOff
    case fixed
    case longNote
}

class FrontPageMenuViewController: UITableViewController {

    var didTapMenuType: ((Game) -> Void)?
    let data = UserDefaults.standard
    

    @IBOutlet weak var standardHighScore: UILabel!
    @IBOutlet weak var challengeHighScore: UILabel!
    @IBOutlet weak var blitzHighScore: UILabel!
    @IBOutlet weak var longNoteHighScore: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sortLabels()
    }
    
    func sortLabels(){
        standardHighScore.text = data.double(forKey: Keys.endlessHighScore).forDisplay()
        challengeHighScore.text = data.double(forKey: Keys.highScore).forDisplay()
        blitzHighScore.text = "\(data.integer(forKey: Keys.blitzNotes)) Notes"
        longNoteHighScore.text = "\(data.double(forKey: Keys.bestHeldNoteTime).forDisplay())s"
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let game = Game(rawValue: indexPath.row) else {return}
        Analytics.logEvent("gameStarted", parameters: ["gameType": game])
        dismiss(animated: true, completion: {
            self.didTapMenuType?(game)
        })
    }
}

