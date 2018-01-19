---
title:  "Robot Framework教程 —— 安装"
date:   2018-01-17 20:54:16 +0800
categories: test
tags: ["robot", "robotframework", "autotest", "test", "自动化测试"]
---

本文主要讲下如何使用Robot Framework搭建自己的自动化测试框架，包括如下几部分：
- [安装](/test/robot-framework-tutorial-installation "安装")
- [关键字](/test/robot-framework-tutorial-keywords "关键字")
- [整合Jenkins](/test/robot-framework-tutorial-integration-jenkins "整合Jenkins")


## 介绍

### 主要特性
- 它是一款基于Python的，可扩展的关键字驱动（keyword-driven）的自动化测试框架。
- 采用简单易用的表格式语法统一创建测试用例。
- 高复用性：提供了关键字语法，可以使用现有的关键字创建高级的关键字。
- 提供HTML格式的测试结果报表，简单易读。
- 跨平台和应用，不依赖相关环境。
- 提供简单API库创建自定义测试库，可以在本地使用Python或者Java运行。
- 提供命令行CLI界面和基于XML的输出文件。
- 支持Selemium页面测试，Java GUI测试，运行进程，Telnet，SSH等。
- 支持创建数据驱动（data-driven）的测试用例。
- 内置支持变量，尤其适用于在不同环境下进行测试。
- 提供标签分类和可以指定测试用例执行。
- 易于与源码控制整合，测试套件可以是文件或者字典，可以按照源码版本进行管理。
- 提供测试用例和测试套件级别的设置（setup）和拆卸（teardown）
- 模块化架构：支持为多种不同类型接口的应用提供创建针对性测试用例

### 架构设计
Robot Framework是一个通用的，独立于应用和技术的框架。它有一个高度模块化的体系结构，如下图：

<img src="{{ '/assets/images/robot-framework/architecture.jpg' }} " alt="Robot Framework architecture" width="50%"/>

这里进行几点说明：
- 测试数据（`Test Data`）可以采用简单易编辑的表格形式进行撰写。
- 框架启动时，它可以获取测试数据，执行测试用例，并生成日志和报表。
- 核心的框架并不了解测试以下的系统，一般都是通过测试库（`Test Libraries`）进行交互。
- 库既可以直接使用应用接口，也可以使用低级别的测试工具（`Test Tools`）作为驱动。

### 相关截图
下面是测试数据和测试报告的一些截图示例：

<figure>
  <img src="{{ '/assets/images/robot-framework/test-case-data.jpg' }}" alt="Test Case Data"/>
</figure>

<figure>
  <img src="{{ '/assets/images/robot-framework/test-case-report.jpg' }}" alt="Test Case Report"/>
</figure>

## 安装
安装一般有两种方式：Python环境下直接进行安装；或者Java环境下直接使用一个独立Jar包。

### Python
最简单直接的方式，直接使用pip命令进行安装。
```shell
# Install the latest version
pip install robotframework

# Upgrade to the latest version
pip install --upgrade robotframework
```

当然，也可以将[Github源码](https://github.com/robotframework/robotframework)下载下来，进行手动安装：
```shell
python setup.py install
jython setup.py install
ipy setup.py install
pypy setup.py install
```
备注：不同的python环境请使用对应的解释器。


### Java
Java相对简单些，直接去[Maven中心仓库](http://search.maven.org/#search%7Cga%7C1%7Ca%3Arobotframework)下载最新的Jar包即可，包的命名是`robotframework-<version>.jar`。
使用时直接执行如下类似指令即可：
```shell
java -jar robotframework-3.0.2.jar mytests.robot
java -jar robotframework-3.0.2.jar --variable name:value mytests.robot
```

## 参考文档
- [Robot Framework源码](https://github.com/robotframework/robotframework)
- [Robot Framework主站](http://robotframework.org/)
- [Robot Framework文档](http://robotframework.org/robotframework/)
- [Robot Framework用户说明文档](http://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html)
