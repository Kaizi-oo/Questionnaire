//
//  QABaseQuestionController.swift
//  Questionnaire
//
//  Created by kyang on 2017/8/1.
//  Copyright © 2017年 kyang. All rights reserved.
//

import Foundation
import UIKit

class QABaseQuestionController: UIViewController {
    /// 模仿一个生命周期，因为没找到直接获取当前生命周期的方法
    enum Life {
        case didLoad
        case willAppear
        case didAppear
        case willDisappear
        case didDisappear
    }
    var lifeCircle: Life = .didLoad //初始就默认为didLoad了，不要在意这些细节
    var reuseIdentifier: String!
    
    init(frame: CGRect, reuseIdentifier: String) {
        super.init(nibName: nil, bundle: nil)
        
        view.frame = frame
        self.reuseIdentifier = reuseIdentifier
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.lifeCircle = .willAppear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.lifeCircle = .didAppear
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.lifeCircle = .willDisappear
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.lifeCircle = .didDisappear
    }
}
    
