## Android Handler

  * framework:
    - Handler: 负责收发消息 Message; sendMessage, dispatchMessage, handleMessage (要点: dispatchMessage 优先级)
    - Message: 数据载体, 单向链表实现, 回收池50: Message.obtain()
    - Looper: loop 从MessageQueue 取Message 处理, tls 线程内唯一, 
    - MessageQueue: 除了满足Handler 延迟执行, 线程间通讯的接口之外, 可以监听fd: addOnFileDescriptorEventListener
      要点: nativePollOnce android_os_MessageQueue.cpp
  * native:
    - Looper.cpp: Looper::sendMessage; Looper::addFd; Looper::pollOnce; Looper::wake
    - Looper.h: MessageHandler - handleMessage; LooperCallback - handleEvent, Message 采用Vector保存
  * kernel:
    - epoll_create
    - epoll_ctl
    - epoll_wait

> 整体机制: epoll IO复用机制fd监听, Message(fw的头节点, native的数组第一个元素)的when - now 作为timeout时间poll_wait
> 默认Looper至少有一个eventfd: mWakeEventFd; 添加Message时, 唤醒mWakeEventFd, pollOnce -> pollInner 处理 handleMessage
