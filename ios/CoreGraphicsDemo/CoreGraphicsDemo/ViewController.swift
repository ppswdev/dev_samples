//
//  ViewController.swift
//  CoreGraphicsDemo
//
//  Created by xiaopin on 2022/5/11.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    var dataArray = ["圆弧绘制1"]

    lazy var tableView:UITableView = {
        let tbView = UITableView(frame: .zero, style: .plain)
        tbView.contentInsetAdjustmentBehavior = .never
        tbView.isScrollEnabled = false
        tbView.dataSource = self
        tbView.delegate = self
        return tbView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
            
        initSubviews()
    }
    
    func initSubviews(){
        tableView.snp.makeConstraints { m in
            m.top.left.bottom.right.equalToSuperview()
        }
        view.addSubview(tableView)
    }
}

extension ViewController:UITableViewDelegate,UITableViewDataSource{
    //MARK: 标准UITableView代理
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell1111")
        if cell == nil { cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell1111") }
        cell!.textLabel?.text = dataArray[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
}
