--- 
layout: post 
title: "How Messaging Implement Runtime Permission"
published: true
date: 2016-03-22
categories: android runtime permission messaging
---

## How Messaging Implement Runtime Permission

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




#### Permission group  在哪里定义的? 

[frameworks/base/core/res/AndroidManifest.xml][4]

example:
    <!-- Used for runtime permissions related to user's contacts and profile. -->
    <permission-group android:name="android.permission-group.CONTACTS"
        android:icon="@drawable/perm_group_contacts"
        android:label="@string/permgrouplab_contacts"
        android:description="@string/permgroupdesc_contacts"
        android:priority="100" />

    <!-- Allows an application to read the user's contacts data.
        <p>Protection level: dangerous-->
    <permission android:name="android.permission.READ_CONTACTS"
        android:permissionGroup="android.permission-group.CONTACTS"
        android:label="@string/permlab_readContacts"
        android:description="@string/permdesc_readContacts"
        android:protectionLevel="dangerous" />

    <!-- Allows an application to write the user's contacts data.
         <p>Protection level: dangerous-->
    <permission android:name="android.permission.WRITE_CONTACTS"
        android:permissionGroup="android.permission-group.CONTACTS"
        android:label="@string/permlab_writeContacts"
        android:description="@string/permdesc_writeContacts"
        android:protectionLevel="dangerous" />


#### DefaultPermissionGrantPolicy

前面说到, default SMS Application 系统会自动赋予三个权限组:Contacts,Phone,SMS.这个是在哪里实现的呢?

参看: [DefaultPermissionGrantPolicy.java][5], 具体修改可查:[quicinc_link]

在 [DefaultPermissionGrantPolicy.java][5] 中,先是定义了一些权限组(ps:权限组添加权限怎么能 hard code 呢? ), 和 [frameworks/base/core/res/AndroidManifest.xml][4]定义的是一致的.

    private static final Set<String> PHONE_PERMISSIONS = new ArraySet<>();
    static {
        PHONE_PERMISSIONS.add(Manifest.permission.READ_PHONE_STATE);
        PHONE_PERMISSIONS.add(Manifest.permission.CALL_PHONE);
        PHONE_PERMISSIONS.add(Manifest.permission.READ_CALL_LOG);
        PHONE_PERMISSIONS.add(Manifest.permission.WRITE_CALL_LOG);
        PHONE_PERMISSIONS.add(Manifest.permission.ADD_VOICEMAIL);
        PHONE_PERMISSIONS.add(Manifest.permission.USE_SIP);
        PHONE_PERMISSIONS.add(Manifest.permission.PROCESS_OUTGOING_CALLS);
    }

    private static final Set<String> CONTACTS_PERMISSIONS = new ArraySet<>();
    static {
        CONTACTS_PERMISSIONS.add(Manifest.permission.READ_CONTACTS);
        CONTACTS_PERMISSIONS.add(Manifest.permission.WRITE_CONTACTS);
        CONTACTS_PERMISSIONS.add(Manifest.permission.GET_ACCOUNTS);
    }

    private static final Set<String> LOCATION_PERMISSIONS = new ArraySet<>();
    static {
        LOCATION_PERMISSIONS.add(Manifest.permission.ACCESS_FINE_LOCATION);
        LOCATION_PERMISSIONS.add(Manifest.permission.ACCESS_COARSE_LOCATION);
    }

    private static final Set<String> CALENDAR_PERMISSIONS = new ArraySet<>();
    static {
        CALENDAR_PERMISSIONS.add(Manifest.permission.READ_CALENDAR);
        CALENDAR_PERMISSIONS.add(Manifest.permission.WRITE_CALENDAR);
    }

    private static final Set<String> SMS_PERMISSIONS = new ArraySet<>();
    static {
        SMS_PERMISSIONS.add(Manifest.permission.SEND_SMS);
        SMS_PERMISSIONS.add(Manifest.permission.RECEIVE_SMS);
        SMS_PERMISSIONS.add(Manifest.permission.READ_SMS);
        SMS_PERMISSIONS.add(Manifest.permission.RECEIVE_WAP_PUSH);
        SMS_PERMISSIONS.add(Manifest.permission.RECEIVE_MMS);
        SMS_PERMISSIONS.add(Manifest.permission.READ_CELL_BROADCASTS);
    }

