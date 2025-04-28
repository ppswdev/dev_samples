//
//  ViewController.swift
//  AirPlay
//
//  Created by xiaopin on 2021/12/1.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.playback, mode: .default, policy: .longFormVideo, options: .allowAirPlay)
        
        //AVRoutePickerView, AVRouteDetecotor
    }


}

