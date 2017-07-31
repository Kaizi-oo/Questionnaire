//
//  TestViewController.swift
//  Q&A
//
//  Created by kyang on 2017/7/17.
//  Copyright © 2017年 kyang. All rights reserved.
//

import Foundation
import UIKit

import Alamofire

class QAViewController: UIViewController {
    
    var pageViewController: UIPageViewController!
    
    var viewControllers: [UIViewController] = []
    
    var pageIndex = 0 {
        didSet{
            //设置当前页面的下一题按钮的标题
            if pageIndex == questions.count - 1 {
                nextButton.setTitle("提交", for: .normal)
            }else
            {
                nextButton.setTitle("下一题", for: .normal)
            }
        }
    }
    
    //其实可以合成一个model
    var questions = [QAQuestion]() //问题的数组
    var realAnswer = [RealAnswer]() //回答的数组
    
    var pageLabel: UILabel! //页码
    
    var nextButton: UIButton!  //下一题
    
    var answerCard: UICollectionView! //答题卡
    
    var currentController: QAQuestionViewController?
    
    enum QADirection {
        case none
        case last
        case next
    }
//    var translateLock: Bool = false // 枷锁
    
    var direction: QADirection = .none
    
    struct AnswerCardFrame {
        let count: Int
        let maximumInLine: Int = 9  //单行最大
        let space: CGFloat = 10
        let width: CGFloat
        var height: CGFloat {
            let ww = (width - CGFloat(maximumInLine) * space) / CGFloat(maximumInLine)
            let numberOflineDisplay: CGFloat = maximumInLine > count ? 1 : 2
            let hh = (ww + space) * numberOflineDisplay + space
            return hh
        }
        var itemSize: CGSize {
            let ww = (width - CGFloat(maximumInLine) * space) / CGFloat(maximumInLine)
            return CGSize(width: ww, height: ww)
        }
    }
    
    var answerCardFrame: AnswerCardFrame!
    
    func allocData() {
        var json: Data
        let filePath = Bundle.main.path(forResource: "DataSource", ofType: "txt")
        do {
            json = try Data(contentsOf: URL(fileURLWithPath: filePath!), options: Data.ReadingOptions.dataReadingMapped)
            
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: json, options: JSONSerialization.ReadingOptions.mutableContainers)
                
                let arr = jsonObject as? Array<Any>
                
                arr?.forEach({ (quest) in
                    if let question = quest as? [String: Any] {
                        let qqq = QAQuestion(question)
                        questions.append(qqq)
                        //                拿到 questions 之后，再创建realAnswers
                        realAnswer.append(RealAnswer(qqq))
                    }
                })
            } catch {
                print("json decode error")
            }
        } catch  {
            print("cann't find dataSource.txt")
        }
    }
    
    deinit {
        //取消通知监听
        NotificationCenter.default.removeObserver(self)
    }
    
    //TODO: lifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        
        //获取数据
        allocData()
        
        //根据数据个数，设置答题卡的坐标
        answerCardFrame = AnswerCardFrame(count: questions.count, width: view.frame.width - 2 * Q_A.Padding.left)
        
        //背景
        let backgroundView = UIImageView(frame: view.bounds)
        backgroundView.image = #imageLiteral(resourceName: "background")
        view.addSubview(backgroundView)
        
        //返回按钮
        let backButton = UIButton(type: .custom)
        backButton.frame = CGRect(x: 20, y: 35, width: 37, height: 35)
        backButton.setImage( #imageLiteral(resourceName: "back"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        view.addSubview(backButton)
        
        //当前页码
        pageLabel = UILabel(frame: CGRect(x: view.frame.width - 90 - 15, y: 56, width: 90, height: 35))
        pageLabel.textAlignment = .center
        pageLabel.textColor = UIColor.purple
        pageLabel.font = Q_A.Font.senty(size: 44)
        pageLabel.text = "1/\(questions.count)"
        
        view.addSubview(pageLabel)
        
        //主体答题位置
        makePageViewController()
        
        //答题答题卡
        makeAnswerCard()
        
        //下一题
        nextButton = UIButton(type: .custom)
        nextButton.setTitle("下一题", for: .normal)
        nextButton.setTitleColor(UIColor.white, for: .normal)
        nextButton.titleLabel?.font = Q_A.Font.senty(size: 18)
        nextButton.backgroundColor = Q_A.Color.blue
        nextButton.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
        nextButton.frame = CGRect(x: 0, y: 0, width: view.frame.width * 0.5, height: 40)
        nextButton.center = CGPoint(x: view.frame.width * 0.5, y: pageViewController.view.frame.maxY)
        nextButton.layer.cornerRadius = 20
        nextButton.layer.masksToBounds = true
        view.addSubview(nextButton)
        
        //添加通知
        addNotification()
    }
}

