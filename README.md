# iOSIM

即时通讯


### 快捷目录

> #### ▌ 网络理论
* [网络编程理论经典《TCP/IP详解》（在线阅读版）](http://www.52im.net/topic-tcpipvol1.html) :triangular_flag_on_post:

> #### ▌ 相关资料
* [MobileIMSDK版本更新日志](http://www.52im.net/thread-1270-1-1.html)
* [MobileIMSDK常见问题解答](http://www.52im.net/thread-60-1-1.html) :point_left:
* [MobileIMSDK性能测试报告](http://www.52im.net/thread-57-1-1.html)
* [客户端Demo安装和使用帮助(Android)](http://www.52im.net/thread-55-1-1.html)
* [客户端Demo安装和使用帮助(iOS)](http://www.52im.net/thread-54-1-1.html)
* [客户端Demo安装和使用帮助(Java)](http://www.52im.net/thread-56-1-1.html)
* [服务端Demo安装和使用帮助](http://www.52im.net/thread-1272-1-1.html) :new:
* [应用案例RainbowChat体验版](http://www.52im.net/thread-19-1-1.html) :point_left:
* [应用案例RainbowChat体验版截图预览](http://www.52im.net/thread-20-1-1.html)
* [应用案例某Chat的部分非敏感运营数据](http://www.52im.net/thread-21-1-1.html)

> #### ▌ 开发文档
* [客户端开发指南(Android)](http://www.52im.net/thread-61-1-1.html)
* [客户端开发指南(iOS)](http://www.52im.net/thread-62-1-1.html)
* [客户端开发指南(Java)](http://www.52im.net/thread-59-1-1.html)
* [服务端开发指南](http://www.52im.net/thread-63-1-1.html)
* [客户端SDK API文档(Android)](http://docs.52im.net/extend/docs/api/mobileimsdk/android/)
* [客户端SDK API文档(iOS)](http://docs.52im.net/extend/docs/api/mobileimsdk/ios/)
* [客户端SDK API文档(Java)](http://docs.52im.net/extend/docs/api/mobileimsdk/java/)
* [服务端SDK API文档(基于Mina框架)](http://docs.52im.net/extend/docs/api/mobileimsdk/server/)
* [服务端SDK API文档(基于Netty框架)](http://docs.52im.net/extend/docs/api/mobileimsdk/server_netty/)

> #### ▌ 资源下载
* [MobileIMSDK最新版打包下载](https://github.com/JackJiang2011/MobileIMSDK/releases/latest) :point_left:
* [MobileIMSDK的Github地址](https://github.com/JackJiang2011/MobileIMSDK)

![](https://raw.githubusercontent.com/JackJiang2011/MobileIMSDK/master/preview/more_screenshots/others/github_header_logo_h.png)


[MobileIMSDK](https://github.com/JackJiang2011/MobileIMSDK)


[QQVoiceDemo](https://github.com/ChavezChen/QQVoiceDemo)


## Socket

* 同一时刻，一个端口只能建立一个连接。
* 监听的同时生成一个等待队列，用来存储客户端的连接请求；
* 一个端口可以监听多个请求。

## OSI 七层数据模型

[百度百科](https://baike.baidu.com/item/%E4%B8%83%E5%B1%82%E6%A8%A1%E5%9E%8B)
[OSI七层模型详解](https://blog.csdn.net/qq_35885488/article/details/88051602)

![](http://dzliving.com/OSI.png)


## TCP

应用层把数据传给传输层，传输层有一个缓冲区，因为网络的原因，导致数据不能及时的发送出去，导致粘包的发生。

![](http://dzliving.com/iOSIM_1.png)

一般通过自定义数据格式的方式解决。

![](http://dzliving.com/iOSIM_0.png)


[链路层常见报文格式及长度](http://blog.chinaunix.net/uid-20530497-id-2878069.html)

![](https://images2015.cnblogs.com/blog/517519/201609/517519-20160907232758160-1699770171.png)

>MTU：最大传输单元，限制了传递数据的大小
>
>MSS：传输层，最大分段，规定了 TCP 报文的最大长度，报文过长时进行分段传输。分段 = TCP 头部 + MSS + ID1。
>MSS < MTU

1. tcp 分段

	分段在传输层，有序列号
	
	

## UDP

UDP 不可靠传输

1. IP 分片

	网络层处理数据，确保数据传输 < MTU