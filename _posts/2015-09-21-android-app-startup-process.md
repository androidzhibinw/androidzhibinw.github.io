--- 
layout: post 
title: "Android 应用程序启动过程分析 "
published: true
date: 2015-09-21
categories: android app startup activity
---

学习并分享 Android  应用启动过程 => 

## 为什么要写这篇文章？

### 梳理总结
前一段时间在做 Android 应用启动的 performance 相关的工作，对这应用启动的流程做了一些了解和分析，通过写作的方式进行一下梳理和总结。写作的过程是一个记述的过程，也是一个再加工和表达的过程。可以加深自己对所做工作的理解，同时也能发现工作中疏漏的方面，弥补这些不足，使自己能有一个更全面和深入的认识。

### 表达，分享，交流
写作是一个表达的过程，通过写作来提高程序员比较欠缺的表达能力。有很多人因为欠缺表达能力或是羞于表达而被埋没，也有很多人表达太盛而容易被高估。做一个踏实的程序员工程师，技术求精细，表达求严谨。将自己的认识和理解分享出来，可以避免很多无意义的重复工作从头开始，给别人和自己作为参考。通过分享促成交流，方便认识更多的朋友哦。

### 缺少好文章
Android 分析的文章很多，但是缺少好文。分析应用程序启动过程的文章不少，但多是泛泛而谈，[老罗这篇][1]倒是比较详细，不过除了罗列了下调用过程(你自己也可以在一个下午之内搞清楚这个调用过程)，再无其他。缺少自己的思考，理解和加工。

## 写作的目标要求
为了提升自己的表达水平，对自己提出了一些要求，希望越来越好。

### 深入浅出

读书要先厚再薄，文章宜深入而浅出。细节是复杂的，原理是简单的。透过细节去发现原理，而不是迷失在细节中。细节往往是多变的，如代码更新这么频繁，过时的细节阐述其实是一种错误和误导。原理是相对恒定不变的，理解了原理则可以融会贯通，举一反三。所以，好的文章总是透过复杂的现象去发现本质，透过复杂的细节去归纳原理。[Linux Kernel Development ][2] 就是一本不错的深入浅出的书。

### 注重方法
大多数文章都是在描述是什么，而没有说为什么是这样和怎么得到这个结果的。授之以鱼不如授之以渔，传授怎么样学习的方法比得到结果更有意义。只要找对方法，可以在一个下午之内搞清楚整个启动过程，不比看那些罗列细节的文章更有意义麽？

### 思考设计
是什么重要，是什么都不知道的话，你也不会去琢磨为什么。为什么更重要，只有思考为什么，你才能知道这个是不是真的对，是不是真的好，能不能改成别样，能不能不要，能不能优化，才能让它变得更好，才能触类旁通。

## 分析的范围
### onClick 到 Display
分析的范围定位于从 Launcher 点击应用图标到应用显示在屏幕上这一过程。这里以 Calculator 应用为例。

## 框架概述

###前期准备信息
1. 基于 Android 5.1 的代码。
2. 这里会涉及到四个进程:Launcher,SystemServer,Zygote,Calculator。

###用户的角度
从用户的角度来看，这个过程是十分简单流畅的，用户在一个界面点击了一个图标或者按钮，新的界面跳出来显示在屏幕最前端。这个过程在其他操作系统 Ubuntu，IOS，Windows上面也都是如此。

###从系统的角度
先提出一个问题：作为一个支持 GUI 的操作系统，应该为应用程序开发提供什么样的接口？ 读者可以自行思考这个问题并找到自己的答案，相信会对系统有更深的认识。

虽然不是每个人都会思考这样的问题，但是提出这个问题应该是很自然的事情。在一个系统上开发应用程序，自然要了解系统为应用程序开发提供了什么样的接口，再深入一点说，让你去设计一个系统，你会为应用程序开发提供什么接口，让开发者可以快速高效的进行应用程序开发？

我个人的理解，从大的方面说，至少要两点：

1. 开发语言和程序启动入口
2. GUI 支持 

系统至少要提供一种开发语言的编译和运行环境吧，要不然程序怎么创建呢？系统还需要提供程序启动入口来让开发者可以添加自己的代码，运行自己的逻辑,如 Linux环境下 C 语言的 main 函数。
当然 shell 是个天才的设计，作为CLI给用户提供了很多，不限于开发语言和启动程序的入口。Android 提供给开发者的是 Java 语言和运行环境，程序启动入口是如何提供的呢？

作为一个支持 GUI 的系统，还需提供GUI的支持。当然这包含很多方面，我指的是提供给应用程序一个创建 Window 的接口，让其可以通过 Window 与用户交互（显示内容，获取反馈等)。当然不只是这么简单，肯定需要一套 Window 管理的框架。 如 Linux 的 X Window System , 可以参考下面这个图。思考一下 Android 是怎么实现这个的？ （相信 Android 从 X Window 借鉴了不少）

