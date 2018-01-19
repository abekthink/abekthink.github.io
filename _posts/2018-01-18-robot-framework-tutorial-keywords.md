---
title:  "Robot Framework教程 —— 关键字"
date:   2018-01-18 23:58:56 +0800
categories: test
tags: ["robot", "robotframework", "autotest", "test", "agile", "keywords", "自动化测试"]
---

本文主要讲下如何使用Robot Framework搭建自己的自动化测试框架，包括如下几部分：
- [安装](/test/robot-framework-tutorial-installation "安装")
- [关键字](/test/robot-framework-tutorial-keywords "关键字")
- [整合Jenkins](/test/robot-framework-tutorial-integration-jenkins "整合Jenkins")

## 声明
框架支持多种方式撰写测试数据和用例，包括HTML、TSV、纯文本、reStructuredText等。本文主要讲解纯文本方式，如果想看其他几种方式，请查看[测试数据格式](http://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#test-data-syntax)。


## 一个简单的示例
让我们直接看一个简单的示例，从而初步理解框架是如何进行测试的。
```
*** Settings ***

*** Test Cases ***
Test Robot Framework Logging
    Log    "Test Logging"
```

`Settings`部分是空的，因为我们并没有引用标准测试库或者外部测试类。现在我们可以忽略它。
`Test Cases`部分，我们定义了一个测试用例。它执行了一个关键字`Log`，我们传递一个`Test Loging`的字符串参数给它。这里有几点需要注意下，关键字与参数之间要至少有2个空格以上。另外，在每一个测试用例下的每一行，都要有至少2个空格以上的缩进。在这个例子中，很明显的看到我们都保留了4个空格，但往往这点容易被人忽略。

以上测试用例，我们可以使用robot或者java命令来去运行测试。如下：
```shell
pybot --outputdir ./reports test0.robot
java -jar /usr/local/opt/robotframework/robotframework-3.0.2.jar --outputdir ./report test0.robot
```

命令行能够支持多种选项，在这上面这个例子中，我们只使用了`--outputdir`选项来指定测试日志和报告存储的目录。


## 关键字 —— 编程语言
使用关键字就像学习了一门新的编程语音。关键字语法包括内置、标注和外部测试库。内置库可以直接使用，无需显式声明import。标准库也是框架的一部分，但是需要在Settings块内显式地声明import。外部库必须单独安装，然后按照标准库的方式导入。
下面举一个例子：
```
*** Settings ***
Library     String


*** Test Cases ***
Test Robot Framework Logging
    Log    Test Logging
    Log Many    First Entry   Second Entry   Third Entry
    Log To Console    Display to console while Robot is running

Test For Loop
    : FOR    ${INDEX}    IN RANGE    1    3
    \    Log    ${INDEX}
    \    ${RANDOM_STRING}=    Generate Random String    ${INDEX}
    \    Log    ${RANDOM_STRING}
```
首先，我们扩展了第一个测试用例，增加了几行调用不同的关键字。尽管这三行都是打日志，但在测试用例定义下执行多个关键字是我们最常用的测试方式。
第二个测试用例实现了一个循环，以及如何执行一个关键字将结果赋值到一个变量中。
因为关键字`Generate Random String`来自于`String Library`，所以我需要在`Settings`块下import它。


## 写自己的关键字
到现在为止，已经学习了怎么是怎么使用保留的关键字。下面我们写自己的第一个关键字：
```
*** Settings ***

*** Test Cases ***
Test Robot Framework Logging
    Log    Test Logging

Test My Robot Framework Logging
    My Logging    My Message    WARN

*** Keywords ***
My Logging
    [Arguments]    ${msg}    ${level}
    Log    ${msg}    ${level}
```
自己的关键字需要写在`Keywords`块下。语法和写测试用例一样，最大的不同是可以再自己的关键字里传递参数。


## 管理关键字 —— 资源文件
当然，随着关键字定义越来越多，测试用例文件会越来越复杂，不容易管理。为了解决这个，可以考虑在所谓的资源文件里定义新的关键字，然后这些资源文件可以与测试库一样被导入进测试用例文件。

资源文件如下：
```
*** Keywords ***
My Logging
    [Arguments]    @{arg}
    Log Many    @{arg}
```

测试用例文件如下：
```
*** Settings ***
Resource        resource-0.txt

*** Variables ***
${MESSAGE}    "Test My Logging 3"

*** Test Cases ***
Test Robot Framework Logging
    Log    "Test Logging"

Test My Logging
    My Logging    "Test My Logging 1"    "Test My Logging 2"    ${MESSAGE}
```
在上面这个例子中，测试用例文件和资源文件必须在同一个目录下；当然，也可以把资源文件放在子目录下，在import时也需要使用那个相对路径。
另外，上面例子中还使用了`Variables`块来定义变量。


## 高级功能
现在已经学会了写自己关键字、资源文件和测试用例文件的基本知识。当然还会有一些更高级的功能。下面列了两个你可能会使用到的功能。

### 设置和拆卸
下面这个列子显示了在执行关键字前，需要做的准备工作以及测试完成后做的清理工作。
```
*** Settings ***
Suite Setup       Setup Actions
Suite Teardown    Teardown Actions

*** Test Cases ***
Test Robot Framework Logging
    Log    Test Logging

*** Keywords ***
Setup Actions
    Log    Setup Actions done here

Teardown Actions
    Log    Teardown Actions done here
```

### 打标签
打标签和关键字并没有关系，但是这是一个很好的方式，在测试完成后产生的测试报表中有利于更好地理解报表。
```
*** Settings ***
Suite Setup       Setup Actions
Suite Teardown    Teardown Actions

*** Test Cases ***
Test Robot Framework Logging
    [Tags]    sample   logging
    Log    Test Logging

*** Keywords ***
Setup Actions
    Log    Setup Actions done here

Teardown Actions
    Log    Teardown Actions done here
```
这些标签在报表中会进行汇总，你可以查看有多少测试用例与这些标签有关。


## 报告与日志文件
Robot Framework框架产生的报告和日志文件功能是非常强大的。

<figure>
  <img src="{{ '/assets/images/robot-framework/keywords-report.jpg' }}" alt="Report File"/>
</figure>

正如上面的截图，显示了测试结果不同维度的统计。你可以看到有多少测试用例打上了同一个标签。另外，你还可以按照测试套件查看统计，如下图。

<figure>
  <img src="{{ '/assets/images/robot-framework/keywords-report-suites.jpg' }}" alt="Report File Details"/>
</figure>

值得高兴的是你还可以继续深挖，点击某一个具体用例查看其具体的结果。这样会打开一个新的日志页面。这个页面可以查看每一个关键字被执行的结果。如果一个用例执行失败了，可以非常方便地查看到具体是什么原因导致的。

<figure>
  <img src="{{ '/assets/images/robot-framework/keywords-log.jpg' }}" alt="Log File"/>
</figure>


## 参考文档
- [Robot Framework文档](http://robotframework.org/robotframework/)
- [Robot Framework用户说明文档](http://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html)
- [Robot Framework标准库](http://robotframework.org/robotframework/#standard-libraries)
- [Keywords语法简明教程](https://github.com/ThomasJaspers/robot-keyword-tutorial)
- [本文代码示例](https://github.com/abekthink/robot-framework-demo)
- [robot-keyword-tutorial](https://github.com/ThomasJaspers/robot-keyword-tutorial)
