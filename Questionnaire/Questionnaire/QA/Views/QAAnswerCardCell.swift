//
//  AnswerCardCell.swift
//  Q&A
//
//  Created by kyang on 2017/7/24.
//  Copyright © 2017年 kyang. All rights reserved.
//

import UIKit

class QAAnswerCardCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    var isAnswered: Bool = false {
        didSet{
            titleLabel.layer.cornerRadius = frame.width * 0.5
            titleLabel.layer.masksToBounds = true
            if isAnswered {
                //选中
                titleLabel.backgroundColor = Q_A.Color.yellow
            }else
            {
                titleLabel.backgroundColor = Q_A.Color.gray
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        titleLabel.textColor = Q_A.Color.text

    }

}