//MARK: 创建UI
extension QAViewController {
    
    /// 答题的主题位置
    func makePageViewController() {
        //主体答题位置，设置样式为 pageCurl ，
        pageViewController =  UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: [UIPageViewControllerOptionSpineLocationKey: NSNumber(value:UIPageViewControllerSpineLocation.min.rawValue)])
        pageViewController.view.frame = CGRect(x: Q_A.Padding.left, y: Q_A.Padding.top, width: view.frame.width - 2 * Q_A.Padding.left, height: view.frame.height - Q_A.Padding.top - answerCardFrame.height - 44 - 64)
        pageViewController.delegate = self
        pageViewController.dataSource = self
        
        pageViewController.isDoubleSided = false //单面
        pageViewController.cancleSideTouch()  //自定义，取消了边缘响应点击事件
        
        pageViewController.view.backgroundColor = UIColor.clear
        
        //使用UIBezierPath给答题区域添加了一个虚线边框
        let beziel = UIBezierPath(roundedRect: pageViewController.view.bounds, cornerRadius: 10)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = beziel.cgPath
        shapeLayer.lineDashPattern = [5,2]
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.strokeColor = Q_A.Color.blue.cgColor
        shapeLayer.borderWidth = 1
        shapeLayer.zPosition = -1
        pageViewController.view.layer.addSublayer(shapeLayer)
        
        // 创建2个Controller 留着用
//        for _ in 0..<2 {
//            let current = QAQuestionViewController()
//            current.view.frame = pageViewController.view.bounds
//            //            current.dataSource = (questions[i], realAnswer[i])
//            
//            viewControllers.append(current)
//        }
        
//        let vc = viewControllers.first as? QAQuestionViewController
        let vc = getNextExpectController(index: 0) as? QAQuestionViewController
        vc?.dataSource = (questions[0], realAnswer[0])
        currentController = vc
        
        pageViewController.setViewControllers([vc!], direction: .forward, animated: true) { (bool) in
            print("设置完成")
            self.addChildViewController(self.pageViewController)
            self.view.addSubview(self.pageViewController.view)
            
//            self.pageViewController.didMove(toParentViewController: self) //前面两句已经加了，这句是什么意思？
        }
    }
    
    /// 答题卡
    func makeAnswerCard() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 5
        flowLayout.minimumInteritemSpacing = 5
        
        answerCard = UICollectionView(frame: CGRect(x: Q_A.Padding.left, y: view.frame.height - answerCardFrame.height - 44, width: answerCardFrame.width, height: answerCardFrame.height), collectionViewLayout: flowLayout)
        answerCard.delegate = self
        answerCard.dataSource = self
        answerCard.backgroundColor = UIColor.white
        answerCard.isPagingEnabled = false
        answerCard.register(UINib(nibName: "QAAnswerCardCell", bundle: nil), forCellWithReuseIdentifier: "QAAnswerCardCell")
        answerCard.showsVerticalScrollIndicator = false
        
        //设置边框黄色 背景透明 圆角5
        answerCard.backgroundColor = UIColor.clear
        answerCard.layer.borderColor = Q_A.Color.yellow.cgColor
        answerCard.layer.borderWidth = 0.5
        answerCard.layer.cornerRadius = 5
        
        view.addSubview(answerCard)
    }
}

