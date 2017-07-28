//
//  QuestionViewController.swift
//  Q&A
//
//  Created by kyang on 2017/7/17.
//  Copyright © 2017年 kyang. All rights reserved.
//

import Foundation

import UIKit

class QAQuestionViewController: UIViewController {
    
    
    lazy var tableView: UITableView = {

        let tb = UITableView(frame: CGRect(x: 5, y: 1, width: self.view.frame.width - 10, height: self.view.frame.height - 2), style: .grouped)
        tb.estimatedRowHeight = 44
        tb.rowHeight = UITableViewAutomaticDimension
        tb.delegate = self
        tb.dataSource = self
        tb.separatorStyle = .none
        //注册不同类型问题的不同cell
        tb.register(UINib(nibName: "QAOptionCell", bundle: nil), forCellReuseIdentifier: "QAOptionCell")
        tb.register(UINib(nibName: "QASubjectCell", bundle: nil), forCellReuseIdentifier: "QASubjectCell")
        tb.register(UINib(nibName: "QATextViewCell", bundle: nil), forCellReuseIdentifier: "QATextViewCell")
        tb.backgroundColor = UIColor.white
        return tb
    }()
    
    var dataSource: (QAQuestion, RealAnswer?)? {
        didSet{
            guard let data = dataSource else {
                return
            }
            question = data.0
            switch (question?.mode)! {
            case 0:
                tableView.allowsSelection = true
                tableView.allowsMultipleSelection = false
            case 1:
                tableView.allowsMultipleSelection = true
                
            case 2:
                tableView.allowsSelection = false
                tableView.allowsMultipleSelection = false
            default:
                break
            }
            realAnswer = data.1
            view.addSubview(tableView)
            tableView.reloadData()
            
        }
    }
    var question: QAQuestion?
    
    var realAnswer: RealAnswer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        
    }
}

extension QAQuestionViewController: UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return question?.answers.count ?? 0
        case 2:
            return question?.mode == 2 ? 1 : 0
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "QASubjectCell") as! QASubjectCell
            let starAttr = NSAttributedString(string: "*", attributes: [NSForegroundColorAttributeName: Q_A.Color.red , NSFontAttributeName: UIFont.systemFont(ofSize: 18)])
            let subjectAttr = NSAttributedString(string: "\(question?.question ?? "未知异常")", attributes: [NSForegroundColorAttributeName: Q_A.Color.drakText , NSFontAttributeName: Q_A.Font.senty(size: 16)])
            
            let attributes = [NSForegroundColorAttributeName: Q_A.Color.white , NSFontAttributeName: UIFont.systemFont(ofSize: 16)]
            var modeAttr:NSAttributedString
            switch (question?.mode)! {
            case 0:
                modeAttr = NSAttributedString(string: " [单选]", attributes: attributes)
            case 1:
                modeAttr = NSAttributedString(string: " [多选]", attributes: attributes)
            case 2:
                modeAttr = NSAttributedString(string: " [简答]", attributes: attributes)
            default:
                modeAttr = NSAttributedString(string: " [其他]", attributes: attributes)
            }
            let hole = NSMutableAttributedString()
            
            if question?.required == 1 {
                hole.append(starAttr)
            }
            
            hole.append(subjectAttr)
            hole.append(modeAttr)
            
            cell.subjectLabel.attributedText = hole
//                = "\(question?.question ?? "adasdas")    -    " + "\(question?.questionId ?? 0)"
            cell.selectionStyle = .none
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "QAOptionCell")! as! QAOptionCell
            let answer = question?.answers[indexPath.row]
            cell.indexPath = indexPath
            cell.descLabel.text = answer?.desc ?? "异常" + "\(question?.questionId ?? 0)"
            
            if !(realAnswer?.answer.isEmpty)! {
                switch (question?.mode)! {
                case 0:
                    //单选
                    if Int((realAnswer?.answer)!)! == answer?.answerId {
                        DispatchQueue.main.async {
                            //如果是正确答案，那么设置选中
                            self.tableView.selectRow(at: IndexPath(row: indexPath.row, section: 1), animated: false, scrollPosition: UITableViewScrollPosition.none)
                        }
                    }
                case 1:
                    //多选
                    let bool = realAnswer?.answer.contains("|\(answer?.answerId ?? 0)|")
                    if bool! {
                        DispatchQueue.main.async {
                            //如果是正确答案，那么设置选中
                            self.tableView.selectRow(at: IndexPath(row: indexPath.row, section: 1), animated: false, scrollPosition: UITableViewScrollPosition.none)
                        }
                    }
                default:
                    break
                }
            }
            
            
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "QATextViewCell")! as! QATextViewCell
            cell.selectionStyle = .none
            cell.textView.text = "请输入回答"
            if let _ = realAnswer
            {
                cell.realAnswer = realAnswer
                cell.textView.text = realAnswer?.answer
            }
            
            return cell
        default:
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("\(tableView)")
        switch (question?.mode)! {
        case 0:
            //单选
            realAnswer?.answer = "\(question?.answers[indexPath.row].answerId ?? 0)"
        case 1:
            //多选
            //为空的话，就先加一个 |
            if (realAnswer?.answer.isEmpty)! {
                realAnswer?.answer = "|"
            }
            realAnswer?.answer.append("\(question?.answers[indexPath.row].answerId ?? 0)|")
        default:
            break
        }
        //把通知发出去
        NotificationCenter.default.post(name: Q_A.NotifyName.answerChanged, object: realAnswer)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        guard indexPath.section == 1 else {
            //第0组，和第2组点了也没用
            return
        }
        switch (question?.mode)! {
        case 0:
            //单选
            break
        case 1:
            //多选
            
            let range = realAnswer?.answer.range(of: "\(question?.answers[indexPath.row].answerId ?? 0)|")
            realAnswer?.answer.removeSubrange(range!)
            if realAnswer?.answer.characters.count == 1 { //只剩最后一个的时候，把剩下的／ 也给删掉
                realAnswer?.answer = ""
            }
            //把通知发出去
            NotificationCenter.default.post(name: Q_A.NotifyName.answerChanged, object: realAnswer)

        default:
            break
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //滑动状态下停止编辑
        view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0001
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
}
