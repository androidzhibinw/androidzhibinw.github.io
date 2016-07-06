--- 
layout: post
title: "Start With Libgdx for  Android on Windows"
published: true
date: 2016-07-06
categories: libgdx,game,android
---

libgdx 是个开源 game engine 框架， 支持多个平台(Android,IOS,WEB,Desktop)，主要语言是 Java。 [主页][libgdx] , [Github][libgdx-github]

##1. 安装 Java 和　Android Stdio

- [java 下载地址][java-download] (Android api >=24 需要 java 1.8,23 以前 1.7)
- [Android Stdio 下载][android-stdio-download] (需翻墙) 

##2. 创建一个 libgdx project 

- [Wiki][create-libgdx-project]

首先需要下载一个 gdx-setup.jar 这个工具包可以提供GUI界面帮助创建一个完整的 libgdx project.

运行：

    java -jar gdx-setup.jar 

就可以看到：

![gdx-setup](https://raw.githubusercontent.com/androidzhibinw/androidzhibinw.github.io/master/images/2016-07-06/gdx-setup.png)


Destination 和 Android SDK 选好，点击 Generate.

这时候可能会弹出 Warning ：

> You have a more recent version of andoid build tool than recommanded. Do you want to use your more recent version. 

意思是你的 Android SDK 支持的最高平台比 libgdx 推荐的要高，是否用你 SDK 最高的。如果你的 java 是1.8 了，可以选择是， 否则选择否。Android api 24 以上需要 java 1.8 编译。如果不知道可以无脑选择否。

然后就生成好了 ， 使用 Android Stdio 导入 

> To import to Intellij IDEA: File -> Open -> build.gradle

打开 Android Stdio => File=>New=>Import Project => 选择 sample (上面生成的) 里面的 build.gradle 

导入好了， Android project 可以直接 Run。

Desktop Project 需要 Edit Configurations， 添加一个 Application , 填好下面参数： 

![gdx-setup](https://raw.githubusercontent.com/androidzhibinw/androidzhibinw.github.io/master/images/2016-07-06/add-configuration.png)

然后就可以 run 了， 成功出来： 

![gdx-setup](https://raw.githubusercontent.com/androidzhibinw/androidzhibinw.github.io/master/images/2016-07-06/success.png)



[libgdx]:https://libgdx.badlogicgames.com
[libgdx-github]:https://github.com/libgdx/libgdx
[java-download]:http://www.oracle.com/technetwork/java/javase/downloads/index.html
[android-stdio-download]:https://developer.android.com/studio/index.html?gclid=Cj0KEQjwte27BRCM6vjIidHvnKQBEiQAC4MzrZl8T_5ohKht6iz0xGcHfPUMurj7umhbRCObCJUMeyIaAhGV8P8HAQ
[create-libgdx-project]:https://github.com/libgdx/libgdx/wiki/Project-Setup-Gradle