//MARK: Actions
extension QAViewController {
    
    func backButtonAction() {
        print("click back button")
        let alert = UIAlertController(title: "确定退出", message: "退出后未提交的内容将不被保存，是否继续", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "继续答题", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "退出", style: .default, handler: { (action) in
            //
            print("做退出的逻辑")
        }))
        self.present(alert, animated: true, completion: {
            //
        })
    }
    
    func nextButtonAction() {
        
        if pageIndex < questions.count - 1 {
//            print("next button clicked")
            
            showTargetQuestion(with: self.pageIndex + 1)
            
        }else if pageIndex == questions.count - 1 {
            //最后一个题，提交
            print("next button 提交")
            let alert = UIAlertController(title: "是否提交", message: "提交后不可更改，是否提交", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "继续答题", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "交卷", style: .default, handler: { (action) in
                //
                self.checkAndUpload()
            }))
            self.present(alert, animated: true, completion: {
                //
            })
        }
        
    }
    
    func getNextExpectController(index: Int) -> UIViewController {
        
        let ques = questions[index].mode
//
        let VC = viewControllers.first { (controller) -> Bool in
            let aController = controller as? QAQuestionViewController
            return aController?.lifeCircle == .didDisappear && (aController?.reuseIdentifier)! == "\(ques)"
        }
        
        if VC != nil {
            print("当前是第几个：\(viewControllers.index(of: VC!) ?? 999)")
            return VC!
        }else
        {
            let current = QAQuestionViewController(frame: pageViewController.view.bounds, reuseIdentifier: "\(ques)")
            viewControllers.append(current)
            
            print("当前是第几个：\(viewControllers.index(of: current) ?? 999)")
            
            return current
        }
//        let current = QAQuestionViewController(frame: pageViewController.view.bounds, reuseIdentifier: "\(ques)")
//        viewControllers.append(current)
//        
//        print("当前是第几个：\(viewControllers.index(of: current) ?? 999)")
//        
//        return current

    }
    
    /// 显示相应题目
    ///
    /// - Parameter index: 数组中第几个
    func showTargetQuestion(with index: Int) {

        let pDirection: UIPageViewControllerNavigationDirection = pageIndex < index ? .forward : .reverse
        pageIndex = index

        let vc = getNextExpectController(index: index) as? QAQuestionViewController
        vc?.dataSource = (questions[pageIndex], realAnswer[pageIndex])
        
        pageViewController.setViewControllers([vc!], direction: pDirection, animated: true) { (bool) in

            if bool {
                //设置当前Controller, 完成后去更新 上面的数字
                self.currentController = vc
                self.pageLabel.text = "\(index + 1)/\(self.questions.count)"
                
//                self.currentController?.didMove(toParentViewController: self.pageViewController)
            }
        }
    }
    
    /// 检查并提交--检查是否必填项都已完成
    func checkAndUpload() {
        //
        upload()
        let unDidAnswers = realAnswer.filter { (answer) -> Bool in
            return (answer.answer.isEmpty && answer.required == 1)
        }
        
        guard unDidAnswers.count == 0 else {
            print("any question required is not answerd")
            let firstUnDid = realAnswer.index(of: unDidAnswers.first!)
            let alert = UIAlertController(title: "存在未答题的必选项:\(firstUnDid! + 1)题", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "继续答题", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: {
                //
            })
            return
        }
        //.准备提交
        let results = realAnswer.map{["id": $0.questionId,"answer": $0.answer]}
        
        do{
            let data = try JSONSerialization.data(withJSONObject: results, options: .prettyPrinted)
            
            let jsonStr = String(data: data, encoding: .utf8)
            print(jsonStr ?? "what")
            
        }catch
        {
            print("转json出错了")
        }
    }
    
    func upload() {
        
        let request = Alamofire.request(URL(string: "http://192.168.2.202:8080/user/login")!, method: .post, parameters: ["username":["1":10 ,"2":[1,2,3,4,5], "3": "wo shi tian kong"]], encoding: URLEncoding.default, headers: nil).responseJSON(queue: DispatchQueue.global(), options: JSONSerialization.ReadingOptions.mutableContainers) { (dataResponds) in
            //
            
            print(dataResponds)
        }
        
        print(request.request?.url ?? URLRequest(url: URL(string: "http://111.222.122.322/")!))
        
    }
    
    /// 添加通知监听
    func addNotification() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(answerChanged), name: Q_A.NotifyName.answerChanged, object: nil)
    }
    /// 通知的事件，如果问题被回答。改变答题卡颜色
    ///
    /// - Parameter notify: notify description
    func answerChanged(notify: Notification) {
        //
        let answer = notify.object as? RealAnswer
        print("answer changed")
        let index = realAnswer.index(of: answer!)
        
        let cell = answerCard.cellForItem(at: IndexPath(item: index!, section: 0)) as? QAAnswerCardCell
        
        cell?.isAnswered = !((answer?.answer.isEmpty)!)
    }
}

