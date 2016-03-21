--- 
layout: post 
title: "Android Runtime Permission"
published: true
date: 2016-03-21
categories: android runtime permission
---

Android 运行时 permission 

##运行时 permission

从 Android 6.0 (API level 23) 开始， Android 开始支持 Runtime permission.这种方式是对以前在安装时Grant 给应用程序 permission的改进，在 api 23 以前，Android 应用程序在 AndroidManifest.xml 声明使用了哪些permission, 用户在安装是会看到应用使用了那些 permission.  如下：

    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="android.permission.CALL_PHONE" />
    <uses-permission android:name="android.permission.READ_CONTACTS" />
    <uses-permission android:name="android.permission.WRITE_CONTACTS" />
    <uses-permission android:name="android.permission.READ_PROFILE" />
    <uses-permission android:name="android.permission.RECEIVE_SMS" />
    <uses-permission android:name="android.permission.RECEIVE_MMS" />
    <uses-permission android:name="android.permission.SEND_SMS" />
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.READ_SMS"/>
    <uses-permission android:name="android.permission.WRITE_SMS"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />
    <uses-permission android:name="android.permission.READ_PHONE_STATE" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.WRITE_APN_SETTINGS" />


这种设计给用户的选择是，要么安装给予所有权限，要么放弃安装。 这种设计给用户带来一定的困扰。你要使用一个应用前提是必须给予它所有它想要的权限，即使你知道它是不合理的。 比如 微信，下面是微信使用的近60个permission.

    uses-permission:'android.permission.access_network_state'
    uses-permission:'android.permission.access_coarse_location'
    uses-permission:'android.permission.access_fine_location'
    uses-permission:'android.permission.camera'
    uses-permission:'android.permission.get_tasks'
    uses-permission:'android.permission.internet'
    uses-permission:'android.permission.modify_audio_settings'
    uses-permission:'android.permission.receive_boot_completed'
    uses-permission:'android.permission.record_audio'
    uses-permission:'android.permission.read_contacts'
    uses-permission:'android.permission.read_sms'
    uses-permission:'android.permission.vibrate'
    uses-permission:'android.permission.wake_lock'
    uses-permission:'android.permission.write_external_storage'
    uses-permission:'android.permission.write_contacts'
    uses-permission:'android.permission.write_settings'
    uses-permission:'com.android.launcher.permission.install_shortcut'
    uses-permission:'com.android.launcher.permission.uninstall_shortcut'
    uses-permission:'com.android.launcher.permission.read_settings'
    uses-permission:'com.tencent.mm.location.permission.send_view'
    uses-permission:'android.permission.bluetooth'
    uses-permission:'android.permission.bluetooth_admin'
    uses-permission:'android.permission.broadcast_sticky'
    uses-permission:'android.permission.system_alert_window'
    uses-permission:'android.permission.change_wifi_state'
    uses-permission:'android.permission.get_package_size'
    uses-permission:'android.permission.download_without_notification'
    uses-permission:'android.permission.nfc'
    uses-permission:'com.huawei.android.launcher.permission.change_badge'
    uses-permission:'android.permission.write_app_badge'
    uses-permission:'com.tencent.mm.ext.permission.READ'
    uses-permission:'com.tencent.mm.ext.permission.WRITE'
    uses-permission:'android.permission.USE_FINGERPRINT'
    uses-permission:'android.permission.GET_ACCOUNTS'
    uses-permission:'android.permission.MANAGE_ACCOUNTS'
    uses-permission:'android.permission.AUTHENTICATE_ACCOUNTS'
    uses-permission:'android.permission.READ_SYNC_SETTINGS'
    uses-permission:'android.permission.WRITE_SYNC_SETTINGS'
    uses-permission:'android.permission.READ_PROFILE'
    uses-permission:'android.permission.NFC'
    uses-permission:'com.google.android.c2dm.permission.RECEIVE'
    uses-permission:'android.permission.GET_ACCOUNTS'
    uses-permission:'com.tencent.mm.permission.C2D_MESSAGE'
    uses-permission:'com.android.alarm.permission.SET_ALARM'
    uses-permission:'com.tencent.mm.wear.message'
    uses-permission:'android.permission.BODY_SENSORS'
    uses-permission:'android.permission.WRITE_EXTERNAL_STORAGE'
    uses-permission:'android.permission.CAMERA'
    uses-permission:'android.permission.CAMERA'
    uses-feature-not-required:'android.hardware.camera'
    uses-feature-not-required:'android.hardware.camera.autofocus'
    uses-permission:'android.permission.USE_CREDENTIALS'
    uses-permission:'android.permission.NFC'
    uses-permission:'android.permission.ACCESS_WIFI_STATE'
    uses-permission:'android.permission.READ_PHONE_STATE'
    uses-permission:'android.permission.ACCESS_NETWORK_STATE'
    uses-permission:'android.permission.READ_EXTERNAL_STORAGE'
    uses-implied-permission:'android.permission.READ_EXTERNAL_STORAGE','requested WRITE_EXTERNAL_STORAGE'

