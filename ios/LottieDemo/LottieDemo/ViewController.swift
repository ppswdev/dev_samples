//
//  ViewController.swift
//  LottieDemo
//
//  Created by xiaopin on 2024/4/12.
//

import UIKit
import Lottie
import SwiftUI

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 创建 AnimationView 实例
        let animationView = LottieAnimationView(name: "Animation - 1712919797395")

        // 注意：JSON 文件名不包括 .json 扩展名

        // 设置动画视图的 frame 或使用 Auto Layout 添加约束
        animationView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)

        // 加载动画
        animationView.animation = LottieAnimation.named("Animation - 1712919797395")

        animationView.loopMode = .loop
        
        // 开始播放动画
        animationView.play()

        // 将动画视图添加到父视图
        view.addSubview(animationView)
    }


}

