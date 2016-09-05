//
//  socket_manager.h
//  Block
//
//  Created by hairong chen on 16/2/23.
//  Copyright © 2016年 hairong chen. All rights reserved.
//

#import <Foundation/Foundation.h>
void error_handling(char *message);

@interface socket_manager : NSObject

@end


// 构建接电话套接字

/*
一、套接字创建过程
1.调用socket函数（安装电话机）时进行的对话。成功时返回文件描述，失败时返回－1
 int socket(int main,int type,int protocol);
 
2.调用bind函数（分配电话号码）时进行的对话,成功时返回0，失败时返回－1
int bind(int sockfd,struct sockaddr *maddr,socklen_t addrlen);
 
3.调用listem函数（连接电话线）时进行的对话,成功时返回0，失败时返回－1
int listen(int sockfd,int backlog);
 
4.调用accept函数（拿起话筒）时进行的对话,成功时返回文件描述，失败时返回－1
int accetp(int sockfd,struct sockaddr *addr,socklen_t *addrlen);
 
 
网络编程中接受连接请求的套接字创建过程如下：
 1.调用socket函数创建套接字
 2.调用bind函数分配IP地址和端口号
 3.调用listen函数转为可接收请求状态
 4.调用accept函数受理连接请求
 
 
二、服务端创建的套接字又称服务端套接字或监听(listening)套接字，客户羰套接字的创建过程比创建服务器端
 套接字简单，客户端只有调用socket函数创建套接字和调用connect函数向服务器发送连接请求两个步骤：
 1.调用socket ,connect 
 2.与服务端共同运行以收发字符串数据
 
 打电话（请求连接）的函数，其调用的是客户端套接字,成功时返回0，失败时返回－1
 int connect(int sockefd,struct sockaddr *serv_addr,socklen_t addrlen);
 
 
 3. 调用socket函数创建套接字，如果紧接着调用bind,listen将成为服务端套接字；如果调用connect
 将成为客户端套接字
 
        ｜｜｜｜
 
 4. GCC(GUN Complier Collection,GUN编译器集合)
 gcc server_socket.c -o hserver
 ./hserver 9190
 
 gcc client_socket.c -o hclient
 ./hclient 127.0.0.1 9190
 
 5.Linux而言，socket操作与文件操作没有区别，socket也被认为是文件的一种，因为在网络数据传输过程中自然可以使用文件I/O的
 相关函数，而Windows则与Linux不同，是要区分socket和文件的
 
 
 6.如果想使用Linux提供的文件I/O函数，应该理解好文件描述符的概念： 此处的文件描述符是系统分配给文件或套接字的整数，学习Ｃ
 语言过程中用过的标准输入输出及标准错误在Linux中也被分配 如下的文件描述符：
  文件描述符         对象
    0               标准输入：Standard Input
    1               标准输出：Standard Output
    2               标准错误：Standard Error
 在Windows平台中称"句柄",Linux平台则用“描述符"

 三、文件操作
 1.打开文件
 int open(const char *path,int flag) 成功时返回文件描述，失败时返回－1
 
 第一个参数：文件路径
 第二个参数：文件打开模式
 
 打开模式           含义
 O_CREAT           必要时创建文件
 O_TRUNC           删除全部现有数据
 O_APPEND           维技现在数据，保存到其后面
 O_RDONLY           只读打开
 O_WRONLY           只写打开
 O_RDWR             读写打开
 
2.关闭文件
 int close(int fd) 成功时返回0，失败时返回－1
 fd:需要关闭的文件或套接字的文件描述符
 
3.将数据写入文件
 write函数用于向文件输出（传输）数据。Linux中不区分文件与套接字，因此，通过套接字向其他计算机传递数据
 时也会用到该函数
 ssize_t write(int fd,const void *buf,size_t nbytes);成功时返回写入的字节数，失败时返回－1
  fd:显示数据传输对象的文件描述符
  buf:保存要传输数据的缓冲地址值
  nbytes:要传输数据的字节数

 size_t通过typedef 声明的unsigned int类型,ssize_t，size_t前面多加的s代表signed,即ssize_t是
 通过typedef声明的signed int类型
 
 4.读取文件中的数据
 ssize_t read(int fd,void *buf,size_t nbytes);成功时返回接收的字节数（但遇到文件结尾则返回0)，失败时返回－1
 
 
 
 
 
 
 
 
 
 
 
 
 
 
*/