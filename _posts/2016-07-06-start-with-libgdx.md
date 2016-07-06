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

![gdx-setup](https://raw.githubusercontent.com/androidzhibinw/androidzhibinw.github.io/master/images/2016-07-06/gdx-setup.png



[libgdx]:https://libgdx.badlogicgames.com
[libgdx-github]:https://github.com/libgdx/libgdx
[java-download]:http://www.oracle.com/technetwork/java/javase/downloads/index.html
[android-stdio-download]:https://developer.android.com/studio/index.html?gclid=Cj0KEQjwte27BRCM6vjIidHvnKQBEiQAC4MzrZl8T_5ohKht6iz0xGcHfPUMurj7umhbRCObCJUMeyIaAhGV8P8HAQ
[create-libgdx-project]:https://github.com/libgdx/libgdx/wiki/Project-Setup-Gradle