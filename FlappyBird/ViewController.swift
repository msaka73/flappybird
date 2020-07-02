//
//  ViewController.swift
//  FlappyBird
//
//  Created by 坂本充生 on 2020/06/26.
//  Copyright © 2020 michio. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("①ここまできた")
        //SKViewに型を変換する
        let skView = self.view as! SKView
        //FPSを表示する
        skView.showsFPS = true
        //ノードの数を表示
        skView.showsNodeCount = true
        print("②ここまできた")
        //ビューと同じサイズでシーンを作成
        let scene = GameScene(size: skView.frame.size)
        //ビューにシーンを表示
        skView.presentScene(scene)
        print("③ここまできた")
        
    }
    //ステータスバーの非表示（時間,バッテリ量など)
    override var prefersStatusBarHidden: Bool{
        get{
            return true
        }
    }
}

