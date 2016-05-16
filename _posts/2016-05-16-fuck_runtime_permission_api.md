--- 
layout: post 
title: "Fuck Android Runtime Permission API"
published: true
date: 2016-05-16
categories: Android
---

今天 吐槽下 Android Runtime Permission API 相关的设计。只吐槽缺点！

##Background
 参考 [http://developer.android.com/intl/zh-cn/guide/topics/security/permissions.html][1]

##吐槽点 1: 所有权限都可以被用户拒绝。

看起来是合理的，但是细想一下，如果应用的权限都被用户拒绝了，这应用还有啥存在的意义？如果应用是系统某方面的Default Handler .  举个短信例子好了，假设系统只有一个 Message 应用收发短信，权限都被拒绝了，用户还能收到短信不？？电话权限被拒绝了就不能打电话，接电话了呗！你可以说这是用户自己的行为，好吧！就算是用户自作自受吧。
那么对于开发来说怎么办呢？情况见下面一点。

##吐槽点 2: 拒绝基本权限后无法提供统一入口。

假设应用权限都被拒绝了，应用开发者要在这种情况下保证所有代码能正常！我TM原来有100W行代码原来都是基于权限默认给我的，你TM 现在说不给了，让我去检查 100W 行代码那些地方使用了权限，去修改也好，加保护也好，你TM还是人吗？
你TM 能提供个机制不?这个机制就是，没赋予应用基本权限的时候，只能进入某个入口（Activity，用来引导用户授予权限和解释缺少权限的后果）。 别的地方没有权限，别TM 给我触发，触发了没法保证正常！！(receiver,servcie,providers 等等) 

## 吐槽点 3: request Permission 需要　Activity, 回调也在　activity 

Service/Receiver 以及其他地方原来需要权限的代码怎么办！只有 Activity 需要申请权限吗？

## 吐槽点 4: requestPermissions 无法传递可变参数列表 

原来是同步的，授予权限的情况下 对 A，B,C 三个对象进行修改。现在需要在操作A，B，C之前先申请权限，申请权限之后回调到了TM activity 的 onRequestPermissionsResult。TMD 你要告诉我 A,B,C 怎么传递到onRequestPermissionsResult 这里面去修改！我TM 原来修改 A,B,C的地方和那个activity 根本不在一个文件！！你TM 能不能让我把 A,B,C传过去，在回调onRequestPermissionsResult的时候，再TM给我不行吗！


## 吐槽 5： 没有 API 判断用户是否勾选了 Never ask again. 

你 TM 能不能告诉我 用户是否勾选了  Never ask again ？ 到底有没有？没有我就可以 request Permission了, 有的话我就不请求了（请求也没用!）！

## 6： shouldShowRequestPermissionRationale()

[code](http://androidxref.com/6.0.1_r10/xref/frameworks/base/services/core/java/com/android/server/pm/PackageManagerService.java#3808)

谁TM 能解释下这代码？ TMD 什么时候该用这个 API ？ 还不如把 flags 返回给我，让我自己去判断呢！

##
[1]:http://developer.android.com/intl/zh-cn/guide/topics/security/permissions.html 