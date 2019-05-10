//
//  ViewController.swift
//  Zero_Refresh
//
//  Created by ZeroJian on 05/09/2019.
//  Copyright (c) 2019 ZeroJian. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton()
        button.setTitle("RefreshList", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.frame = CGRect(x: 30, y: 100, width: 120, height: 45)
        view.addSubview(button)
        
        button.addTarget(self, action: #selector(clicked), for: .touchUpInside)
    }
    
    @objc func clicked() {
        navigationController?.pushViewController(TestListViewController(), animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

