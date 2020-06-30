//
//  GameScene.swift
//  FlappyBird
//
//  Created by 坂本充生 on 2020/06/28.
//  Copyright © 2020 michio. All rights reserved.
//

import UIKit
import SpriteKit

class GameScene: SKScene {
    
    var scrollNode:SKNode!
    
    //SKView上にシーンが表示された時に呼ばれるメソッド
    override func didMove(to view: SKView) {
        print("④ここまできた")
        //背景色設定
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.9, alpha: 1)
        //スクロールするスプレライトの親ノード
        scrollNode = SKNode()
        addChild(scrollNode)
        
        //地面の画像読み込み
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = .nearest
        
        //必要枚数計算
        print(self.frame.size.width / groundTexture.size().width)
        let needNumber = Int(self.frame.size.width / groundTexture.size().width) + 2
//        let needNumber = Int(self.frame.size.width / groundTexture.size().width) + 1
//        let needNumber = Int(self.frame.size.width / groundTexture.size().width)
        print("needNumber：\(needNumber)")
        //スクロールするアクションを作成
        //左方向に画像一枚分スクロールさせるアクション
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5)
//        let moveGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 5)
        
        //元の位置に戻すアクション
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
        //左にスクロール->元の位置->左にスクロールを無限に繰り返すアクション
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround,resetGround]))
//        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround]))
        
        //groundのスプライトを配置する
        for i in 0..<needNumber{
            let sprite = SKSpriteNode(texture: groundTexture)
            print("⑤ここまできた\(i)")
            //スプライトの表示位置設定
            sprite.position = CGPoint(
                x: groundTexture.size().width / 2 + groundTexture.size().width * CGFloat(i),
                y: groundTexture.size().height / 2
            )
            //スプライトにアクションを設置
            sprite.run(repeatScrollGround)
            //スプライトを追加
            scrollNode.addChild(sprite)

        }
//        let sprite = SKSpriteNode(texture: groundTexture)
//        //スプライトの表示位置設定
//        sprite.position = CGPoint(
//            x: groundTexture.size().width / 2 + groundTexture.size().width * CGFloat(1),
//            y: groundTexture.size().height / 2
//        )
//        //スプライトにアクションを設置
//        sprite.run(repeatScrollGround)
//        //スプライトを追加
//        scrollNode.addChild(sprite)
        
        
//        //テクスチャを指定してスプライト作成
//        let groundSprite = SKSpriteNode(texture: groundTexture)
//        //スプライトの表示する位置を指定
//        groundSprite.position = CGPoint(
//            x:groundTexture.size().width / 2,
//            y:groundTexture.size().height / 2
//        )
//        //シーンにスプライトを追加
//        addChild(groundSprite)
    }

}