![X Window System](https://raw.githubusercontent.com/androidzhibinw/androidzhibinw.github.io/master/images/250px-X_client_server_example.svg.png)

> The X Window System was designed to allow multiple programs to share access to a common set of hardware. This hardware includes both input devices such as mice and keyboards, and output devices: video adapters and the monitors connected to them. A single process was designated to be the controller of the hardware, multiplexing access to the applications. This controller process is called the X server, as it provides the services of the hardware devices to the client applications. In essence, the service the Xserver provides is access, through the keyboard, mouse and display, to the X user.

可以通过 [X Window System Protocol][x-req] 来参考一个 Window System  提供的基本功能：创建 Window，销毁 Window，配置 Window 属性，绘制内容，获取用户反馈等等。

再在来张图吧：

![X Server Client Example ](https://raw.githubusercontent.com/androidzhibinw/androidzhibinw.github.io/master/images/250px-X_client_server_example.svg.png)

[XLib][x-lib] 是 [X Window System Protocol][x-req] 协议的 Client 端的 C语言实现 , 将协议封装成了 C 语言函数供开发者使用。[XLib Wiki][x-lib] 里面有一段直接使用 [XLib][x-lib] 创建 Window 的代码示例，有兴趣可以看一下使用基础的协议如何实现GUI。

>Rather than develop directly for X, we recommend you use a toolkit such as GTK+ or Qt. There are many other popular toolkits, some special-purpose, such as Clutter and Enlightenment/EFL. 

光有协议和基础协议的实现也还是不够的，让开发者自己从零创建自己要展示的内容(View)，自己监听 Server 反馈的事件分发到自己的 View 上，是重复和低效的。因此这部分内容也是系统需要提供的。所以几乎没有人会直接基于 [XLib][x-lib] 开发应用程序，而是使用 [GTK][gtk] 或者 [QT][qt] 这类封装了 [XLib][x-lib] 并集成了大多数常用的 UI 控件的开发包。当然它们还集成了其他很多东西方便开发者，UI 响应事件的回调，其他非图形的类库，IDE开发环境等等。系统相关的一切他们都准备好了，只差开发者开发自己的业务逻辑。

移动操作系统和桌面操作系统还有一点比较大的区别，就是屏幕太小（当然发展趋势是越来越大的），在移动操作系统上通常需要很多屏的内容要显示，每一屏内容和其他会产生关联，最常见的就是顺序调用，比如一个有多个注册流程的应用。这些内容需要window来展示。那么 app 有多屏的内容展示，这多屏的内容如何去对应window呢？使用一个window还是多个？在 app 侧是否需要一个抽象的组件去对应它们？思考到这里，我觉得 Android 和 IOS 都是设计得非常出色的系统。

Android 的 [Activity][activity] 和 IOS 的 [UIViewController][u-v-c] 就是设计来解决上面的问题。再提出一些问题：

- Android 的 [Activity][activity] （IOS 的 [UIViewController][u-v-c]） 是否和 window 一一对应？(或许再读一下文档和代码你就明白了）
- [Activity][activity]　和　[UIViewController][u-v-c]　的设计需要完成什么功能？

到这里，相信每个人对　[Activity][activity]　都有了一些自己的疑问或想法。

[Activity][activity]　和　[UIViewController][u-v-c]　有很多相似的地方，下图(来自[这里][activity-uvc])展示了它们的生命周期：

![activity-uiviewcontroller](https://raw.githubusercontent.com/androidzhibinw/androidzhibinw.github.io/master/images/activity-uiviewcontroller.png)

还有这个表格（来自[这里][table-a-uvc]）：

![activity-uiviewcontroller](https://raw.githubusercontent.com/androidzhibinw/androidzhibinw.github.io/master/images/android-uiviewcontroller.png)

###启动过程概况
1. Launcher 接收到点击事件，获取应用的信息，向 SystemServer(ActivityManagerService 简称AMS 运行在里面) 发起启动应用的请求。
2. SystemServer(AMS)  请求 Launcher Pause （Launcher 需要保存状态进入后台）
3. Launcher Pause ， 向 SystemServer(AMS) 发送 Pause 完毕
4. SystemServer(AMS) 向 Zygote 请求启动一个新进程(calculator) 
5. Zygote [fork][fork]  出新进程(calculator) , 在新进程中执行 ActivityThread 类的 main 方法
6. calculator 向 SystemServer(AMS) 请求 attach 到 AMS
7. SystemServer(AMS) 请求 calculator launch
8. calculator 调用 onCreate ， onResume 回调
9. calculator 界面显示自屏幕上(还需细分)

自己画了一张图，（没包含9) ，有点丑,呵呵：
![app-start](https://raw.githubusercontent.com/androidzhibinw/androidzhibinw.github.io/master/images/app-process.png)

###如何分析这个过程
#### [官方文档][android-dev] 
Android [官方文档][android-dev]  是最好的文档资料，文档会经常更新，每次看可能都有新的理解，所以看再多次也不为过。
### 代码
任何文档分析都代替不了代码，代码是唯一能代表系统的东西，代码就是系统本身，所以在编程上一个惯例的要求是可读性要高，代码就是详细设计，而专门的文档只去描述 High Level 的架构。

[androidxref.com][androidxref] 是一个在线查看 Android 代码的网站，方便任何时候任何地方查看代码。

### 代码调试
代码是静态的，单纯去看代码可能会陷入细节当中，看不清楚代码运行时的状态和流程。而且代码的跳转非常频繁，很容易跟着跟着就跟丢了。所以需要调试技术来跟踪查看器运行的轨迹。下面就列举一个我认为最简单实用的调试方法--打印 StackTrace, 如下：

    Log.d("tag","message",new RuntimeException("").fillInStackTrace());

在关键点加入 StackTrace 打印，就可以清晰的看出它前向的所有函数调用栈，下面这个是在
**ActivityManagerProxy.java** 的 `startActivity` 函数打印的调用栈： 

    07-29 07:06:11.691  6231  6231 D zhibinw : java.lang.RuntimeException: ActivityManagerProxy-startActivity
    07-29 07:06:11.691  6231  6231 D zhibinw : 	at android.app.ActivityManagerProxy.startActivity(ActivityManagerNative.java:2409)
    07-29 07:06:11.691  6231  6231 D zhibinw : 	at android.app.Instrumentation.execStartActivity(Instrumentation.java:1496)
    07-29 07:06:11.691  6231  6231 D zhibinw : 	at android.app.Activity.startActivityForResult(Activity.java:3788)
    07-29 07:06:11.691  6231  6231 D zhibinw : 	at android.app.Activity.startActivity(Activity.java:4055)
    07-29 07:06:11.691  6231  6231 D zhibinw : 	at com.android.launcher3.Launcher.startActivity(Launcher.java:3314)
    07-29 07:06:11.691  6231  6231 D zhibinw : 	at com.android.launcher3.Launcher.startActivitySafely(Launcher.java:3338)
    07-29 07:06:11.691  6231  6231 D zhibinw : 	at com.android.launcher3.Launcher.startAppShortcutOrInfoActivity(Launcher.java:3108)
    07-29 07:06:11.691  6231  6231 D zhibinw : 	at com.android.launcher3.Launcher.onClickAppShortcut(Launcher.java:3067)
    07-29 07:06:11.691  6231  6231 D zhibinw : 	at com.android.launcher3.Launcher.onClick(Launcher.java:2895)
    07-29 07:06:11.691  6231  6231 D zhibinw : 	at android.view.View.performClick(View.java:4781)
    07-29 07:06:11.691  6231  6231 D zhibinw : 	at android.view.View$PerformClick.run(View.java:19874)
    07-29 07:06:11.691  6231  6231 D zhibinw : 	at android.os.Handler.handleCallback(Handler.java:739)
    07-29 07:06:11.691  6231  6231 D zhibinw : 	at android.os.Handler.dispatchMessage(Handler.java:95)
    07-29 07:06:11.691  6231  6231 D zhibinw : 	at android.os.Looper.loop(Looper.java:135)
    07-29 07:06:11.691  6231  6231 D zhibinw : 	at android.app.ActivityThread.main(ActivityThread.java:5258)
    07-29 07:06:11.691  6231  6231 D zhibinw : 	at java.lang.reflect.Method.invoke(Native Method)
    07-29 07:06:11.691  6231  6231 D zhibinw : 	at java.lang.reflect.Method.invoke(Method.java:372)
    07-29 07:06:11.691  6231  6231 D zhibinw : 	at com.android.internal.os.ZygoteInit$MethodAndArgsCaller.run(ZygoteInit.java:904)
    07-29 07:06:11.691  6231  6231 D zhibinw : 	at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:699)
    
通过这个调用栈，就可以看出在 Launcher 进程向 AMS 发请求的函数调用。这种方式在 Andorid 的 framework 的代码里很常见，比如 [这里][stack-trace]。通过这种方式，你就可以在很短的时间里搞清楚整个流程的调用关系(一个下午够了吧？)，当然，还是要花一些时间找到关键点的（只要理清了跨越进程的调用，关键点还是很容易找的）。

## 详细调用分析
下面结合各阶段的 StackTrace ，来详细看看每个调用过程。看看有什么要学习的。

### 1. Launcher 接收到点击事件向AMS发起启动应用的请求。
StackTrace 就是上面贴的那一段，就不重复贴了。从这个 StackTrace 里面我们可以看出来不少东西呢：

1. Launcher 进程启动的调用栈：ZygoteInit.main ->ActivityThread.main->Looper.loop(进入消息循环）
2. 消息循环中收到系统分发过来的消息，回调 onClick 去启动 Activity
3. 通过 ActivityManagerProxy  RPC 将请求发送给 AMS。

这里面我们多关注一下系统的设计。click 事件是如何发送到 Launcher 进程的？ 应用启动另外一个应用的接口是如何设计的？ app 进程与 系统进程的交互如何设计的？

### 2. SystemServer(AMS)  请求 Launcher Pause
下面的ST是在 **ApplicationThreadProxy** 的 `schedulePauseActivity` 函数打印的调用栈。

    07-29 07:06:11.922  4151  4183 D zhibinw : java.lang.RuntimeException: ApplicationThreadProxy-schedulePauseActivity
    07-29 07:06:11.922  4151  4183 D zhibinw : 	at android.app.ApplicationThreadProxy.schedulePauseActivity(ApplicationThreadNative.java:699)
    07-29 07:06:11.922  4151  4183 D zhibinw : 	at com.android.server.am.ActivityStack.startPausingLocked(ActivityStack.java:842)
    07-29 07:06:11.922  4151  4183 D zhibinw : 	at com.android.server.am.ActivityStackSupervisor.pauseBackStacks(ActivityStackSupervisor.java:680)
    07-29 07:06:11.922  4151  4183 D zhibinw : 	at com.android.server.am.ActivityStack.resumeTopActivityInnerLocked(ActivityStack.java:1638)
    07-29 07:06:11.922  4151  4183 D zhibinw : 	at com.android.server.am.ActivityStack.resumeTopActivityLocked(ActivityStack.java:1477)
    07-29 07:06:11.922  4151  4183 D zhibinw : 	at com.android.server.am.ActivityStackSupervisor.resumeTopActivitiesLocked(ActivityStackSupervisor.java:2520)
    07-29 07:06:11.922  4151  4183 D zhibinw : 	at com.android.server.am.ActivityStack.startActivityLocked(ActivityStack.java:2125)
    07-29 07:06:11.922  4151  4183 D zhibinw : 	at com.android.server.am.ActivityStackSupervisor.startActivityUncheckedLocked(ActivityStackSupervisor.java:2258)
    07-29 07:06:11.922  4151  4183 D zhibinw : 	at com.android.server.am.ActivityStackSupervisor.startActivityLocked(ActivityStackSupervisor.java:1560)
    07-29 07:06:11.922  4151  4183 D zhibinw : 	at com.android.server.am.ActivityStackSupervisor.startActivityMayWait(ActivityStackSupervisor.java:994)
    07-29 07:06:11.922  4151  4183 D zhibinw : 	at com.android.server.am.ActivityManagerService.startActivityAsUser(ActivityManagerService.java:3415)
    07-29 07:06:11.922  4151  4183 D zhibinw : 	at com.android.server.am.ActivityManagerService.startActivity(ActivityManagerService.java:3402)
    07-29 07:06:11.922  4151  4183 D zhibinw : 	at android.app.ActivityManagerNative.onTransact(ActivityManagerNative.java:140)
    07-29 07:06:11.922  4151  4183 D zhibinw : 	at com.android.server.am.ActivityManagerService.onTransact(ActivityManagerService.java:2223)
    07-29 07:06:11.922  4151  4183 D zhibinw : 	at android.os.Binder.execTransact(Binder.java:446)

这个调用栈正好衔接上面的调用栈，上面是从 Launcher 通过 ActivityManagerProxy RPC 到 SystemServer(AMS) , 这里刚好 RPC 切换到 SystemServer（AMS) 进程。通过一系列调用 SystemServer(AMS)进程向 Launcher 发送 pause 的请求，同样是通过 RPC. 这一来一回，涉及到 app 进程和 SystemServer 的交互，涉及到 ActivityManagerNative, ActivityManagerService, ActivityManagerProxy, ApplicationThreadNative, ApplicationThread,ApplicationThreadProxy. 我画了一张图来展示它们的关系， 如下：

![app-ams-communicate](https://raw.githubusercontent.com/androidzhibinw/androidzhibinw.github.io/master/images/android-app-system.png)

通过这个图，我们就能清楚的看出来 ApplicationThreadProxy  schedulePauseActivity RPC 到 Launcher 程序会调用 ApplicationThread 的 schedulePauseActivity：

    public final void schedulePauseActivity(IBinder token, boolean finished,
            boolean userLeaving, int configChanges, boolean dontReport) {
        sendMessage(
                finished ? H.PAUSE_ACTIVITY_FINISHING : H.PAUSE_ACTIVITY,
                token,
                (userLeaving ? 1 : 0) | (dontReport ? 2 : 0),
                configChanges);
    }

这里发送一个 PAUSE_ACTIVITY 的消息来异步处理这个事件。这里有一个问题，为什么这里是异步的？Launcher 向 SystemServer(AMS) RPC 是异步的吗？

    case PAUSE_ACTIVITY:
        Trace.traceBegin(Trace.TRACE_TAG_ACTIVITY_MANAGER, "activityPause");
        handlePauseActivity((IBinder)msg.obj, false, (msg.arg1&1) != 0, msg.arg2,
                (msg.arg1&2) != 0);
        maybeSnapshot();
        Trace.traceEnd(Trace.TRACE_TAG_ACTIVITY_MANAGER);
        break;

然后我们在 onPause 里面打印StackTrace 就看到了紧接着下面的调用：

    07-29 07:06:12.019  6231  6231 D zhibinw : 	at com.android.launcher3.Launcher.onPause(Launcher.java:1237)
    07-29 07:06:12.019  6231  6231 D zhibinw : 	at android.app.Activity.performPause(Activity.java:6144)
    07-29 07:06:12.019  6231  6231 D zhibinw : 	at android.app.Instrumentation.callActivityOnPause(Instrumentation.java:1310)
    07-29 07:06:12.019  6231  6231 D zhibinw : 	at android.app.ActivityThread.performPauseActivity(ActivityThread.java:3248)
    07-29 07:06:12.019  6231  6231 D zhibinw : 	at android.app.ActivityThread.performPauseActivity(ActivityThread.java:3221)
    07-29 07:06:12.019  6231  6231 D zhibinw : 	at android.app.ActivityThread.handlePauseActivity(ActivityThread.java:3195)
    07-29 07:06:12.019  6231  6231 D zhibinw : 	at android.app.ActivityThread.access$1000(ActivityThread.java:151)
    07-29 07:06:12.019  6231  6231 D zhibinw : 	at android.app.ActivityThread$H.handleMessage(ActivityThread.java:1314)
    07-29 07:06:12.019  6231  6231 D zhibinw : 	at android.os.Handler.dispatchMessage(Handler.java:102)
    07-29 07:06:12.019  6231  6231 D zhibinw : 	at android.os.Looper.loop(Looper.java:135)
    07-29 07:06:12.019  6231  6231 D zhibinw : 	at android.app.ActivityThread.main(ActivityThread.java:5258)
    07-29 07:06:12.019  6231  6231 D zhibinw : 	at java.lang.reflect.Method.invoke(Native Method)
    07-29 07:06:12.019  6231  6231 D zhibinw : 	at java.lang.reflect.Method.invoke(Method.java:372)
    07-29 07:06:12.019  6231  6231 D zhibinw : 	at com.android.internal.os.ZygoteInit$MethodAndArgsCaller.run(ZygoteInit.java:904)
    07-29 07:06:12.019  6231  6231 D zhibinw : 	at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:699)


Launcher 的 onPause 结束。
### 3.Launcher Pause ， 向 SystemServer(AMS) 发送 Pause 完毕

紧接着，Launcher 会回复 SystemServer(AMS)  ， Pause 完毕：

    07-29 07:06:12.022  6231  6231 D zhibinw : java.lang.RuntimeException: ActivityManagerProxy-activityPaused
    07-29 07:06:12.022  6231  6231 D zhibinw : 	at android.app.ActivityManagerProxy.activityPaused(ActivityManagerNative.java:2920)
    07-29 07:06:12.022  6231  6231 D zhibinw : 	at android.app.ActivityThread.handlePauseActivity(ActivityThread.java:3206)
    07-29 07:06:12.022  6231  6231 D zhibinw : 	at android.app.ActivityThread.access$1000(ActivityThread.java:151)
    07-29 07:06:12.022  6231  6231 D zhibinw : 	at android.app.ActivityThread$H.handleMessage(ActivityThread.java:1314)
    07-29 07:06:12.022  6231  6231 D zhibinw : 	at android.os.Handler.dispatchMessage(Handler.java:102)
    07-29 07:06:12.022  6231  6231 D zhibinw : 	at android.os.Looper.loop(Looper.java:135)

###4. SystemServer(AMS) 向 Zygote 请求启动一个新进程(calculator) 
然后调到了 SystemServer(AMS) 的 activityPaused，接下来 AMS 尝试去启动 calculator 的界面，发现没有，所以向 Zygote 请求创建一个新的进程。Zygote 存在的目的就是去创建新的进程， SystemServer 通过 socket 和 Zygote 进行通讯。那么思考一下 使用 Zygote 这种方式创建新进程是唯一的选择吗？SystemServer 向 Zygote 发请求能不能用 RPC 不用 socket ?

    07-29 07:06:12.077  4151  5830 D zhibinw : 	at android.os.Process.zygoteSendArgsAndGetResult(Process.java:579)
    07-29 07:06:12.077  4151  5830 D zhibinw : 	at android.os.Process.startViaZygote(Process.java:692)
    07-29 07:06:12.077  4151  5830 D zhibinw : 	at android.os.Process.start(Process.java:491)
    07-29 07:06:12.077  4151  5830 D zhibinw : 	at com.android.server.am.ActivityManagerService.startProcessLocked(ActivityManagerService.java:3034)
    07-29 07:06:12.077  4151  5830 D zhibinw : 	at com.android.server.am.ActivityManagerService.startProcessLocked(ActivityManagerService.java:2902)
    07-29 07:06:12.077  4151  5830 D zhibinw : 	at com.android.server.am.ActivityManagerService.startProcessLocked(ActivityManagerService.java:2787)
    07-29 07:06:12.077  4151  5830 D zhibinw : 	at com.android.server.am.ActivityStackSupervisor.startSpecificActivityLocked(ActivityStackSupervisor.java:1337)
    07-29 07:06:12.077  4151  5830 D zhibinw : 	at com.android.server.am.ActivityStack.resumeTopActivityInnerLocked(ActivityStack.java:1926)
    07-29 07:06:12.077  4151  5830 D zhibinw : 	at com.android.server.am.ActivityStack.resumeTopActivityLocked(ActivityStack.java:1477)
    07-29 07:06:12.077  4151  5830 D zhibinw : 	at com.android.server.am.ActivityStackSupervisor.resumeTopActivitiesLocked(ActivityStackSupervisor.java:2520)
    07-29 07:06:12.077  4151  5830 D zhibinw : 	at com.android.server.am.ActivityStack.completePauseLocked(ActivityStack.java:1017)
    07-29 07:06:12.077  4151  5830 D zhibinw : 	at com.android.server.am.ActivityStack.activityPausedLocked(ActivityStack.java:913)
    07-29 07:06:12.077  4151  5830 D zhibinw : 	at com.android.server.am.ActivityManagerService.activityPaused(ActivityManagerService.java:6374)
    07-29 07:06:12.077  4151  5830 D zhibinw : 	at android.app.ActivityManagerNative.onTransact(ActivityManagerNative.java:513)
    07-29 07:06:12.077  4151  5830 D zhibinw : 	at com.android.server.am.ActivityManagerService.onTransact(ActivityManagerService.java:2223)
    07-29 07:06:12.077  4151  5830 D zhibinw : 	at android.os.Binder.execTransact(Binder.java:446)

SystemServer 向 Zygote 发送创建新进程的请求，并获取结果。那么请求消息需要包含哪些信息？结果信息又需要包含哪些呢？从下面可以看到返回的是 pid 和 usingWrapper，考虑下 usingWrapper 是需要的吗？

    private static ProcessStartResult zygoteSendArgsAndGetResult(
            ZygoteState zygoteState, ArrayList<String> args)
            throws ZygoteStartFailedEx {
            ###here write to socket###
            ###read the result ###
            ProcessStartResult result = new ProcessStartResult();
            result.pid = inputStream.readInt();
            result.usingWrapper = inputStream.readBoolean();
            return result;
    }

### 5. Zygote [fork][fork]  出新进程(calculator) , 在新进程中执行 ActivityThread 类的 main 方法

从Zygote 的 main 函数可以看出， Zygote 的作用： 一是 [fork][fork]出 SystemServer , 然后进入循环，读取 socket 来的消息，响应 [fork][fork] 新进程的请求。这里思考一下，是否任何进程都可以向zygote 发socket 请求创建新进程？除了这种方式还有没有其他方式创建新的 java 应用进程？
 
    public static void main(String argv[]) {
            ###get arguments,register socket,preload class###
            if (startSystemServer) {
                startSystemServer(abiList, socketName);
            }
            runSelectLoop(abiList);
    }

Zygote [fork][fork] 出新进程，分别从子进程和父进程返回。

    boolean runOnce() throws ZygoteInit.MethodAndArgsCaller {
            ### handle args ###
            pid = Zygote.forkAndSpecialize(parsedArgs.uid, parsedArgs.gid, parsedArgs.gids,
                    parsedArgs.debugFlags, rlimits, parsedArgs.mountExternal, parsedArgs.seInfo,
                    parsedArgs.niceName, fdsToClose, parsedArgs.instructionSet,
                    parsedArgs.appDataDir);
        try {
            if (pid == 0) {
                // in child
                IoUtils.closeQuietly(serverPipeFd);
                serverPipeFd = null;
                handleChildProc(parsedArgs, descriptors, childPipeFd, newStderr);
                return true;
            } else {
                IoUtils.closeQuietly(childPipeFd);
                childPipeFd = null;
                return handleParentProc(pid, descriptors, serverPipeFd, parsedArgs);
            }
        } finally {
            IoUtils.closeQuietly(childPipeFd);
            IoUtils.closeQuietly(serverPipeFd);
        }
    }

父进程将结果返回给 SystemServer ,然后继续自己的 loop, 而子进程进入新的入口 ActivityThread， 下面是子进程的：

    07-29 07:06:12.104  9272  9272 D zhibinw : ZygoteInit.invokeStaticMain
    07-29 07:06:12.104  9272  9272 D zhibinw : java.lang.RuntimeException: android.app.ActivityThread
    07-29 07:06:12.104  9272  9272 D zhibinw : 	at com.android.internal.os.RuntimeInit.invokeStaticMain(RuntimeInit.java:232)
    07-29 07:06:12.104  9272  9272 D zhibinw : 	at com.android.internal.os.RuntimeInit.applicationInit(RuntimeInit.java:322)
    07-29 07:06:12.104  9272  9272 D zhibinw : 	at com.android.internal.os.RuntimeInit.zygoteInit(RuntimeInit.java:277)
    07-29 07:06:12.104  9272  9272 D zhibinw : 	at com.android.internal.os.ZygoteConnection.handleChildProc(ZygoteConnection.java:911)
    07-29 07:06:12.104  9272  9272 D zhibinw : 	at com.android.internal.os.ZygoteConnection.runOnce(ZygoteConnection.java:267)
    07-29 07:06:12.104  9272  9272 D zhibinw : 	at com.android.internal.os.ZygoteInit.runSelectLoop(ZygoteInit.java:789)
    07-29 07:06:12.104  9272  9272 D zhibinw : 	at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:695)

ActivityThread 是 Application 相关的最重要的一个类了，但是名字起的不好，它叫Thread ,但是不是一个 Thread, 它也不局限在 Activity 上。

ActivityThread 是 app 进程运行的入口和框架，个人觉得，看懂了这个类，就看懂了 Android app 框架的设计。它负责 app 与 system_server 交互，负责 app 侧 activity,service,broadcast,provider 管理。



>This manages the execution of the main thread in an
>application process, scheduling and executing activities,
>broadcasts, and other operations on it as the activity
>manager requests.


### 6. calculator 向 SystemServer(AMS) 请求 attach 到 AMS 

新进程启动后的第一件事就是上报(attach)到 SystemServer（AMS) ，使得 SystemServer（AMS) 可以统一管理调度。

ActivityThread.java main 方法：

    ActivityThread thread = new ActivityThread();
    thread.attach(false);

ActivityThread.java attach  方法:

            final IActivityManager mgr = ActivityManagerNative.getDefault();
            try {
                mgr.attachApplication(mAppThread);
            } catch (RemoteException ex) {
                // Ignore
            }


attach call stack: 

    07-29 07:06:12.107  9272  9272 D zhibinw : ActivityManagerProxy-attachApplication
    07-29 07:06:12.107  9272  9272 D zhibinw : java.lang.RuntimeException: ActivityManagerProxy-attachApplication
    07-29 07:06:12.107  9272  9272 D zhibinw : 	at android.app.ActivityManagerProxy.attachApplication(ActivityManagerNative.java:2874)
    07-29 07:06:12.107  9272  9272 D zhibinw : 	at android.app.ActivityThread.attach(ActivityThread.java:5095)
    07-29 07:06:12.107  9272  9272 D zhibinw : 	at android.app.ActivityThread.main(ActivityThread.java:5247)
    07-29 07:06:12.107  9272  9272 D zhibinw : 	at java.lang.reflect.Method.invoke(Native Method)
    07-29 07:06:12.107  9272  9272 D zhibinw : 	at java.lang.reflect.Method.invoke(Method.java:372)
    07-29 07:06:12.107  9272  9272 D zhibinw : 	at com.android.internal.os.ZygoteInit$MethodAndArgsCaller.run(ZygoteInit.java:904)
    07-29 07:06:12.107  9272  9272 D zhibinw : 	at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:699)

