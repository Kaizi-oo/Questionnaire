//
//  textViewTableViewCell.swift
//  Q&A
//
//  Created by kyang on 2017/7/14.
//  Copyright © 2017年 kyang. All rights reserved.
//

import UIKit

class QATextViewCell: UITableViewCell {

    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    var realAnswer: RealAnswer?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textView.delegate = self
        textView.layer.cornerRadius = 5
        textView.layer.masksToBounds = true
        
        let img = #imageLiteral(resourceName: "rectangle-y")
        backgroundImageView.image = img.resizableImage(withCapInsets: UIEdgeInsetsMake(img.size.height * 0.5, img.size.width * 0.5, img.size.height * 0.5, img.size.width * 0.5 + 1), resizingMode: .tile)
        }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension QATextViewCell: UITextViewDelegate
{
    func textViewDidChange(_ textView: UITextView) {
            placeholderLabel.isHidden = textView.text.characters.count > 0
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        //编辑完成
        realAnswer?.answer = textView.text
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "answerChanged"), object: realAnswer)

    }
}