在 [grantDefaultSystemHandlerPermissions][6] 里面, 会赋予 Default handler 相应的权限,如 SMS 和 Contacts:


            // SMS
            if (smsAppPackageNames == null) {
                Intent smsIntent = new Intent(Intent.ACTION_MAIN);
                smsIntent.addCategory(Intent.CATEGORY_APP_MESSAGING);
                PackageParser.Package smsPackage = getDefaultSystemHandlerActivityPackageLPr(
                        smsIntent, userId);
                if (smsPackage != null) {
                   grantDefaultPermissionsToDefaultSystemSmsAppLPr(smsPackage, userId);
                }

            // Contacts
            Intent contactsIntent = new Intent(Intent.ACTION_MAIN);
            contactsIntent.addCategory(Intent.CATEGORY_APP_CONTACTS);
            PackageParser.Package contactsPackage = getDefaultSystemHandlerActivityPackageLPr(
                    contactsIntent, userId);
            if (contactsPackage != null
                    && doesPackageSupportRuntimePermissions(contactsPackage)) {
                grantRuntimePermissionsLPw(contactsPackage, CONTACTS_PERMISSIONS, userId);
                grantRuntimePermissionsLPw(contactsPackage, PHONE_PERMISSIONS, userId);
            }


在 [grantDefaultPermissionsToDefaultSystemSmsAppLPr][7] 里面,三个基本权限组 Phone,Contacts 和 SMS 自动赋予 default SMS  application.

    private void grantDefaultPermissionsToDefaultSystemSmsAppLPr(
            PackageParser.Package smsPackage, int userId) {
        if (doesPackageSupportRuntimePermissions(smsPackage)) {
            grantRuntimePermissionsLPw(smsPackage, PHONE_PERMISSIONS, userId);
            grantRuntimePermissionsLPw(smsPackage, CONTACTS_PERMISSIONS, userId);
            grantRuntimePermissionsLPw(smsPackage, SMS_PERMISSIONS, userId);
        }
    }


### Messaging 如何实现 Runtime permission 支持

实现 Runtime permission 可以有几种方式/级别,一种是完全动态,所有的都是在运行时去检查,不需要用户提前授权.第二种是进入之前获取授权,在进入应用之前检查所需要的所有权限,如果没有全部授权则不能进入.

这两种方式是两种极端,各有利弊.第一种的弊端是,应用的基本功能都需要动态申请,可以想象 Messaging 这样的应用,如果读写SMS都要动态申请权限的话,代码里肯定满满的都是 request permission,异步接受到用户返回结果之后再继续处理,极大的增加了复杂性.第二种的弊端是,用户的进入成本变到最大,和 Android 6.0 之前的 permission control 没有太多区别.用户若不满意一些权限,可能会放弃安装.

Messaging 采用了一种折中的方式,基本功能权限在进入之前申请授权,非基本功能需要的权限根据情况动态去申请.这个基本功能权限和 Android 系统里面 DefaultPermissionGrantPolicy 是相一致的. DefaultPermissionGrantPolicy 定义了 SMS default application 会自动授权 phone,contacts,SMS 三个权限组, 也是为了保证基本功能相关的权限不用在代码里动态申请,降低复杂度.

系统自动授权之后,用户还是可以去改变权限的,所以,需要应用自己在进入是检查基本权限是否得到授权,并作出相应处理.


1.[Messaing][1] 需要在进入之前检查三个 SMS 基本权限是否得到授权,如果没有则显示需要授权的界面.

在 [Messaing][1] 里面,所有 Activity 的入口都要调用 [redirectToPermissionCheckIfNeeded][8] 检查是否取得基本权限,如果没有则跳转到  [PermissionCheckActivity.java][9], 在这个 Activity 里面会请求三个基本权限组,处理得到授权和得不到授权的情况: 

- 得到授权,[redirect][10] 到应用主入口  [ConversationListActivity][11].
- 如果没有得到授权,调用 [tryRequestPermission]:[12] 提示用户授权.直到用户授权(同上),或者选择 Don't ask again.如果未得到用户授权并且用户勾选了 Don't ask again. 在点击 Next 会直接返回失败,用户不会受到提示.这种情况下,Messaing 会显示需要到Settings->Apps->Messaing->Permission 去给予授权,同时 Next button 变成了Settings button,点击它会跳转到 Settings->Apps->Messaing->Permission


2. Activity 的入口都要调用 [redirectToPermissionCheckIfNeeded][8] 检查授权,那么在哪里 onCreate  or onResume 呢? [Messaing][1] 是在几个基类的 onCreate 去检查的,其他 Activity 继承它们.


    public class BaseBugleActivity extends Activity {
    @Override
    protected void onCreate(final Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (UiUtils.redirectToPermissionCheckIfNeeded(this)) {
            return;
        }
    }

这样不会有问题吗? 有些用户通过,statusbar 或其他方式在不 Destroy Activity 的情况下去修改权限,然后回到原来的  Activity, 那么 Activity 在缺失某些权限的情况下还可以继续吗?

这的确是个问题,不过 Android 在从系统层面解决了这个问题. 如果应用在运行的时候权限被回收了,那么系统会 kill 它,下一次重新启动,这样能保证之前的状态不会因为权限突然变化产生的异常.

看如下log:

    03-23 15:08:20.122  2197  4415 I ActivityManager: Killing 8050:com.android.messaging/u0a112 (adj 9): **permissions revoked**
    03-23 15:08:20.314  2197  4431 W ActivityManager: Spurious death for ProcessRecord{7c20ad3 0:com.android.messaging/u0a112}, curProc for 8050: null
    03-23 15:08:25.175  2197  3867 I ActivityManager: Start proc 8216:com.android.messaging/u0a112 for activity com.android.messaging/.ui.conversation.ConversationActivity


[1]:http://androidxref.com/6.0.1_r10/xref/packages/apps/Messaging/
[2]:https://androidzhibinw.github.io/android/runtime/permission/2016/03/21/android-runtime-permission/
[3]:http://developer.android.com/training/permissions/requesting.html
[4]:http://androidxref.com/6.0.1_r10/xref/frameworks/base/core/res/AndroidManifest.xml
[5]:http://androidxref.com/6.0.1_r10/xref/frameworks/base/services/core/java/com/android/server/pm/DefaultPermissionGrantPolicy.java
[6]:http://androidxref.com/6.0.1_r10/xref/frameworks/base/services/core/java/com/android/server/pm/DefaultPermissionGrantPolicy.java#grantDefaultSystemHandlerPermissions
[7]:http://androidxref.com/6.0.1_r10/xref/frameworks/base/services/core/java/com/android/server/pm/DefaultPermissionGrantPolicy.java#grantDefaultPermissionsToDefaultSystemSmsAppLPr
[quicinc_link]:https://git.quicinc.com/?p=platform/frameworks/base.git;a=commitdiff;h=adc1cf46045ae756d3a9ccbccf6b0f894e4c1edd
[8]:http://androidxref.com/6.0.1_r10/xref/packages/apps/Messaging/src/com/android/messaging/util/UiUtils.java#311
[9]:http://androidxref.com/6.0.1_r10/xref/packages/apps/Messaging/src/com/android/messaging/ui/PermissionCheckActivity.java
[10]:http://androidxref.com/6.0.1_r10/xref/packages/apps/Messaging/src/com/android/messaging/ui/PermissionCheckActivity.java#redirect
[11]:http://androidxref.com/6.0.1_r10/xref/packages/apps/Messaging/src/com/android/messaging/ui/conversationlist/ConversationListActivity.java
[12]:http://androidxref.com/6.0.1_r10/xref/packages/apps/Messaging/src/com/android/messaging/ui/PermissionCheckActivity.java#92