//MARK: UIPageController的代理事件
extension QAViewController : UIPageViewControllerDelegate, UIPageViewControllerDataSource{
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        print("after- \(pageIndex)")
        if (pageIndex == questions.count - 1)// || translateLock
        { //最后一条
            return nil
        }
        direction = .next
        
        let vc = getNextExpectController(index: pageIndex + 1) as? QAQuestionViewController

        vc?.dataSource = (questions[pageIndex + 1], realAnswer[pageIndex + 1])
        currentController = vc
        return vc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        print("before")
        
        if pageIndex == 0 //|| translateLock
        { //当前页是第一页，那么
            return nil
        }
        
        direction = .last
        let vc = getNextExpectController(index: pageIndex - 1) as? QAQuestionViewController

        vc?.dataSource = (questions[pageIndex - 1], realAnswer[pageIndex - 1])
        currentController = vc
        return vc
    }
    
    func pageViewControllerSupportedInterfaceOrientations(_ pageViewController: UIPageViewController) -> UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    
    //将要到--
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
//        translateLock = true
        
        if direction == .last {//想上 print("will Trans to last")
            pageIndex -= 1
        }else if direction == .next{// print("will Trans to next")
            pageIndex += 1
        }else{
            print("direction 出错了")
        }
        pageLabel.text = "\(pageIndex + 1)/\(questions.count)"
    }
    func pageViewControllerPreferredInterfaceOrientationForPresentation(_ pageViewController: UIPageViewController) -> UIInterfaceOrientation {
        return .portrait
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        //判断是否成功，不成功，重新设置回去
        print("complete \(completed)")
        
        if !completed {
            if direction == .last {
                pageIndex += 1
            }else if direction == .next
            {
                pageIndex -= 1
            }else
            {
                print("direction 出错了")
            }
            pageLabel.text = "\(pageIndex + 1)/\(questions.count)"
            currentController = previousViewControllers.first as? QAQuestionViewController
        }
//        translateLock = false
    }
}
//MARK: 答题卡的代理事件
extension QAViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return questions.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QAAnswerCardCell", for: indexPath) as! QAAnswerCardCell
        
        cell.titleLabel.text = "\(indexPath.row + 1)"
        cell.isAnswered = !(realAnswer[indexPath.row].answer.isEmpty)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return answerCardFrame.itemSize
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(answerCardFrame.space, answerCardFrame.space, answerCardFrame.space, answerCardFrame.space)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //显示相应页面
        self.showTargetQuestion(with: indexPath.row)
    }
}

//MARK: 拓展UIPageViewController，取消了边缘的点击事件
extension UIPageViewController: UIGestureRecognizerDelegate {
    
    /// 拓展一个方法，取消UIPageViewController的点击边界翻页
    fileprivate func cancleSideTouch() {
        for ges in gestureRecognizers {
            ges.delegate=self;
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard gestureRecognizer is UITapGestureRecognizer else {
            return true
        }
        return false
    }

}
