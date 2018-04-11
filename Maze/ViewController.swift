//
//  ViewController.swift
//  Maze
//
//  Created by 大林拓実 on 2018/04/12.
//  Copyright © 2018年 Life is tech. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    var playerView: UIView!     //プレーヤーを表す
    var playerMotionManager: CMMotionManager!   //iPhoneの動きを感知するMotionManager
    var speedX: Double = 0.0    //プレイヤーが動く速さ(x方向)
    var speedY: Double = 0.0    //プレイヤーが動く速さ(y方向)
    
    //画面サイズの取得
    let screenSize = UIScreen.main.bounds.size
        //screensizeにはデバイスの画面サイズの情報が入る->どんな画面サイズにも対応できるようにscreenSize基準で決めていく
    
    //迷路のマップを表す配列(0:通過可能,1:壁,2:スタート,3:ゴール)
    let maze = [
        [1, 0, 0, 0, 1, 0],
        [1, 0, 1, 0, 1, 0],
        [3, 0, 1, 0, 1, 0],
        [1, 1, 1, 0, 0, 0],
        [1, 0, 0, 1, 1, 0],
        [0, 0, 1, 0, 0, 0],
        [0, 1, 1, 0, 1, 0],
        [0, 0, 0, 0, 1, 1],
        [0, 1, 1, 0, 0, 0],
        [0, 0, 1, 1, 1, 2],
    ]
    
    //スタートとゴールを表すUIView
    var startView: UIView!
    var goalView: UIView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let cellWidth = screenSize.width / CGFloat(maze[0].count)
        let cellHeight = screenSize.height / CGFloat(maze.count)
        
        let cellOffsetX = screenSize.width / CGFloat(maze[0].count * 2)
        let cellOffsetY = screenSize.height / CGFloat(maze.count * 2)
        
        for y in 0 ..< maze.count{
            for x in 0 ..< maze[y].count{
                switch maze[y][x] {
                case 1: //壁
                    let wallview = createView(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOffsetY)
                    wallview.backgroundColor = UIColor.black
                    view.addSubview(wallview)
                
                case 2: //スタート
                    startView = createView(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOffsetY)
                    startView.backgroundColor = UIColor.green
                    view.addSubview(startView)
                    
                case 3: //ゴール
                    goalView = createView(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOffsetY)
                    goalView.backgroundColor = UIColor.red
                    view.addSubview(goalView)
                    
                default:
                    break
                }
            }
        }
        
        //playerViewを作成
        playerView = UIView(frame: CGRect(x: 0, y: 0, width: cellWidth / 6, height: cellHeight / 6)) //playerの幅と高さはマスの1/6
        playerView.center = startView.center    //スタート位置に合わせる
        playerView.backgroundColor = UIColor.gray
        self.view.addSubview(playerView)
        
        //MotionManagerを生成
        playerMotionManager = CMMotionManager()
        playerMotionManager.accelerometerUpdateInterval = 0.02  //0.02sごとに加速度の値を取得
        
        self.startAccelerometer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createView(x: Int, y: Int, width: CGFloat, height: CGFloat, offsetX: CGFloat, offsetY: CGFloat) -> UIView{
        
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        let view = UIView(frame: rect)
        
        let center = CGPoint(x:offsetX + width * CGFloat(x), y: offsetY + height * CGFloat(y))
        
        view.center = center
        
        return view
    }
    
    func startAccelerometer(){
        //加速度を取得する
        let handler: CMAccelerometerHandler = {(CMAccelerometerData:CMAccelerometerData?, error:Error?) -> Void in
            self.speedX += CMAccelerometerData!.acceleration.x
            self.speedY += CMAccelerometerData!.acceleration.y
            
            //プレイヤーの中心位置を設定
            var posX = self.playerView.center.x + (CGFloat(self.speedX) / 3)
            var posY = self.playerView.center.y - (CGFloat(self.speedY) / 3)
            
            //画面上からプレイヤーがはみ出しそうなら，posX,posYを修正
            if posX <= self.playerView.frame.width / 2 {
                self.speedX = 0
                posX = self.playerView.frame.width / 2
            }
            if posY <= self.playerView.frame.height / 2 {
                self.speedY = 0
                posY = self.playerView.frame.height / 2
            }
            if posX >= self.screenSize.width - (self.playerView.frame.width / 2){
                self.speedX = 0
                posX = self.screenSize.width - (self.playerView.frame.width / 2)
            }
            if posY >= self.screenSize.height - (self.playerView.frame.height / 2){
                self.speedY = 0
                posY = self.screenSize.height - (self.playerView.frame.height / 2)
            }
            
            self.playerView.center = CGPoint(x: posX, y: posY)
        }
        //加速度の開始
        playerMotionManager.startAccelerometerUpdates(to: OperationQueue.main, withHandler: handler)
    }

}
