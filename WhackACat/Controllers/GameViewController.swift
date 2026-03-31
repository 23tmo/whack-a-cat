

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController, GameViewControllerDelegate {
    var shouldReset = true
    var scene: GameScene!
    
    @IBOutlet weak var MainMenuButton: UIButton!
  
    func checkButton(){
        performSegue(withIdentifier: "mainMenu", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create skview in front of self view controller
        if let view = self.view as! SKView? {
            if let scene = GameScene(fileNamed: "GameScene") {
                scene.gameViewControllerDelegate = self
                scene.scaleMode = .fill
                // Present the scene
                view.presentScene(scene)
            }
            view.ignoresSiblingOrder = true
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
