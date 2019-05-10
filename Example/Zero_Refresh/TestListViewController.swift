//
//  TestListViewController.swift
//  Zero_Refresh_Example
//
//  Created by ZeroJian on 2019/5/10.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Zero_Refresh

struct Person {
    var name: String = ""
    var age: Int = 18
}

class TestListViewController: UIViewController {
    
    let cellIdentifier = "TestListCellIdentifier"
    
    let tableView = UITableView()
    
    lazy var refresh: Refresh<Person> = {
        let r = Refresh<Person>.init(refreshView: self.tableView)
        return r
    }()
    
    var serverData: [Person] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        tableView.frame = view.bounds
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        let barButton = UIBarButtonItem(title: "Refresh", style: .done, target: self, action: #selector(refreshBarButtonAction))
        navigationItem.rightBarButtonItem = barButton
        
        
        
        // init server data
        for i in  0..<46 {
            let p = Person(name: "Zero \(i + 100)", age: i + 1)
            serverData.append(p)
        }

        
        requestDataSource()
    }
    
    func requestDataSource() {
                
        refresh.requestHandle { [weak self](pageIndex, result) in
            
            print("\n ------ Current Page: \(pageIndex) ")
            
            let (success, failure) =  result
            
            self?.request(isSuccessful: true, page: pageIndex, successful: { (totalCount, data) in
                success?(totalCount, data)
                
            }, failured: { (message) in
                failure?(message)
            })
        }
        
        refresh.makeEmptyView(lableText: "暂时没有数据哦~~", imageName: "empty-datasource")
//        let button = UIButton()
//        button.backgroundColor = .blue
//        button.setTitleColor(.white, for: .normal)
//        button.setTitle("重试请求", for: .normal)
//        refresh.makeEmptyButton(button: button)
        
//        refresh.showFirstSpinnerView(inView: view)
        
        refresh.configRefresh(beginPage: 1, pageSize: 20)
        
        refresh.beginRefresh()
    }
    
    
    func request(isSuccessful: Bool, page: Int, successful: @escaping((Int, [Person]) -> Void), failured: @escaping (String) -> Void) {
        let after = DispatchTime.now() + 2
        DispatchQueue.global().asyncAfter(deadline: after) {
            DispatchQueue.main.async {
                if isSuccessful {
                    let result = self.getSeverData(page: page, pageSize: 20)
                    successful(result.totalCount, result.data)
                    
                } else {
                    failured("Request fail...")
                }
            }
        }
    }
    
    /// 模拟获取服务器数据
    /// return 总行数 和 当前 page 返回的数据
    func getSeverData(page: Int, pageSize: Int) -> (totalCount: Int, data: [Person]) {
        
        if serverData.isEmpty {
            return (0, [])
        }
        
        /// 假设服务器第一页 page = 1
        let first = (page - 1) * pageSize
        var last: Int
        if first + pageSize > serverData.count {
            last = (serverData.count - first) + first
        } else {
            last = first + pageSize
        }
        
        let sliceData = serverData[first..<last]
        let data = Array(sliceData)
        return (serverData.count, data)
    }
    
    @objc func refreshBarButtonAction() {
        refresh.beginRefresh()
    }

}

extension TestListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return refresh.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        let item = refresh.dataSource[indexPath.row]
        cell.textLabel?.text = "Name: \(item.name),  age: \(item.age)"
        return cell
    }
}
