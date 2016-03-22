--- 
layout: post 
title: "How Messaging Implement Runtime Permission"
published: true
date: 2016-03-22
categories: android runtime permission messaging
---

 How Messaging Implement Runtime Permission

Android M 上新增加了一个 [open source 的 SMS/MMS 应用 Messaging][1]，这个应用支持了 Android 6.0 上的 runtime permission, 来分析下它是怎么做的。如果不了解 Android 6.0 的 runtime permission , 可以看[这里][2],或 [官方文档 （需翻墙)][3]。

先看下 [Messaging][1] 的行为 （前提：Messaging 安装之前系统有SMS/MMS 应用) ：


- 新安装上 [Messaging][1], 如果它不是唯一的 SMS application，也不是 default SMS application , 安装之后不带任何 permisssions. 

![messaging-permission-initialize](https://raw.githubusercontent.com/androidzhibinw/androidzhibinw.github.io/master/images/2016-03-22/messaging-permission-initialize.png)

- 如果将 [Messaging][1] 设为 default SMS application(如果安装时是唯一的 SMS application 默认会是 default SMS application)，系统自动会赋予三个基本权限组：Contacts,Phone,SMS。

![messaing-default-sms](https://raw.githubusercontent.com/androidzhibinw/androidzhibinw.github.io/master/images/2016-03-22/messaing-default-sms.png)

- 如果 [Messaging][1] 启动已获得三个基本权限组：Contacts,Phone,SMS，则直接进入应用里面，显示 ConversationList。

![normal](https://raw.githubusercontent.com/androidzhibinw/androidzhibinw.github.io/master/images/2016-03-22/normal.png)

- 如果 [Messaging][1] 启动未获得三个基本权限组：Contacts,Phone,SMS， [Messaging][1] 会显示一个需要三个基本权限的界面，上面有两个 Buttons , EXIT 和 NEXT， 点 EXIT 直接退出， 点 NEXT，会弹出三个请求用户授权 三个基本权限组：Contacts,Phone,SMS 的 Dialog, 如果 用户都 Allow 了，进入，否则，重复弹出请求收取的 Dialog，直到都 Allow 或者 选择 DENY + Never ask again.

![no-permission-start](https://raw.githubusercontent.com/androidzhibinw/androidzhibinw.github.io/master/images/2016-03-22/no-permission-start.png)


![request-permission1](https://raw.githubusercontent.com/androidzhibinw/androidzhibinw.github.io/master/images/2016-03-22/request-permission1.png)


![request-permission2](https://raw.githubusercontent.com/androidzhibinw/androidzhibinw.github.io/master/images/2016-03-22/request-permission2.png)


![request-permission3](https://raw.githubusercontent.com/androidzhibinw/androidzhibinw.github.io/master/images/2016-03-22/request-permission3.png)

![ask-again](https://raw.githubusercontent.com/androidzhibinw/androidzhibinw.github.io/master/images/2016-03-22/ask-again.png)

- 如果 [Messaging][1] 启动未获得三个基本权限组：Contacts,Phone,SMS，并且选择了 DENY + Never ask again.NEXT Button 会变成 SETTINGS， 同时显示用户需要在 Settings->Apps->Messaging->Permissions 里面授权这三个权限。点击 SETTINGS 会跳到 Settings->Apps->Messaging->Permissions。

![dont-ask-again](https://raw.githubusercontent.com/androidzhibinw/androidzhibinw.github.io/master/images/2016-03-22/dont-ask-again.png)


[Messaging][1]  应用内需要的其他权限如 Camera，会在操作执行之前动态请求授权。


![picture](https://raw.githubusercontent.com/androidzhibinw/androidzhibinw.github.io/master/images/2016-03-22/picture.png)

[1]:http://androidxref.com/6.0.1_r10/xref/packages/apps/Messaging/
[2]:https://androidzhibinw.github.io/android/runtime/permission/2016/03/21/android-runtime-permission/
[3]:http://developer.android.com/training/permissions/requesting.html 
