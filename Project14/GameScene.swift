

import SpriteKit
import UIKit

// Rulebook for making the rulebook. Like interface saying VC need to make checkButton
protocol GameViewControllerDelegate: AnyObject {
    func checkButton()
}

// Highscore function
let kScore = "kScore"
let kHighscore = "kHighscore"

func setScore(_ value: Int){
    if value > getHighscore(){
        setHighscore(value)
    }
    
    UserDefaults.standard.set(value, forKey: kScore)
    UserDefaults.standard.synchronize()
}

func getScore() -> Int {
    return UserDefaults.standard.integer(forKey: kScore)
}

func setHighscore(_ value: Int){
    UserDefaults.standard.set(value, forKey: kHighscore)
    UserDefaults.standard.synchronize()
}

func getHighscore() -> Int {
    return UserDefaults.standard.integer(forKey: kHighscore)
}

// GameScene
class GameScene: SKScene {
    var slots = [WhackSlot]() // array of all the "cells" or slots where holes/moles will appear
    let gameScore = SKLabelNode(fontNamed: "ArialMT") // font of score
    let highscore = SKLabelNode(fontNamed: "ArialMT")
    var moveGameOverScreenUp = 100

    let pauseButton = SKSpriteNode(imageNamed: "PauseButton4")
    var gamePaused = false
    
    var gameViewControllerDelegate: GameViewControllerDelegate?
    var background = SKSpriteNode(imageNamed: "WhackBlueWallPaperLarge") // makes background the blue wallpaper
    
    var resumeButton: SKSpriteNode!
    var MainMenuButton: SKSpriteNode!
    var MainMenuButtonNoRedText: SKSpriteNode!
    
    var xscale = 0.13
    var yscale = 0.1
    var holeSeperation = 95

    var popupTime = 0.85 // a bit faster than once a second
    var numRounds = 0 // increases everytime createEnemy() called, game ends at round 30
    
    var score = 0 { // player's internal score
        didSet {
            gameScore.text = "Score: \(score)"
            setScore(score)
        }
    }
    
    override func didMove(to view: SKView) {
        background.position = CGPoint(x: 568, y: 350) 
        background.blendMode = .replace // draws whole bakckground over whatever was there before
        background.zPosition = -1 // places background behind other stuff (buttons, animations, etc)
        addChild(background)
        
        pauseButton.position = CGPoint(x: 360, y: 690)
        pauseButton.zPosition = 10
        pauseButton.xScale = xscale*1.5
        pauseButton.yScale = yscale*1.5
        addChild(pauseButton)
        
        gameScore.text = "Score: 0" // default score
        gameScore.xScale = xscale*10
        gameScore.yScale = yscale*10
        gameScore.position = CGPoint(x: 15, y: 675) 
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 35;
        addChild(gameScore)
        
        highscore.text = "Highscore: \(getHighscore())"
        highscore.position = CGPoint(x: 17, y: 650)
        highscore.xScale = xscale*10
        highscore.yScale = yscale*10
        highscore.horizontalAlignmentMode = .left
        highscore.fontSize = 15;
        addChild(highscore)
        
        
        //  Creating slots in each row, high y makes nodes towards top of screen, 25 slots total
        for i in 0..<4 { createSlot(at: CGPoint(x: 40 + (i * holeSeperation), y: 570)) }
        for i in 0..<4 { createSlot(at: CGPoint(x: 40 + (i * holeSeperation), y: 455)) }
        for i in 0..<4 { createSlot(at: CGPoint(x: 40 + (i * holeSeperation), y: 340)) }
        for i in 0..<4 { createSlot(at: CGPoint(x: 40 + (i * holeSeperation), y: 225)) }
        for i in 0..<4 { createSlot(at: CGPoint(x: 40 + (i * holeSeperation), y: 100)) }
        
        // Wait 1 second after game starts before making new enemy
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){ [weak self] in self?.createEnemy()}
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let tappedNodes = nodes(at: location)
            
