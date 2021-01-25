--------------------------------------------------

   项目作者：fuyinglong
   
   邮箱：838106527@qq.com
   
   CSDN昵称：你喜欢梅西吗
   
   github主页：https://github.com/CopyDragon

--------------------------------------------------

## 项目名：chat-project-based-on-ubuntu

### 介绍

使用C++实现的ubuntu环境下的聊天小项目，采用C/S架构，支持注册、登录、记录登录状态、私聊、群聊功能，前期使用多线程实现并发服务器，后期利用epoll监听+boost库线程池处理的Reactor模式实现并发服务器，进行了压力测试，并采用bitmap实现的布隆过滤器减少对MySQL的查询。

项目中使用TCP网络编程实现C/S的信息交互，使用Mysql记录用户账号、密码，使用redis记录用户的登录状态，编写了makefile进行编译，使用shell脚本提高了开发效率，开发过程使用git进行版本管理，编写了说明文档。

### 主要功能：
1、用户注册，数据存储到服务器主机的数据库中 
2、用户登录
3、私聊
4、群聊
5、记录用户登录状态，五分钟内重启进程都不需要重新登陆


### 项目环境：
1、ubuntu 20.04.1
2、vi编辑器
3、g++ 
4、Mysql 5.7.31
5、redis 4.0.8
6、boost库1.71版本
7、hiredis库


### 主要技术：
1、C++语言、STL库容器和函数
2、多线程实现并发服务器
3、IO多路复用+线程池实现并发服务器（使用epoll的ET边缘触发、EPOLLONESHOT）
4、使用boost库的线程池实现并发服务器
5、TCP socket网络编程
6、Mysql数据库以及SQL语句
7、redis数据库（HASH数据类型、设置键的过期时间）
8、session、cookie（利用redis保存session对象，服务器随机生成sessionid发往客户端保存到cookie)
9、线程互斥锁
10、makefile编译
11、git版本管理
12、shell脚本测试

### 设计思路：
1、用Mysql记录客户的账号和密码，注册和登录都要经过Mysql
2、使用C/S模型完成私聊和群聊功能，所有的请求和聊天记录都会经过服务器并转发，减轻客户端压力，客户端只维护和服务器的TCP连接
3、利用Redis记录用户登录状态（HASH类型，键为sessionid，值为session对象，键五分钟后过期），当用户成功登录时服务器会利用随机算法生成sessionid发送到客户端保存，客户登录时会优先发送cookie到服务器检查，如果检查通过就不用输入账号密码登录。
4、循序渐进实现了三种服务器：多线程服务器、线程池服务器、IO多路复用+线程池服务器
5、IO多路复用+线程池服务器：采用epoll的边缘触发ET模式，对所有的读事件感兴趣，监听到某个socket上有事件触发时将通知线程池处理，线程池中的工作线程从缓冲区中读出数据并进行业务处理，同时epoll采用EPOLLSHOT模式，防止多个线程在同一socket上处理。

### Redis记录登录状态：
    假设用户xiaoming登录，服务器随机生成的sessionid为1a2b3c4DEF，
    那么会执行如下的redis插入语句：hset 1a2b3c4DEF name xiaoming ，
    然后执行如下语句设置过期时间为300秒：expire 1a2b3c4DEF 300 ，
    服务器将该sessionid发往客户端作为cookie保存，客户端在重新启动进程会将cookie发往服务器，
    服务器收到客户端发来的sessionid后查询，使用如下语句：hget 1a2b3c4DEF name，
    只要该sessionid还未过期，就可以查询到结果，告知客户端登陆成功以及用户名。
    （注：redis查看所有键可用keys *语句）

### 生成sessionid的随机算法：
   sessionid大小为10位，每位由数字、小写字母、大写字母随机组成，理论上有(9+26+26)^10种组合

### 压力测试思路
client.cpp会向服务器发起若干个并发连接，并在这些连接上不断对服务器发出登录请求，每次使用的用户名和密码都是随机从本地的account.txt文件中抽取，客户端每隔1秒钟发动一波攻势。

### bitmap实现的布隆过滤器优化：
服务器启动时，会先根据所有数据来初始化布隆过滤器，当收到登录请求时，会先根据布隆过滤器来判断该用户名是否一定不存在，如果能够判断不存在就不会查询MySQL数据库，减小开销。

### 文件说明：
1、log.txt：git导出的版本日志，记录了版本更新历史
2、test_mysql文件夹：里面的文件用于测试和数据库是否成功建立连接，和项目没有直接联系
3、start_mysql.sh:启动、登录数据库的shell脚本，使用命令sh start_mysql.sh执行
4、makefile：用于编译
5、make_save:makefile的副本
6、global.h、global.cpp：声明全局变量
7、server.cpp：服务器的基础代码
8、HandleServer.h、HandleServer.cpp：服务器的线程函数代码
9、client.cpp：客户端的基础代码
10、HandleClient.h、HandleClient.cpp：客户端的线程函数代码
11、make_and_run.sh：编译运行的shell脚本
12、cookie.txt：把程序跑起来才会在客户端产生的文件，保存sessionid
13、test_thread_pool文件夹：里面的文件用于测试boost库的线程池使用
14、start_redis.sh：快速启动redis服务的shell脚本，使用命令source start_redis.sh执行
15、serverUseThreadPool.cpp：利用线程池实现的服务器的基本代码
16、HandleServerUseThreadPool.cpp：线程池实现的服务器调用的线程函数代码
17、server：可执行文件，多线程服务器
18、serverUseThreadPool：可执行文件，线程池服务器
19、client：可执行文件，客户端
20、serverV2.cpp：IO多路复用+线程池实现的并发服务器2.0
21、HandleServerV2.cpp：serverV2使用线程池调用该函数处理事件
22、HandleServerV2.h：文件21的头文件
23、serverV2：可执行文件，IO多路复用+线程池实现的服务器
24、stress_test文件夹：里面的文件用于压力测试，具体的说明可见文件夹中的aboutStressTest.md文件
25、asio文件夹：包含boost库的asio库源代码，可以看该源代码来了解线程池实现

### 特别注意：
server、serverUseThreadPool、serverV2都是服务器，只运行其中一个即可，
server是普通的多线程服务器，serverUseThreadPool是用线程池实现的服务器，serverV2是IO多路复用+线程池实现的服务器

### 运行环境说明：
1、基于ubuntu系统
2、装有g++编译器及相关组件
3、服务器安装了mysql（安装教程：https://blog.csdn.net/weixin_44164489/article/details/108926885）
4、服务器安装了redis（安装教程：https://blog.csdn.net/weixin_44164489/article/details/109015099)
5、安装了boost库1.71版本
6、安装了hiredis库（安装教程：https://blog.csdn.net/weixin_44164489/article/details/110876479)

### 使用说明：
1、首先在mysql控制台创建一个数据库叫test_connect，再创一个表叫user，表有两项VARCHAR类型属性：NAME和PASSWORD，将NAME设为主键
2、然后修改server和serverUseThreadPool.cpp代码中的ip地址，更改为自己的服务器ip地址
3、启动Mysql、redis服务
4、执行make_and_run脚本得到可执行文件client、server、serverUseThreadPool、serverV2
5、用一个终端先运行server或者serverUseThreadPool或者serverV2
6、再开另外一个或多个终端运行client

### 备注
1、数据库的名字和表的名字可以通过修改代码来自由决定
2、服务器ip地址可自行修改