attachApplication call stack:

    07-29 07:06:12.134  4151  6177 D zhibinw : scheduleLaunchActivity
    07-29 07:06:12.134  4151  6177 D zhibinw : java.lang.RuntimeException: ApplicationThreadProxy-scheduleLaunchActivity
    07-29 07:06:12.134  4151  6177 D zhibinw : 	at android.app.ApplicationThreadProxy.scheduleLaunchActivity(ApplicationThreadNative.java:779)
    07-29 07:06:12.134  4151  6177 D zhibinw : 	at com.android.server.am.ActivityStackSupervisor.realStartActivityLocked(ActivityStackSupervisor.java:1226)
    07-29 07:06:12.134  4151  6177 D zhibinw : 	at com.android.server.am.ActivityStackSupervisor.attachApplicationLocked(ActivityStackSupervisor.java:594)
    07-29 07:06:12.134  4151  6177 D zhibinw : 	at com.android.server.am.ActivityManagerService.attachApplicationLocked(ActivityManagerService.java:6084)
    07-29 07:06:12.134  4151  6177 D zhibinw : 	at com.android.server.am.ActivityManagerService.attachApplication(ActivityManagerService.java:6146)
    07-29 07:06:12.134  4151  6177 D zhibinw : 	at android.app.ActivityManagerNative.onTransact(ActivityManagerNative.java:481)
    07-29 07:06:12.134  4151  6177 D zhibinw : 	at com.android.server.am.ActivityManagerService.onTransact(ActivityManagerService.java:2223)
    07-29 07:06:12.134  4151  6177 D zhibinw : 	at android.os.Binder.execTransact(Binder.java:446)

