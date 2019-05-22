//
//  MemeDetailViewController.swift
//  Mememev2
//
//  Created by Nishtha Behal on 22/05/19.
//  Copyright © 2019 Nishtha Behal. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {

    var image: UIImage!
    @IBOutlet weak var memeImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        memeImageView.image = image
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
}
