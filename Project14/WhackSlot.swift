
import SpriteKit
import UIKit

class WhackSlot: SKNode {
    var charNode: SKSpriteNode! // character = cat or dog
    
    var isVisible = false
    var isHit = false
    var cropNodeShift = 23
    var charNodeShift = 0
    
    func configure(at position: CGPoint){
        self.position = position
        
        let sprite = SKSpriteNode(imageNamed: "WAMHole3") // hole image
        sprite.centerRect = CGRect(x: 5, y: 10, width: 0.4, height: 0)
        sprite.xScale = 0.12
        sprite.yScale = 0.16
        addChild(sprite)
        
        let cropNode = SKCropNode() // cropNode hides characters, characters go behind invisable wall
        cropNode.position = CGPoint(x: 0+cropNodeShift, y:15)
        cropNode.zPosition = 1
        cropNode.maskNode = SKSpriteNode(imageNamed: "whackMask")
        
        charNode = SKSpriteNode(imageNamed: "WAMCat3")
        charNode.position = CGPoint(x: 0+charNodeShift, y: -90+20)
        charNode.xScale = 0.3
        charNode.yScale = 0.3
        charNode.name = "character"
        cropNode.addChild(charNode)
        
        addChild(cropNode)
    }
    func show(hideTime: Double){ // hideTime = how long animal will hide
        if isVisible { return }
        
        charNode.xScale = 0.32
        charNode.yScale = 0.26
        
        // if animal isn't visible, move it into view:
        charNode.run(SKAction.moveBy(x: 0, y: 80, duration: 0.05)) // how animal comes out of hole
        isVisible = true
        isHit = false
        
        if Int.random(in: 0...2) == 0 { // how often characters show/hide
            charNode.texture = SKTexture(imageNamed: "WAMDog3")
            charNode.name = "charFriend"
        } else {
            charNode.texture = SKTexture(imageNamed: "WAMCat3")
            charNode.name = "charEnemy"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (hideTime * 3.5)){ [weak self] in self?.hide()} // animal hides itself after certain time has elapsed
    }
    
    func hide(){
        if !isVisible { return } // only hide if currently showing
        
        charNode.run(SKAction.moveBy(x: 0, y:-80, duration:0.05))
        isVisible = false
    }
    
    func hit(){
        isHit = true
        
        let delay = SKAction.wait(forDuration: 0.25)
        let hide = SKAction.moveBy(x: 0, y: -80, duration: 0.5) // moves down slowly after hit
        let notVisible = SKAction.run { [weak self] in self?.isVisible = false }
        let sequence = SKAction.sequence([delay, hide, notVisible])
        charNode.run(sequence) // runs delay, hide, and notVisible in order every hit
    }
}