### 7. SystemServer(AMS) 请求 calculator launch

SystemServer(AMS) 调用 scheduleLaunchActivity 通过IPC 传递到 ActivityThread 的 scheduleLaunchActivity，在 ActivityThread 里面它用 Message 的方式发送自己主线程的 Handler 来异步处理。这里有个问题了，app 侧的scheduleLaunchActivity 是在哪个线程里执行的？ 实际上 app attach 上AMS 之后的事情都是类似的异步来执行的，为什么这么去设计呢？

下面是 app 侧的 scheduleLaunchActivity:

    // we use token to identify this activity without having to send the
    // activity itself back to the activity manager. (matters more with ipc)
    public final void scheduleLaunchActivity(Intent intent, IBinder token, int ident,
            ActivityInfo info, Configuration curConfig, CompatibilityInfo compatInfo,
            String referrer, IVoiceInteractor voiceInteractor, int procState, Bundle state,
            PersistableBundle persistentState, List<ResultInfo> pendingResults,
            List<ReferrerIntent> pendingNewIntents, boolean notResumed, boolean isForward,
            ProfilerInfo profilerInfo) {
    
        updateProcessState(procState, false);
    
        ActivityClientRecord r = new ActivityClientRecord();
        ###skip some code###
        sendMessage(H.LAUNCH_ACTIVITY, r);
    }

