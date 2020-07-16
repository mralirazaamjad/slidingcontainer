//
//  ViewController.swift
//  AesEncryption
//
//  Created by Ali Raza Amjad on 14/07/2020.
//  Copyright © 2020 Ali Raza Amjad. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func action(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        guard let vc = storyBoard.instantiateViewController(identifier: "SecondViewController") as? SecondViewController else { return }
        let container = SlidingContainer()
        container.embed(vc)
        
        self.showSlidingContainer(container)
    }
    
    func showSlidingContainer(_ container: SlidingContainerProtocol) {
        guard let container = container as? UIViewController else { return }
        container.modalPresentationStyle = .overFullScreen
        container.modalTransitionStyle = .crossDissolve
        self.present(container, animated: false)
    }
}

