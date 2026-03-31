

import UIKit

class MainMenuViewController: UIViewController {

    @IBOutlet weak var Highscore: UILabel!
    @IBOutlet weak var PrevScore: UILabel!
    @IBOutlet weak var StartNewGame: UIButton!
    @IBOutlet weak var Info: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        PrevScore.text = "Previous score: \(getScore())"
        Highscore.text = "Highscore: \(getHighscore())"
    }

}