顺便看一下 looper 和 Handler 的创建：

     final ApplicationThread mAppThread = new ApplicationThread();//ApplicationThread 作为 AMS RPC app 的 Server端，AMS端的 proxy 是如何创建的？
     //looper 和 Handler 作为成员变量随着ActivityThread对象的实例化创建的。
     final Looper mLooper = Looper.myLooper();
     final H mH = new H();
     ...
     private class H extends Handler {
      ...
     }

     public static void main(String[] args) {
     Process.setArgV0("<pre-initialized>");
        ###skip some code###
        Looper.prepareMainLooper(); //准备looper 
        ActivityThread thread = new ActivityThread();//创建实例
        thread.attach(false); //attach 到 AMS 
		###skip some code ###
        Looper.loop(); //消息循环
        throw new RuntimeException("Main thread loop unexpectedly exited");
    }

从上面我们可以归纳 ActivityThread 作为app入口框架是怎么做的：1.建立消息队列 2.与AMS建立起关联 3.进入循环等待消息/处理消息。
也就是说，attach AMS 之后，app 主线程里接下来都是在异步的方式处理消息，这样设计是否是唯一的方式？这样设计的依据是什么？


发消息给 H(继承自 Handler) 来处理 => handleLaunchActivity

    public void handleMessage(Message msg) {
              if (DEBUG_MESSAGES) Slog.v(TAG, ">>> handling: " + codeToString(msg.what));
              switch (msg.what) {
                  case LAUNCH_ACTIVITY: {
                      Trace.traceBegin(Trace.TRACE_TAG_ACTIVITY_MANAGER, "activityStart");
                      final ActivityClientRecord r = (ActivityClientRecord) msg.obj;
    
                      r.packageInfo = getPackageInfoNoCheck(
                              r.activityInfo.applicationInfo, r.compatInfo);
                      handleLaunchActivity(r, null);
                      Trace.traceEnd(Trace.TRACE_TAG_ACTIVITY_MANAGER);
                  } break;

在 handleLaunchActivity 里面会通过 performLaunchActivity 和 handleResumeActivity 去callback Activity 的 onCreate 和 onResume

    private void handleLaunchActivity(ActivityClientRecord r, Intent customIntent) {
        // If we are getting ready to gc after going to the background, well
        // we are back active so skip it.
        ###skip some code ###
        // Initialize before creating the activity
        WindowManagerGlobal.initialize();

        Activity a = performLaunchActivity(r, customIntent);
        ###skip some code ###
            handleResumeActivity(r.token, false, r.isForward,
                    !r.activity.mFinished && !r.startsNotResumed);
            ###skip some code ###
        }

### 8. calculator 调用 onCreate ， onResume 回调

Activity 的 onCreate 的 callstack :

    9272  9272 D zhibinw : 	at com.android.calculator2.Calculator.onCreate(Calculator.java:158)
    9272  9272 D zhibinw : 	at android.app.Activity.performCreate(Activity.java:6033)
    9272  9272 D zhibinw : 	at android.app.Instrumentation.callActivityOnCreate(Instrumentation.java:1106)
    9272  9272 D zhibinw : 	at android.app.ActivityThread.performLaunchActivity(ActivityThread.java:2278)
    9272  9272 D zhibinw : 	at android.app.ActivityThread.handleLaunchActivity(ActivityThread.java:2387)
    9272  9272 D zhibinw : 	at android.app.ActivityThread.access$800(ActivityThread.java:151)
    9272  9272 D zhibinw : 	at android.app.ActivityThread$H.handleMessage(ActivityThread.java:1303)
    9272  9272 D zhibinw : 	at android.os.Handler.dispatchMessage(Handler.java:102)
    9272  9272 D zhibinw : 	at android.os.Looper.loop(Looper.java:135)
    9272  9272 D zhibinw : 	at android.app.ActivityThread.main(ActivityThread.java:5258)
    9272  9272 D zhibinw : 	at java.lang.reflect.Method.invoke(Native Method)
    9272  9272 D zhibinw : 	at java.lang.reflect.Method.invoke(Method.java:372)
    9272  9272 D zhibinw : 	at com.android.internal.os.ZygoteInit$MethodAndArgsCaller.run(ZygoteInit.java:904)
    9272  9272 D zhibinw : 	at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:699)

Activity 的 onResume 的 callstack :

    9272  9272 D zhibinw : 	at com.android.calculator2.Calculator.onResume(Calculator.java:260)
    9272  9272 D zhibinw : 	at android.app.Instrumentation.callActivityOnResume(Instrumentation.java:1257)
    9272  9272 D zhibinw : 	at android.app.Activity.performResume(Activity.java:6119)
    9272  9272 D zhibinw : 	at android.app.ActivityThread.performResumeActivity(ActivityThread.java:2975)
    9272  9272 D zhibinw : 	at android.app.ActivityThread.handleResumeActivity(ActivityThread.java:3017)
    9272  9272 D zhibinw : 	at android.app.ActivityThread.handleLaunchActivity(ActivityThread.java:2392)
    9272  9272 D zhibinw : 	at android.app.ActivityThread.access$800(ActivityThread.java:151)
    9272  9272 D zhibinw : 	at android.app.ActivityThread$H.handleMessage(ActivityThread.java:1303)
    9272  9272 D zhibinw : 	at android.os.Handler.dispatchMessage(Handler.java:102)
    9272  9272 D zhibinw : 	at android.os.Looper.loop(Looper.java:135)
    9272  9272 D zhibinw : 	at android.app.ActivityThread.main(ActivityThread.java:5258)
    9272  9272 D zhibinw : 	at java.lang.reflect.Method.invoke(Native Method)
    9272  9272 D zhibinw : 	at java.lang.reflect.Method.invoke(Method.java:372)
    9272  9272 D zhibinw : 	at com.android.internal.os.ZygoteInit$MethodAndArgsCaller.run(ZygoteInit.java:904)
    9272  9272 D zhibinw : 	at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:699)