            for node in tappedNodes {
                if node.name == "charFriend" { // charFriend = dog
                    let whackSlot = node.parent!.parent as! WhackSlot
                    if !whackSlot.isVisible { continue }
                    if whackSlot.isHit { continue }
                    
                    whackSlot.hit()
                    score -= 1
                    
                    run(SKAction.playSoundFileNamed("DogBarkWAV.wav", waitForCompletion:false))
                    
                    
                } else if node.name == "charEnemy" { // charEnemy = cat
                    let whackSlot = node.parent!.parent as! WhackSlot
                    if !whackSlot.isVisible { continue }
                    if whackSlot.isHit { continue }
                    
                    whackSlot.hit()
                    score += 1
                    run(SKAction.playSoundFileNamed("CatMeowWAV.wav", waitForCompletion:false))
                    
                } else if node == pauseButton{
                    gamePaused = true
                    
                    pauseButton.zPosition = -10
                    
                    background.blendMode = .replace
                    background.position = CGPoint(x: 400, y: 400) 
                    background.zPosition = 1
                    
                    resumeButton = SKSpriteNode(imageNamed: "ResumeGame6")
                    resumeButton.position = CGPoint(x: 200, y: 580)
                    resumeButton.zPosition = 2
                    resumeButton.xScale = 0.42
                    resumeButton.yScale = 0.36
                    addChild(resumeButton)
                    
                    MainMenuButton = SKSpriteNode(imageNamed: "MainMenuButton4") // makes background the blue wallpaper
                    MainMenuButton.position = CGPoint(x: 200, y: 450) 
                    MainMenuButton.zPosition = 2 // places background behind other stuff (buttons, animations, etc)
                    MainMenuButton.xScale = 0.42
                    MainMenuButton.yScale = 0.36
                    addChild(MainMenuButton)
                    
                } else if node == resumeButton{
                    resumeButton.zPosition = -10
                    MainMenuButton.zPosition = -200
                    MainMenuButton.removeFromParent()
                    background.zPosition = -1
                    pauseButton.zPosition = 2
                    gamePaused = false
                } else if node == MainMenuButton || node == MainMenuButtonNoRedText{
                    gameViewControllerDelegate?.checkButton()
                }
            }
        }
    }
    
    func createSlot(at position: CGPoint) { // Makes new slot for hole
        let slot = WhackSlot()
        slot.configure(at: position)
        addChild(slot)
        slots.append(slot)
    }
    
    func createEnemy(){
        if numRounds >= 30 { // numRounds = how long a single game is
            for slot in slots {
                slot.hide()
            }
            background.zPosition = 3
            pauseButton.zPosition = -20
            gameScore.zPosition = 4
            gameScore.position = CGPoint(x: 115, y: 265+moveGameOverScreenUp)
            
            let gameOver = SKSpriteNode(imageNamed: "gameOver")
            gameOver.position = CGPoint(x: 210, y: 354+moveGameOverScreenUp) 
            gameOver.zPosition = 4
            gameOver.xScale = 0.75
            gameOver.yScale = 0.75
            addChild(gameOver)
            
            MainMenuButtonNoRedText = SKSpriteNode(imageNamed: "MainMenuButtonNoRedText")
            MainMenuButtonNoRedText.position = CGPoint(x: 200, y: 150+moveGameOverScreenUp)
            MainMenuButtonNoRedText.zPosition = 4
            MainMenuButtonNoRedText.xScale = 0.42
            MainMenuButtonNoRedText.yScale = 0.36
            addChild(MainMenuButtonNoRedText)
            return // return stops calling createEnemy now
        }
        
        let minDelay = popupTime / 2.0
        let maxDelay = popupTime * 2
        let delay = Double.random(in: minDelay...maxDelay)
        
        if gamePaused == false{
            numRounds += 1
            
            popupTime = 0.991 // every 0.991 seconds create an enemy, and slowly decreases popupTime over time
            
            slots.shuffle() // changes order of whackSlot array
            slots[0].show(hideTime: popupTime) // picks first random slot to show in array
            
           // multiple slots could show simutainously
            if Int.random(in: 0...12) > 4 { slots[1].show(hideTime: popupTime)}
            if Int.random(in: 0...12) > 8 { slots[2].show(hideTime: popupTime)}
            if Int.random(in: 0...12) > 10 { slots[3].show(hideTime: popupTime)}
            if Int.random(in: 0...12) > 11 { slots[4].show(hideTime: popupTime)}
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay){ [weak self] in self?.createEnemy()}
    }
}
