--- 
layout: post 
title: "Python Path and Import"
published: true
date: 2016-03-30
categories: python PYTHONPATH import
---

当使用 python 的 import 另一个文件夹的文件内容的时候，有可能发生 `ImportError`

    ImportError: No module named a.a

例子，文件目录结构如下：

    test-path/
    ├── a
    │   ├── a.py
    │   ├── a.pyc
    │   ├── __init__.py
    │   └── __init__.pyc
    └── b
    ├── b2.py
    ├── b2.pyc
    ├── b.py
    └── __init__.py

a.py 里面： 

    def test_a1():
    print 'a1'

b.py 里面：

    from a.a import test_a1
    from b2 import test_b2

    def test_b1():
        test_a1()
        print "b1"
        test_b2()
    test_b1()

b2.py 里面：

    def test_b2():
        print 'b2'

在 test-path 文件夹下执行 `$ python b/b.py` 的时候就会发生`ImportError` 

    Traceback (most recent call last):
      File "b/b.py", line 5, in <module>
        from a.a import test_a1
    ImportError: No module named a.a

为什么找不到 `a.a` 呢？ 这就要问 python import 的时候会从那些路径上去搜索, [python-module doc][1] 有说明：

>###6.1.2. The Module Search Path
>
>When a module named spam is imported, the interpreter first searches for a built-in module with that name. If not found, it then searches for a file named spam.py in a list of directories given by the variable sys.path. sys.path is initialized from these locations:

> - the directory containing the input script (or the current directory).
> - PYTHONPATH (a list of directory names, with the same syntax as the shell variable PATH).
> - the installation-dependent default.
> 
> After initialization, Python programs can modify sys.path. The directory containing the script being run is placed at the beginning of the search path, ahead of the standard library path. This means that scripts in that directory will be loaded instead of modules of the same name in the library directory. This is an error unless the replacement is intended. See section Standard Modules for more information.


简单来说，python import 的时候会从 `sys.path` 里面去找，`sys.path` 初始值会从三个地方获取：

 1. 执行的 python 脚本的目录(上面例子中b 所在的目录） 
 2. `PYTHONPATH` 这个环境变量
 3. python 安装的路径

由于我的 `PYTHONPATH` 是没设的，所以是空的。那么我们可以打印下 `sys.path` 看看到底包含哪些路径

在 b.py 前面加上：

    import sys
    print sys.path

 再次执行 `python b/b.py` 就会看到 `sys.path` 的打印

    ['/home/myname/github/practice/python/test-path/b', '/usr/lib/python2.7', '/usr/lib/python2.7/plat-linux2', '/usr/lib/python2.7/lib-tk', '/usr/lib/python2.7/lib-old', '/usr/lib/python2.7/lib-dynload', '/usr/local/lib/python2.7/dist-packages', '/usr/lib/python2.7/dist-packages', '/usr/lib/python2.7/dist-packages/PIL', '/usr/lib/python2.7/dist-packages/gst-0.10', '/usr/lib/python2.7/dist-packages/gtk-2.0', '/usr/lib/pymodules/python2.7', '/usr/lib/python2.7/dist-packages/ubuntu-sso-client', '/usr/lib/python2.7/dist-packages/ubuntuone-client', '/usr/lib/python2.7/dist-packages/ubuntuone-control-panel', '/usr/lib/python2.7/dist-packages/ubuntuone-couch', '/usr/lib/python2.7/dist-packages/ubuntuone-installer', '/usr/lib/python2.7/dist-packages/ubuntuone-storage-protocol']

`sys.path` 路径包含了上面 1 和 3 ，b.py 所在的路径和 python 安装的相关路径。

而没有 a 所在的路径，所有在 import a.a 的时候就出错了。

那么如何修改呢？就是想办法让 a 所在的路径加到 `sys.path`

可以修改 `sys.path`

    import sys
    sys.path.append('.')
    print sys.path

也可以修改 `PYTHONPATH`

    export PYTHONPATH=.:${PYTHONPATH}

将 `.` 也就是当前路径加入到 `sys.path` 可以保证 python 在 test-path文件夹里面去执行的时候是没问题的。

要想在任何地方执行都没有问题，可以吧 a 的绝对路径加入到 `sys.path` 里面就可以了。















[1]:https://docs.python.org/2/tutorial/modules.html
