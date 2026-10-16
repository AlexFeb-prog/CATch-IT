//
//  GameScene.swift
//  CATchIT
//
//  Created by un negro on 16/10/2026.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchLocation = touches.first!.location(in: self)
        let node = self.atPoint(touchLocation)
        switch node.name {
            case "SKPlay":
            return
            
            case "SKProfile":
            return
            
            case "SKoption":
            return
            
            case "SKhome":
            return
            
            default:
            return
        }
    }
    
}