要么不用，要么接受即使不合理的权限申请。为了解决这个问题，在 Android 6.0 (API level 23), 引入了 Runtime permission. 这种新的机制改变了原来在安装时给予权限的方式，允许用户任何时候改变赋予应用的权限。 在 Settings->Apps->选择要查看的app，在 Permissions 可以更改。如图：

![we-chat-permission](https://raw.githubusercontent.com/androidzhibinw/androidzhibinw.github.io/master/images/2016-03-21/wechat-android-permission.png)
![we-chat-permission2](https://raw.githubusercontent.com/androidzhibinw/androidzhibinw.github.io/master/images/2016-03-21/android-wechat-permission2.png)


新的这种方式给了用户更多的控制权，使得用户在更小的粒度上控制应用使用的权限，用户可以拒绝应用不合理的权限，而不影响基本功能。

这种新的设计不仅影响了用户，也使得应用开发者必须调整代码，适应这种新的权限控制方式。


##[Android Requesting Permissions at Run Time 官方说明][1] 

系统permission 分成两类，normal 和 dangerous。

-  Normal permissions 不涉及用户隐私，和以前一样，开发者只需在AndroidManifest.xml 声明，安装时系统自动授权。
- Dangerous permissions 设计用户隐私，系统不会自动授权，用户需要主动授权。

> System permissions are divided into two categories, normal and dangerous:

> - Normal permissions do not directly risk the user's privacy. If your app lists a normal permission in its manifest, the system grants the permission automatically.
> - Dangerous permissions can give the app access to the user's confidential data. If your app lists a normal permission in its manifest, the system grants the permission automatically. If you list a dangerous permission, the user has to explicitly give approval to your app.

Normal permission 如下：

    ACCESS_LOCATION_EXTRA_COMMANDS
    ACCESS_NETWORK_STATE
    ACCESS_NOTIFICATION_POLICY
    ACCESS_WIFI_STATE
    BLUETOOTH
    BLUETOOTH_ADMIN
    BROADCAST_STICKY
    CHANGE_NETWORK_STATE
    CHANGE_WIFI_MULTICAST_STATE
    CHANGE_WIFI_STATE
    DISABLE_KEYGUARD
    EXPAND_STATUS_BAR
    GET_PACKAGE_SIZE
    INSTALL_SHORTCUT
    INTERNET
    KILL_BACKGROUND_PROCESSES
    MODIFY_AUDIO_SETTINGS
    NFC
    READ_SYNC_SETTINGS
    READ_SYNC_STATS
    RECEIVE_BOOT_COMPLETED
    REORDER_TASKS
    REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
    REQUEST_INSTALL_PACKAGES
    SET_ALARM
    SET_TIME_ZONE
    SET_WALLPAPER
    SET_WALLPAPER_HINTS
    TRANSMIT_IR
    UNINSTALL_SHORTCUT
    USE_FINGERPRINT
    VIBRATE
    WAKE_LOCK
    WRITE_SYNC_SETTINGS

Dangerous Permission：

在  Android 6.0 (API level 23) ，Android 将 dangerous permissions 分成了几个 permission groups.
如下：

如果应用程序的 targetSdkVersion >=23 , 则会有如下的行为。

- 如果应用请求一个 dangerous permission A，而且应用目前没有得到任何和A在相同 permission group PG的 permission，那么系统会显示一个对话框，对话框会显示应用尝试获取的 permission group PG，但是不会显示应用请求的特定的 permission A。 比如，一个应用请求 READ_CONTACTS， 系统会显示一个对话框说，应用需要访问 CONTACTS.

- 如果应用请求一个 dangerous permission A ， 而应用已经得到一个另一个dangerous permission B 和 A 属于同一个 permission group,那么系统会立即 给予应用 permission B 而不会再给用户提示。 比如应用已经得到 READ_CONTACTS permission, 应用再请求 WRITE_CONTACTS, 系统会立即给予，不再提示。

>All dangerous Android system permissions belong to permission groups. If the device is running Android 6.0 (API level 23) and the app's targetSdkVersion is 23 or higher, the following system behavior applies when your app requests a dangerous permission:

>- If an app requests a dangerous permission listed in its manifest, and the app does not currently have any permissions in the permission group, the system shows a dialog box to the user describing the permission group that the app wants access to. The dialog box does not describe the specific permission within that group. For example, if an app requests the READ_CONTACTS permission, the system dialog box just says the app needs access to the device's contacts. If the user grants approval, the system gives the app just the permission it requested.
>- If an app requests a dangerous permission listed in its manifest, and the app already has another dangerous permission in the same permission group, the system immediately grants the permission without any interaction with the user. For example, if an app had previously requested and been granted the READ_CONTACTS permission, and it then requests WRITE_CONTACTS, the system immediately grants that permission.


在 Settings 里面，用户对 permission 的改变也是以 permission group 为粒度的。用户可以 enable/disable 一个 permission group， 而不是里面每一个 permissions.


对于开发者而言： 无论是 Android 6.0 还是 旧版本，使用的 permission 必须在 AndroidManifest.xml 声明。但是，系统会对 Android 6.0 （API 23+ ) 和  (API 22-) 表现出不同的行为。

- 如果 device 运行在 Android 5.1 or lower, 或者 app 的 targetSDKVersion <=22 ,跟以前的行为一样，开发者需要在 AndroidManifest.xml 声明所需要权限， 用户在安装时授权并安装，或者拒绝授权，放弃安装。
- 如果 device 运行在 Android 6.- + , 而且， app 的 targetSDKVersion >=23, 开发者需要在 AndroidManifest.xml 声明所需要权限， 并且在 app 运行时请求所需要的 dangerous permission，用户可以授权或者拒绝任何一个 permission, 即使用户拒绝了某个 permission, app 需要继续没有得到授权时的行为。

注意：从 Android 6.0 （API 23+) 开始，即使应用 targetSDKVersion <=22， 用户仍然可以任何时间去 Settings 里面 disable 相应的 permissions. 应用开发者应该妥善考虑这种场景，确保应用能在缺少 permission 的情况下正常运行。

