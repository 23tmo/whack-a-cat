

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
    
    //@IBOutlet weak var MyCollectionView: UICollectionView!
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
