//
//  QuestionModel.swift
//  Q&A
//
//  Created by kyang on 2017/7/17.
//  Copyright © 2017年 kyang. All rights reserved.
//

import Foundation

class QAQuestion: NSObject {
    var questionId: Int = 0
    var question: String = "未知异常"
    var mode: Int = 1  // 1, 单选 2，多选， 3 简答
    var answers: [Answer] = []
    var required: Int = 0 // 0 不必须， 1 必须
    
    init(_ dictionary: [String: Any]) {
        super.init()
        self.setValuesForKeys(dictionary)
    }
    override func setValue(_ value: Any?, forKey key: String) {
        if key == "answers" {
            guard let answers = value as? [[String: Any]] else
            {
                print("失败鸟")
                return
            }
            answers.forEach({ (dict) in
                let answer = Answer(dict)
                self.answers.append(answer)
            })
            
        }else
        {
            super.setValue(value, forKey: key)
        }
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        //
    }
    
}

class Answer: NSObject {
    var answerId: Int = 0
    var desc: String = "未知描述"
    
    init(_ dictionary: [String: Any]) {
        super.init()
        self.setValuesForKeys(dictionary)
    }

    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        //
    }
}

class RealAnswer: NSObject {
    
    var questionId: Int = 0
    var questionMode: Int = 0
    var answer: String = "" // 用 | 隔开
    var required: Int = 0
    
    init(_ question: QAQuestion) {
        super.init()
        questionId = question.questionId
        questionMode = question.mode
        required = question.required
    }
    
    
}

