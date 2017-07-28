//
//  CYJSubjectCell.swift
//  Q&A
//
//  Created by kyang on 2017/7/25.
//  Copyright © 2017年 kyang. All rights reserved.
//

import UIKit

class QASubjectCell: UITableViewCell {

    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let img = #imageLiteral(resourceName: "title")
        backgroundImageView.image = img.resizableImage(withCapInsets: UIEdgeInsetsMake(img.size.height * 0.5, img.size.width * 0.5, img.size.height * 0.5, img.size.width * 0.5 + 1), resizingMode: .tile)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