>On all versions of Android, your app needs to declare both the normal and the dangerous permissions it needs in its app manifest, as described in Declaring Permissions. However, the effect of that declaration is different depending on the system version and your app's target SDK level:

> - If the device is running Android 5.1 or lower, or your app's target SDK is 22 or lower: If you list a dangerous permission in your manifest, the user has to grant the permission when they install the app; if they do not grant the permission, the system does not install the app at all.
> - If the device is running Android 6.0 or higher, and your app's target SDK is 23 or higher: The app has to list the permissions in the manifest, and it must request each dangerous permission it needs while the app is running. The user can grant or deny each permission, and the app can continue to run with limited capabilities even if the user denies a permission request.
> 
>- **Note**: Beginning with Android 6.0 (API level 23), users can revoke permissions from any app at any time, even if the app targets a lower API level. You should test your app to verify that it behaves properly when it's missing a needed permission, regardless of what API level your app targets.


### Android 6.0 related API for permission 

Android 6.0 提供了一些 api 来完成 runtime permission.

#### Permission 检查

如果应用执行需要 dangerous permission 的操作，必须每次检查 dangerous permission 是否已经得到授权，因为用户随时都可能 disable dangerous permission。

ContextCompat.checkSelfPermission() (android-support-v4）可以检查应用是否已经取得某个　permission.如果应用取得授权，api 会返回　PackageManager.PERMISSION_GRANTED　，　否则返回　PERMISSION_DENIED。 如果PERMISSION_DENIED，应用需要动态请求用户授权这个permission.


     int permissionCheck = ContextCompat.checkSelfPermission(thisActivity,
        Manifest.permission.WRITE_CALENDAR);


#### 动态请求授权 

如果应用需要一个 dangerours permission (AndroidManifest.xml 里声明)，需要请求用户授权这个 permission. Android 系统提供了一些 api 来完成这个请求，当调用 api 的时候，会弹出一个 Dialog 是不是授权应用使用这个 permission. 用户可以选择 允许，拒绝，拒绝时可以勾选不再提示。 如下图：


![permission-ask](https://raw.githubusercontent.com/androidzhibinw/androidzhibinw.github.io/master/images/2016-03-21/permission-dialog.png)
![permission-ask2](https://raw.githubusercontent.com/androidzhibinw/androidzhibinw.github.io/master/images/2016-03-21/permission-dialog-n-ask-again.png)

有一种场景也需要考虑，当应用去请求一个 dangerous permission的时候，如果用户之前拒绝过这个权限，应用可能想要了解这种情况并给予用户一定的解释。 Android 提供了 **shouldShowRequestPermissionRationale()** 这个 api. 
这个 api 会返回 True , 如果 app 请求过这个权限并且被用户拒绝了。 

**Note:** 如果用户拒绝了并勾选了 Don't ask again , **shouldShowRequestPermissionRationale（）** 会返回 False, 如果 device policy 不允许 app 使用这个 permission, 也会返回 False.


应用可以使用 **requestPermissions()** 这个 api 来请求一个应用还未得到授权的 dangerous permission. **requestPermissions** 这个 api , 有三个参数，第一个是 target activity, 第二个是 需要请求的 permissions, 第三个是 requestCode。 这个 api 会异步的处理，api 会立即返回，等到用户对弹出的 permission Dialog 点了允许或拒绝之后，系统会带请求结果和requestCode  回调 app 的回调方法。

    public static void requestPermissions (Activity activity, String[] permissions, int requestCode)

demo code:

    // Here, thisActivity is the current activity
    if (ContextCompat.checkSelfPermission(thisActivity,
                    Manifest.permission.READ_CONTACTS)
            != PackageManager.PERMISSION_GRANTED) {

        // Should we show an explanation?
        if (ActivityCompat.shouldShowRequestPermissionRationale(thisActivity,
                Manifest.permission.READ_CONTACTS)) {

            // Show an expanation to the user *asynchronously* -- don't block
            // this thread waiting for the user's response! After the user
            // sees the explanation, try again to request the permission.

        } else {

            // No explanation needed, we can request the permission.

            ActivityCompat.requestPermissions(thisActivity,
                    new String[]{Manifest.permission.READ_CONTACTS},
                    MY_PERMISSIONS_REQUEST_READ_CONTACTS);

            // MY_PERMISSIONS_REQUEST_READ_CONTACTS is an
            // app-defined int constant. The callback method gets the
            // result of the request.
        }
    }

当 app 请求 permission 之后，系统显示 permission dialog 给用户，用户选择(允许/拒绝)之后，系统会回调 app的 **onRequestPermissionsResult()** 方法，带有用户选择的结果和请求时的requestCode。

demo code:

    @Override
    public void onRequestPermissionsResult(int requestCode,
            String permissions[], int[] grantResults) {
        switch (requestCode) {
            case MY_PERMISSIONS_REQUEST_READ_CONTACTS: {
                // If request is cancelled, the result arrays are empty.
                if (grantResults.length > 0
                    && grantResults[0] == PackageManager.PERMISSION_GRANTED) {

                    // permission was granted, yay! Do the
                    // contacts-related task you need to do.

                } else {

                    // permission denied, boo! Disable the
                    // functionality that depends on this permission.
                }
                return;
            }

            // other 'case' lines to check for other
            // permissions this app might request
        }
    }

用户在处理 permission dialog 的时候，可以选择拒绝的同时，勾选 Don't ask again. 在这种情况下，app 使用requestPermissions() ，系统会直接拒绝（不会再提示用户), 并回调 onRequestPermissionsResult()， 结果为 PERMISSION_DENIED。


Wechat 已经支持 targetSDKVersion 23, 启动时会有如下效果:

如果一些权限没有得到，wechat 会退出，除非用户在 Settings 里启用他们。

![wechat-ask1](https://raw.githubusercontent.com/androidzhibinw/androidzhibinw.github.io/master/images/2016-03-21/android-wechat-permssion3.png)
![wechat-ask2](https://raw.githubusercontent.com/androidzhibinw/androidzhibinw.github.io/master/images/2016-03-21/android-wechat-permission4.png)


[1]:http://developer.android.com/training/permissions/requesting.html
