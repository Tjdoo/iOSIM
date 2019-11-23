# iOSIM

即时通讯


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