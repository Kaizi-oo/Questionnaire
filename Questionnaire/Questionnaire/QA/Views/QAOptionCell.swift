//
//  CYJOptionCell.swift
//  Q&A
//
//  Created by kyang on 2017/7/25.
//  Copyright © 2017年 kyang. All rights reserved.
//

import UIKit

class QAOptionCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    var indexPath: IndexPath? {
        didSet{
            iconImageView.image = UIImage(named: String(format: "%c", 97 + (indexPath?.row)!))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundView = UIView()
        selectedBackgroundView = UIView()

        let img = #imageLiteral(resourceName: "rectangle-y")
        backgroundImageView.image = img.resizableImage(withCapInsets: UIEdgeInsetsMake(img.size.height * 0.5, img.size.width * 0.5, img.size.height * 0.5, img.size.width * 0.5 + 1), resizingMode: .tile)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        let img = selected ? #imageLiteral(resourceName: "rectangle-g") : #imageLiteral(resourceName: "rectangle-y")
        backgroundImageView.image = img.resizableImage(withCapInsets: UIEdgeInsetsMake(img.size.height * 0.5, img.size.width * 0.5, img.size.height * 0.5, img.size.width * 0.5 + 1), resizingMode: .tile)
    }
    
}
