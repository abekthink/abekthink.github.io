---
title:  "Robot Framework教程 —— 整合Jenkins"
date:   2018-01-19 17:25:10 +0800
categories: "test"
tags: ["robot", "robotframework", "autotest", "test", "jenkins", "自动化测试"]
---

本文主要讲下如何使用Robot Framework搭建自己的自动化测试框架，包括如下几部分：
- [安装](/test/robot-framework-tutorial-installation "安装")
- [关键字](/test/robot-framework-tutorial-keywords "关键字")
- [整合Jenkins](/test/robot-framework-tutorial-integration-jenkins "整合Jenkins")


## 安装
网上安装Jenkins的文章很多，这里不详细介绍了，具体可以查看如下文档：
- [Jenkins官方文档](https://jenkins.io/doc/pipeline/tour/getting-started/)
- [Mac OS X 安装Jenkins](https://www.jianshu.com/p/ab3302cd68eb)


## 创建任务
在Jenkins首页左边导航栏点击新建任务，创建一个freestyle类型的任务。如下图：

<figure>
  <img src="{{ '/assets/images/robot-framework/jenkins-new-job.jpg' }}" alt="Jenkins New Job"/>
</figure>

上一篇文章我们已经写了一批[测试示例](https://github.com/abekthink/robot-framework-demo)，所以这里我们只要引用就可以了。

为了能够及时的获取最新代码进行测试，我们需要对Jenkins里GitHub相关的配置进行下设置：
- 在`General`部分，填写下`GitHub project`字段：`git@github.com:abekthink/robot-framework-demo.git`
- 在`源码管理`部分，选择`Git`选项，然后填写`Repository URL`字段：`git@github.com:abekthink/robot-framework-demo.git`

<figure>
  <img src="{{ '/assets/images/robot-framework/jenkins-job-general.jpg' }}" alt="Jenkins Job General"/>
</figure>

<figure>
  <img src="{{ '/assets/images/robot-framework/jenkins-job-scm.jpg' }}" alt="Jenkins Job SCM"/>
</figure>

然后我们在`构建`部分，选择`Execute shell`配置一个shell脚本：
```shell
mkdir -p reports/robot-framework-demo
/usr/local/bin/robot --outputdir reports/robot-framework-demo test3.robot
```

<figure>
  <img src="{{ '/assets/images/robot-framework/jenkins-job-build.jpg' }}" alt="Jenkins Job Build"/>
</figure>

这样就完成了整个任务的配置，不过这时候产出的文件我们并不能直接看到测试报告。
所以，下一节我们会讲下使用`Robot Framework plugin`来更加直观的查看测试结果。


## 配置测试插件
从`首页` -> `系统管理` -> `管理插件`打开插件管理的页面。在页面选择`可选插件`，然后搜索`robot`，结果中有个`Robot Framework plugin`，这个就是我们想要的，我们安装即可。

<figure>
  <img src="{{ '/assets/images/robot-framework/jenkins-plugin-management.jpg' }}" alt="Jenkins Plugin Management"/>
</figure>

插件安装完成后，我们就可以直接应用在我们刚才的任务里了。打开刚才任务的配置页面，在`构建后操作`部分：
- 选择`Publish Robot Framework test results`进行编辑。
- 在`Directory of Robot output`字段里填写刚才报表的产出目录`reports/robot-framework-demo`。
- 在`Thresholds for build result	`部分可以配置项目在什么情况下显示蓝灯和黄灯，这里配置了当测试用例20%失败时则显示黄灯。

<figure>
  <img src="{{ '/assets/images/robot-framework/jenkins-job-config-robot.jpg' }}" alt="Jenkins Job Config Robot"/>
</figure>

<figure>
  <img src="{{ '/assets/images/robot-framework/jenkins-job-config-robot-1.jpg' }}" alt="Jenkins Job Config Robot"/>
</figure>

配置完成后，可以去任务里`立即构建`，查看刚刚配置的结果。

<figure>
  <img src="{{ '/assets/images/robot-framework/jenkins-job-result.jpg' }}" alt="Jenkins Job Result"/>
</figure>


## 无法查看HTML
为了查看具体的测试结果，我们去打开`Robot Framework plugin`产生的`report.html`和`log.html`，最后发现无法打开，报出如下错误：

<figure>
  <img src="{{ '/assets/images/robot-framework/jenkins-html-error.jpg' }}" alt="Jenkins HTML Error"/>
</figure>

在Google上查询了相关问题，分析得来主要是因为在Jenkins 1.641引入了CSP头保护本地文件。
所以要解决这个问题有两个版本：一个是直接修改Java启动时CSP有关的参数；另一个是增加groovy文件，在Jenkins启动时生效。
这里我们采用了第一种，比较简单直接，直接修改tomcat中的`catalina.sh`，在文件最上面增加如下几行：
```
JENKINS_CSP_OPTS="sandbox allow-scripts; default-src 'none'; img-src 'self' data: ; style-src 'self' 'unsafe-inline' data: ; script-src 'self' 'unsafe-inline' 'unsafe-eval' ;"
JENKINS_OPTS="-Dhudson.model.DirectoryBrowserSupport.CSP=\"$JENKINS_CSP_OPTS\""
CATALINA_OPTS="$JENKINS_OPTS $CATALINA_OPTS"
```
将Tomcat关闭然后重新启动，就能正常查看相关报表了。


## 配置自动化
我们希望当代码提交时就能进行立即触发Jenkins任务的构建和测试，这样整个自动化才能完全实现，所以，这里提一下如何进行配置。

这里依然拿`robot-framework-demo`来举例：
- 首先在Jenkins上该任务的设置页面的`构建触发器`板块，将`GitHub hook trigger for GITScm polling`选项打勾。
- 然后，去GitHub上`robot-framework-demo`项目设置里配置`Webhooks`，创建一个新的webhook。
    - URL的格式是`$JENKINS_BASE_URL/github-webhook/`，这里的JENKINS_BASE_URL就是你Jenkins服务的链接地址。
    - Trigger类型的话可以只选择Push事件。

<figure>
  <img src="{{ '/assets/images/robot-framework/jenkins-job-github-trigger.jpg' }}" alt="Jenkins Job GitHub Trigger"/>
</figure>

配置完成后，当项目的master有代码push时，即可触发webhook；然后触发Jenkins上的任务进行构建，这样就是实时查看最新的测试报告了。


## 参考文档
- [Jenkins官方文档](https://jenkins.io/doc/)
- [GitHub Plugin for Jenkins](https://wiki.jenkins.io/display/JENKINS/GitHub+Plugin)
- [Configuring Content Security Policy](https://wiki.jenkins.io/display/JENKINS/Configuring+Content+Security+Policy)
- [Robot Framework log/report file can not be opened](https://issues.jenkins-ci.org/browse/JENKINS-32118)
- [Adjusting the Jenkins Content Security Policy](https://www.cyotek.com/blog/adjusting-the-jenkins-content-security-policy)