###9. calculator 界面显示自屏幕上

从 onResume 结束到 界面显示到屏幕上是怎样一个过程呢？在 Android 平台上这部分还是一个比较复杂和漫长的过程，我想再新起一篇文章来总结这个过程。

##总结

通过上面的内容抛砖引玉的概括了 app 启动的过程，但是要说到设计和细节，太多的内容有待挖掘。我是作为一个提问者多过解答着去总结，不局限于是什么，而是努力去发掘为什么，不断思索假设自己是设计者会怎么做，从而去加强理解其本质的能力。

或许下次再看的时候，感觉又会不一样，app 启动的设计，app 生命周期的设计，app与系统交互的设计， app 与其他 app 交互的设计，那些蕴含在代码里又脱离了代码的东西，才是值得我们去学习的东西。

或许有一天，我们也会去设计一套系统。

[1]:http://blog.csdn.net/luoshengyang/article/details/6689748 
[2]:http://book.douban.com/subject/3291901/
[x-req]:http://www.x.org/releases/X11R7.7/doc/xproto/x11protocol.html#Requests
[x-lib]:http://www.x.org/releases/X11R7.7/doc/libX11/libX11/libX11.html#Introduction_to_Xlib
[gtk]:http://www.gtk.org/documentation.php
[qt]:http://www.qt.io/
[activity]:http://developer.android.com/guide/components/activities.html
[u-v-c]:https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIViewController_Class/
[table-a-uvc]:http://mobilityadda.blogspot.com/2012/06/uiviewcontroller-in-ios-vs-activity-in.html
[activity-uvc]:http://stackoverflow.com/questions/6519847/what-is-the-life-cycle-of-an-iphone-application
[fork]:http://linux.die.net/man/2/fork
[android-dev]:http://developer.android.com/guide
[stack-trace]:http://androidxref.com/5.1.1_r6/xref/frameworks/base/services/core/java/com/android/server/am/ActivityManagerService.java#8683
[androidxref]:http://androidxref.com/
