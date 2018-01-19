---
title:  "一小时内使用Jekyll搭建自己的GitHub博客"
date:   2017-12-17 20:18:00 +0800
categories: website
tags: ["GitHub Pages", "Jekyll"]
---

这里主要讲下自己是怎么一步一步从零开始搭建自己的博客的。


## 安装ruby
如果你的本机是macOSx，则执行如下命令即可完成ruby的安装：
```bash
brew install ruby
```

如果机器是其他操作系统，这里就不详述了，可以去参考下[Ruby官方安装文档](https://www.ruby-lang.org/en/documentation/installation/)。

另外，如果gem没有安装成功，可以参考[RubyGems](https://rubygems.org/pages/download)去安装gem。


## 安装Jekyll
在命令行里执行如下命令，即可完成jekyll的安装：
```bash
gem install jekyll bundler
```

**备注：** bundler类似于python的pip工具，用于管理项目中的包依赖等，非常好用；另外，bundler需要项目根目录有一个Gemfile文件，类似python项目的的requirements.txt文件。
{: .notice--warning}


## 创建自己的GitHub Pages
请进入[GitHub Pages](https://pages.github.com/)，按照步骤创建自己的站点。

如果需要本地配置，请参考[GitHub Pages本地设置](https://help.github.com/articles/setting-up-your-github-pages-site-locally-with-jekyll/)。


## 初始化自己的站点
在命令行里执行如下命令，即可完成jekyll站点的初始化：
```bash
jekyll new myblog
```

进入项目，即可进行本地测试：
```bash
cd myblog/
bundle exec jekyll serve
```


## 添加Jekyll主题
我自己选择了[Minimal Mistakes](https://github.com/mmistakes/minimal-mistakes)主题。

创建或者编辑根目录下的Gemfile，增改或者增加如下代码：
```ruby
source "https://rubygems.org"

gem "github-pages", group: :jekyll_plugins
gem "jekyll-remote-theme"
```

执行如下命令，确保包依赖安装完毕：
```bash
bundle update
```

修改根目录下的_config.yml文件：

增加`remote_theme: "mmistakes/minimal-mistakes"`。

然后将[`jekyll-remote-theme`](https://github.com/benbalter/jekyll-remote-theme)添加至自己`_config.yml`文件中`plugins`数组中，例如:
```
plugins:
  - jekyll-remote-theme
```

最后，你可以使用`bundle exec jekyll serve`测试主题是否添加成功了。


## 撰写博文
撰写博文时，需要将文件放在`_post`目录下，文件名的格式一般为`YEAR-MONTH-DAY-title.MARKUP`。

当`YEAR`是一个四位数时，`MONTH`和`DAY`必须都是两位数，`MARKUP`是文件名后缀，下面两个是正确的例子：
```
2016-06-04-hello-world.md
2017-08-18-writing-blogs.markdown
```

如何撰写不熟悉markdown文件，请参考[Mastering Markdown](https://guides.github.com/features/mastering-markdown/)。


## 配置评论
在配置staticman V2时，需要关注以下几点：
- reCaptcha的密钥等设置，需要在`_config.yml`和`staticman.yml`两个文件中都添加。
- reCaptcha的secret需要进行[staticman密钥加密](https://staticman.net/docs/encryption)。

## 参考文档
- [GitHub Pages](https://pages.github.com/)
- [Mistakes Theme Configuration](https://mmistakes.github.io/minimal-mistakes/docs/configuration/)
- [Mastering Markdown](https://guides.github.com/features/mastering-markdown/)
- [Staticman Docs](https://staticman.net/docs/)
- [reCaptcha](https://www.google.com/recaptcha)
