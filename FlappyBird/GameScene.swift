//
//  GameScene.swift
//  FlappyBird
//
//  Created by 坂本充生 on 2020/06/28.
//  Copyright © 2020 michio. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class GameScene: SKScene ,SKPhysicsContactDelegate{
    
    var scrollNode:SKNode!
    var wallNode:SKNode!
    var bird:SKSpriteNode!
    var item:SKNode!
    
    // 衝突判定カテゴリー
    let birdCategory: UInt32 = 1 << 0       // 0...00001
    let groundCategory: UInt32 = 1 << 1     // 0...00010
    let wallCategory: UInt32 = 1 << 2       // 0...00100
    let scoreCategory: UInt32 = 1 << 3      // 0...01000
    let itemNormalCategory: UInt32 = 1 << 4      // 0...10000
    let itemSpoiltCategory: UInt32 = 1 << 5      // 0...10000
    let itemPoisonCategory: UInt32 = 1 << 6      // 0...10000
    let itemSuperCategory: UInt32 = 1 << 7      // 0...10000
    // スコア用
    var score = 0
    var itemScore = 0      //アイテム用
    var scoreLabelNode:SKLabelNode!
    var bestScoreLabelNode:SKLabelNode!
    var itemScoreLabelNode:SKLabelNode!
    let userDefaults:UserDefaults = UserDefaults.standard
    //BGM再生
    var audioPlayer:AVAudioPlayer!
    var beepPlayer:AVAudioPlayer!
    let bgmpop = Bundle.main.bundleURL.appendingPathComponent("bgmpop.caf")
    let bgmNormal = Bundle.main.bundleURL.appendingPathComponent("normal.caf")
    let bgmSpoilt = Bundle.main.bundleURL.appendingPathComponent("spoilt.caf")
    let bgmPoison = Bundle.main.bundleURL.appendingPathComponent("poison.caf")
    let bgmSuper = Bundle.main.bundleURL.appendingPathComponent("super.caf")
    let bgmHit = Bundle.main.bundleURL.appendingPathComponent("Down.caf")
    
    //SKView上にシーンが表示された時に呼ばれるメソッド
    override func didMove(to view: SKView) {
        // 重力を設定
        physicsWorld.gravity = CGVector(dx: 0, dy: -4)
        physicsWorld.contactDelegate = self
        
        //背景色設定
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.9, alpha: 1)
        //スクロールするスプライトの親ノード
        scrollNode = SKNode()
        addChild(scrollNode)

        //壁用のノード
        wallNode = SKNode()
        scrollNode.addChild(wallNode)
                
        //各種スプライトを生成する処理のメソッド
        setupGround()
        setupCloud()
        setupWall()
        setupBird()
        setupScoreLabel()
        setupItem()
        
        //BGM再生
        do{
            try audioPlayer = AVAudioPlayer(contentsOf: bgmpop)

            audioPlayer.prepareToPlay()
            audioPlayer.numberOfLoops = -1
            audioPlayer.play()

        } catch{
            print("error")
        }
    }
    func setupScoreLabel() {
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        scoreLabelNode.zPosition = 100 // 一番手前に表示する
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text = "Score:\(score)"
        self.addChild(scoreLabelNode)

        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.black
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
        bestScoreLabelNode.zPosition = 100 // 一番手前に表示する
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left

        let bestScore = userDefaults.integer(forKey: "BEST")
        bestScoreLabelNode.text = "Best Score:\(bestScore)"
        self.addChild(bestScoreLabelNode)
        
        itemScore = 0
        itemScoreLabelNode = SKLabelNode()
        itemScoreLabelNode.fontColor = UIColor.black
        itemScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 120)
        itemScoreLabelNode.zPosition = 100 // 一番手前に表示する
        itemScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        itemScoreLabelNode.text = "Item Score:\(itemScore)"
        self.addChild(itemScoreLabelNode)
    }
    func restart() {
        score = 0
        scoreLabelNode.text = "Score:\(score)"
        itemScore = 0
        itemScoreLabelNode.text = "Item Score:\(itemScore)"
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation = 0

        wallNode.removeAllChildren()

        bird.speed = 1
        scrollNode.speed = 1
        
        //再生位置を最初から
        audioPlayer.currentTime = 0
        //音楽再生
        audioPlayer.play()
    }
    // SKPhysicsContactDelegateのメソッド。衝突したときに呼ばれる
    func didBegin(_ contact: SKPhysicsContact) {
        // ゲームオーバーのときは何もしない
        if scrollNode.speed <= 0 {
            return
        }

        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            // スコア用の物体と衝突した
            print("ScoreUp")
            score += 1
            scoreLabelNode.text = "Score:\(score)"
            // ベストスコア更新か確認する
            var bestScore = userDefaults.integer(forKey: "BEST")
            if score > bestScore {
                bestScore = score
                bestScoreLabelNode.text = "Best Score:\(bestScore)"
                userDefaults.set(bestScore, forKey: "BEST")
                userDefaults.synchronize()
            }
        //通常リンゴ
        }else if(contact.bodyA.categoryBitMask & itemNormalCategory) == itemNormalCategory || (contact.bodyB.categoryBitMask & itemNormalCategory) == itemNormalCategory {
            itemScore += 1
            itemScoreLabelNode.text = "Item Score:\(itemScore)"
            // ベストスコア更新か確認する
            var bestScore = userDefaults.integer(forKey: "BEST")
            if score > bestScore {
                bestScore = score
                bestScoreLabelNode.text = "Best Score:\(bestScore)"
                userDefaults.set(bestScore, forKey: "BEST")
                userDefaults.synchronize()
            }
            //音を鳴らす
            do {
                try beepPlayer = AVAudioPlayer(contentsOf: bgmNormal)
                beepPlayer.play()
            }catch{
                print("soundBeep:error")
            }
            
            //リンゴを消す
            contact.bodyA.node?.removeFromParent()
        //腐ったリンゴ
        }else if(contact.bodyA.categoryBitMask & itemSpoiltCategory) == itemSpoiltCategory || (contact.bodyB.categoryBitMask & itemSpoiltCategory) == itemSpoiltCategory {
            itemScore -= 1
            itemScoreLabelNode.text = "Item Score:\(itemScore)"
            
            //音を鳴らす
            do {
                try beepPlayer = AVAudioPlayer(contentsOf: bgmSpoilt)
                beepPlayer.play()
            }catch{
                print("soundBeep:error")
            }
            
            //リンゴを消す
            contact.bodyA.node?.removeFromParent()
        //毒リンゴ
        }else if(contact.bodyA.categoryBitMask & itemPoisonCategory) == itemPoisonCategory || (contact.bodyB.categoryBitMask & itemPoisonCategory) == itemPoisonCategory {
            itemScore -= 10
            itemScoreLabelNode.text = "Item Score:\(itemScore)"
            
            //音を鳴らす
            do {
                try beepPlayer = AVAudioPlayer(contentsOf: bgmPoison)
                beepPlayer.play()
            }catch{
                print("soundBeep:error")
            }
            
            //リンゴを消す
            contact.bodyA.node?.removeFromParent()
        //スーパーリンゴ
        }else if(contact.bodyA.categoryBitMask & itemSuperCategory) == itemSuperCategory || (contact.bodyB.categoryBitMask & itemSuperCategory) == itemSuperCategory {
            itemScore += 10
            itemScoreLabelNode.text = "Item Score:\(itemScore)"
            
            //音を鳴らす
            do {
                try beepPlayer = AVAudioPlayer(contentsOf: bgmSuper)
                beepPlayer.play()
            }catch{
                print("soundBeep:error")
            }
            
            //リンゴを消す
            contact.bodyA.node?.removeFromParent()
        } else {
            // 壁か地面と衝突した
            print("GameOver")

            // スクロールを停止させる
            scrollNode.speed = 0

            bird.physicsBody?.collisionBitMask = groundCategory

            let roll = SKAction.rotate(byAngle: CGFloat(Double.pi) * CGFloat(bird.position.y) * 0.01, duration:1)
            bird.run(roll, completion:{
                self.bird.speed = 0
            })
            //音を鳴らす
            do {
                try beepPlayer = AVAudioPlayer(contentsOf: bgmHit)
                beepPlayer.play()
            }catch{
                print("soundBeep:error")
            }
            //サウンド停止
            audioPlayer.stop()
        }
    }
    // 画面をタップした時に呼ばれる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if scrollNode.speed > 0 {
            // 鳥の速度をゼロにする
            bird.physicsBody?.velocity = CGVector.zero
            // 鳥に縦方向の力を与える
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
        } else if bird.speed == 0 {
            restart()
        }
    }
    
    func setupBird() {
        // 鳥の画像を2種類読み込む
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = .linear
        
        // 2種類のテクスチャを交互に変更するアニメーションを作成
        let texturesAnimation = SKAction.animate(with: [birdTextureA, birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(texturesAnimation)
        
        // スプライトを作成
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        // 物理演算を設定
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
        // 衝突した時に回転させない
        bird.physicsBody?.allowsRotation = false
        
        // 衝突のカテゴリー設定
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory
        
        // アニメーションを設定
        bird.run(flap)
        
        // スプライトを追加する
        addChild(bird)
    }
    func setupWall(){
        //壁の画像取り込み
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = .linear
        //移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width)
        //画面外まで移動するアクションを作成
        let moveWall = SKAction.moveBy(x: -movingDistance, y: 0, duration: 4)
        
        //自分を取り除くアクションを作成
        let removeWall = SKAction.removeFromParent()
        
        //２つのアニメーションを順に実行するアクションを作成
        let wallAnimation = SKAction.sequence([moveWall,removeWall])

        // 鳥の画像サイズを取得
        let birdSize = SKTexture(imageNamed: "bird_a").size()

        // 鳥が通り抜ける隙間の長さを鳥のサイズの3倍とする
        let slit_length = birdSize.height * 4

        // 隙間位置の上下の振れ幅を鳥のサイズの3倍とする
        let random_y_range = birdSize.height * 3

        // 下の壁のY軸下限位置(中央位置から下方向の最大振れ幅で下の壁を表示する位置)を計算
        let groundSize = SKTexture(imageNamed: "ground").size()
        let center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2
        let under_wall_lowest_y = center_y - slit_length / 2 - wallTexture.size().height / 2 - random_y_range / 2

        // 壁を生成するアクションを作成
        let createWallAnimation = SKAction.run({
            // 壁関連のノードを乗せるノードを作成
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width / 2, y: 0)
            wall.zPosition = -50 // 雲より手前、地面より奥

            // 0〜random_y_rangeまでのランダム値を生成
            let random_y = CGFloat.random(in: 0..<random_y_range)
            // Y軸の下限にランダムな値を足して、下の壁のY座標を決定
            let under_wall_y = under_wall_lowest_y + random_y

            // 下側の壁を作成
            let under = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x: 0, y: under_wall_y)
            
            // スプライトに物理演算を設定する
            under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            under.physicsBody?.categoryBitMask = self.wallCategory
            
            // 衝突の時に動かないように設定する
            under.physicsBody?.isDynamic = false
            
            wall.addChild(under)

            // 上側の壁を作成
            let upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x: 0, y: under_wall_y + wallTexture.size().height + slit_length)
            
            // スプライトに物理演算を設定する
            upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            upper.physicsBody?.categoryBitMask = self.wallCategory
            
            // 衝突の時に動かないように設定する
            upper.physicsBody?.isDynamic = false
            // スコアアップ用のノード --- ここから ---
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: upper.size.width + birdSize.width / 2, y: self.frame.height / 2)
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
            scoreNode.physicsBody?.isDynamic = false
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory

            wall.addChild(scoreNode)

            wall.addChild(upper)

            wall.run(wallAnimation)

            self.wallNode.addChild(wall)
        })

        // 次の壁作成までの時間待ちのアクションを作成
        let waitAnimation = SKAction.wait(forDuration: 2)

        // 壁を作成->時間待ち->壁を作成を無限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))

        wallNode.run(repeatForeverAnimation)
    }
    func setupItem(){
        //壁の画像取り込み
        var itemTexture = SKTexture(imageNamed: "normal")
        itemTexture.filteringMode = .linear
        //移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + itemTexture.size().width)
        //画面外まで移動するアクションを作成
        let moveItem = SKAction.moveBy(x: -movingDistance, y: 0, duration: 4)
        
        //自分を取り除くアクションを作成
        let removeItem = SKAction.removeFromParent()
        
        //２つのアニメーションを順に実行するアクションを作成
        let itemAnimation = SKAction.sequence([moveItem,removeItem])

        // 壁を生成するアクションを作成
        let createWallAnimation = SKAction.run({
            // 壁関連のノードを乗せるノードを作成

            let itemNode = SKNode()
            itemNode.position = CGPoint(x: self.frame.size.width + itemTexture.size().width / 2, y: 0)
            itemNode.zPosition = -75 // 雲より手前、地面より奥,壁より奥
            
            //itemの種類を作成
            let itemValue = Int.random(in: 0...9)
            switch itemValue {
            case 0..<6:
                itemTexture = SKTexture(imageNamed: "normal")
            case 6,7:
                itemTexture = SKTexture(imageNamed: "spoilt")
            case 8:
                itemTexture = SKTexture(imageNamed: "poison")
            case 9:
                itemTexture = SKTexture(imageNamed: "super")
            default:
                itemTexture = SKTexture(imageNamed: "normal")
            }
            
            //アイテムを作成
            let item = SKSpriteNode(texture: itemTexture)
            
            //アイテムの出現位置を算出
            let groundSize = SKTexture(imageNamed: "ground").size() //地面のサイズを取得
            let itemMinY = Int(groundSize.height+self.frame.size.height*0.1)       //最低高さは地面高さ+画面高さ1割から
            let itemMaxY = Int(self.frame.size.height*0.8)  //最大高さは画面高さの８割まで
            let itemPositionY = Int.random(in: itemMinY...itemMaxY)
            
            
            item.position = CGPoint(x: 0, y: itemPositionY)
            
            // スプライトに物理演算を設定する
            item.physicsBody = SKPhysicsBody(rectangleOf: itemTexture.size())
            
            item.physicsBody?.contactTestBitMask = self.birdCategory
            switch itemValue {
            case 0..<6:
                item.physicsBody?.categoryBitMask = self.itemNormalCategory
            case 6,7:
                item.physicsBody?.categoryBitMask = self.itemSpoiltCategory
            case 8:
                item.physicsBody?.categoryBitMask = self.itemPoisonCategory
            case 9:
                item.physicsBody?.categoryBitMask = self.itemSuperCategory
            default:
                item.physicsBody?.categoryBitMask = self.itemNormalCategory
            }
            
            // 衝突の時に動かないように設定する
            item.physicsBody?.isDynamic = false
            
            itemNode.addChild(item)
            
            itemNode.run(itemAnimation)
            self.wallNode.addChild(itemNode)
        })

        // 次の壁作成までの時間待ちのアクションを作成
        let waitAnimation = SKAction.wait(forDuration: 3, withRange: 4)
        // 壁を作成->時間待ち->壁を作成を無限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))

        wallNode.run(repeatForeverAnimation)
    }
    
    func setupGround(){
        //地面の画像取り込み
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
            
            // スプライトに物理演算を設定する
            sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())
            // 衝突のカテゴリー設定
            sprite.physicsBody?.categoryBitMask = groundCategory
            
            // 衝突の時に動かないように設定する
            sprite.physicsBody?.isDynamic = false
            //スプライトを追加
            scrollNode.addChild(sprite)
        }
    }
    func setupCloud(){
        //雲の画像取り込み
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = .nearest
        
        //必要枚数計算
        print(self.frame.size.width / cloudTexture.size().width)
        let needNumber = Int(self.frame.size.width / cloudTexture.size().width) + 2
//        let needNumber = Int(self.frame.size.width / groundTexture.size().width) + 1
//        let needNumber = Int(self.frame.size.width / groundTexture.size().width)
        print("needNumber：\(needNumber)")
        //スクロールするアクションを作成
        //左方向に画像一枚分スクロールさせるアクション
        let moveGround = SKAction.moveBy(x: -cloudTexture.size().width, y: 0, duration: 5)
//        let moveGround = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 5)
        
        //元の位置に戻すアクション
        let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0)
        //左にスクロール->元の位置->左にスクロールを無限に繰り返すアクション
        let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveGround,resetCloud]))
//        let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveGround]))
        
        //groundのスプライトを配置する
        for i in 0..<needNumber{
            let sprite = SKSpriteNode(texture: cloudTexture)
            sprite.zPosition = -100
            //スプライトの表示位置設定
            sprite.position = CGPoint(
                x: cloudTexture.size().width / 2 + cloudTexture.size().width * CGFloat(i),
                y: self.size.height - cloudTexture.size().height / 2
            )
            //スプライトにアクションを設置
            sprite.run(repeatScrollCloud)
            //スプライトを追加
            scrollNode.addChild(sprite)
        }
    }
}
