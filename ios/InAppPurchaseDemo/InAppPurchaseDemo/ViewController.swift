//
//  ViewController.swift
//  InAppPurchaseDemo
//
//  Created by xiaopin on 2024/3/31.
//

import UIKit
import StoreKit

class ViewController: UIViewController,SKProductsRequestDelegate {

    private var dataArray = [SKProduct]()
    private let tableView:UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "Cells")
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        <#code#>
    }

}

extension ViewController:UITableViewDelegate,UITableViewDataSource{
    //MARK: 标准UITableView代理
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //XIB自动布局方式
        //let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MTMatchFightProCell
        //cell.selectionStyle = .none
        //let model = dataArray[indexPath.row]
        //cell.setCellValuesWithObj(model)
        
        //return cell
        
        //纯代码自动布局方式：
        //let cell = MTTeamScheduleCell.cell(tableView: tableView)
        //let model = dataArray[indexPath.section].list[indexPath.row]
        //cell.configureData(model: model)
        //return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //guard let model = dataArray[indexPath.section].list[indexPath.row] as? MTMatchFightModel else{return}
        //let detailVC = MTMatchDetailViewController()
        //detailVC.matchID = model.id ?? 0
        //push(detailVC)
    }
    
    //MARK: 追加HeaderFooterView
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = <#HeaderView#>.headerFooter(tableView: tableView)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
}
