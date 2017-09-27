//
//  LearnModeCell.swift
//  HocLaiXe
//
//  Created by Admin on 7/26/16.
//  Copyright © 2016 Han Luong. All rights reserved.
//

import UIKit

class LearnModeCell: UICollectionViewCell {
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var status: UILabel!
    
    @IBOutlet weak var percentage: UILabel!
    
    @IBOutlet weak var processBar: KDCircularProgress!
    
    func poke() {
        
        let grow = CGAffineTransform(scaleX: 1.2, y: 1.2)
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = grow
            }, completion: nil)
        self.transform = CGAffineTransform.identity
    }
    
    func scaleUpSize() {
        self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
    }
    
    func restoreSize() {
        self.transform = CGAffineTransform.identity
    }
    
 }
