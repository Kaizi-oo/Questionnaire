# Questionnaire

demo 使用**UIPageViewController** 实现，包括单选、多选、简答，题目又分为必选和非必选。

<img src="https://github.com/Kaizi-oo/Questionnaire/raw/master/ScreenShots/IMG_2929.jpg" alt="alt text" title="Title" width="275"/><img src="https://github.com/Kaizi-oo/Questionnaire/raw/master/ScreenShots/IMG_2930.jpg" alt="alt text" title="Title" width="275"/><img src="https://github.com/Kaizi-oo/Questionnaire/raw/master/ScreenShots/IMG_2931.jpg" alt="alt text" title="Title" width="275"/>

* **QAViewController** 为问卷的主题框架，实现题目切换、提交的逻辑

* **QuestionViewController** 为每个题的实现，包括选中的逻辑，

* 通过**通知**实现问题已选和答题卡之间的通讯

详见我的简书:
第一版：[UIPageController实现 问卷、试卷](http://www.jianshu.com/p/776d6b71071e)

第二版加了复用，在master1.0 上面：[UIPageController实现 问卷、试卷 2](http://www.jianshu.com/p/5b0faca44624)
