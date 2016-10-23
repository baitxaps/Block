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
 
 
////////////////////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////////////////////
 5. A:0-127 B:128-191 c:192-223
 
 6.计算机中一般配有NIC(Network Interface Card,网络接口卡）数据传输设备，通过ＮIC向计算机内部传输数据时会用到IP
 操作系统负责把传递到内部的数据适当分配给套接字，这时就要用到端口。也就是说，通过NIC接收的数据内有端口号，操作系统正是参
 此端口号把数据传输给相应端口的套接字
 
 6.1 端口号是在同一操作系统内为区分不同套接字而设置的，因此无法将我个端口号分配给不同套接字。另外，端口号由16位构成，可
 分配的端口号范围是0-65535,但0-1023是知名端口(well-know PORT)，一般分配给特定应用程序。所以应当分配此范围之外的值。
 另外，虽然端口号不能重复，但TCP和UDP套接定不会共用端口号，所以允许复复
 
 7.IPv4地址的结构体
 struct sockaddr_in {
    sa_family_t     sin_family;     // 地址族(Address Family)
    unit16_t        sin_port;       // 16位TCP/UDP 端口号
    struct in_addr  sin_addr;       // 32位IP地址
    char            sin_zert[8];    // 不使用
 };
 
 struct in_addr {
    In_addr_t  s_addr;              //  32位IP地址
 }
 
 
 7.2
 sturct sockaddr_in serv_addr;
 
 if(bind(serv_sock,(struct sockaddr *)&serv_addr,sizeof(serv_addr)) == -1)
 error_handling("bind() error");
 
 stutct sockaddr {
    sa_family_t       sin_family;   // 地址族
    char              sa_data[14];  // 地址信息
 }
 
 此结构体成员sa_data保存的地址信息中需包含IP地址和端口号，剩余部分应填充0,这也是bind函数要求的。
 而这对于包含地址信息来讲非常麻烦，继而就有了新的结构体sockaddr_in.若按照之前的sockadr_in结构
 体，则将生成符合bind函数要求的字节流。最后转换为sockaddr型的结构体变量，再传递给bind函数即可。
 
 sockaddr_in是保存IPv4地址信息的结构体，还需要通过sin_family单独指定地址族信息，结构体sockaddr
 并非只为IPv4设计，这从保存地址信息的数组sa_data长度为14字节也可看出，因此，结构体sockaddr要求在
 sin_family中指定地址族信息，为了与sockaddr保持一致，sockaddr_in结构体中也有地址族信息
 
 
 POSIX(Portable Operation Systerm Interface,可移植操作系统接口).POSIX是为UNIX系列操作系统设立的标准，它定议
 了一些其他数据类型：
-------------------------------------------------------
 sys/types.h
-------------------------------------------------------
 int8_t         singned 8-bit int
 uint8_t        unsigned 8-bit int(unsigned char)
 int16_t        signed 16-bit int
 uint16_t       unsigned 16-bit int(unsigned short)
 int32_t        singned 32-bit int
 uint32_t       unsigned 32-bit int(unsigned long)
 
-------------------------------------------------------
 sys/socket.h
-------------------------------------------------------
 sa_family_t    地址族(address family)
 socklen_t      长度（length of struct)
 
------------------------------------------------------
 netinet/in.h
------------------------------------------------------
 in_addr_t      IP地址，声明为unit32_t
 in_port_t      端口号，声明为unit16_t
------------------------------------------------------
 
 7.3结构体sockaddr_in的成员分析
 sin_family        
 AF_INET        IPv4网络协议中使用的地址族
 AF_INET6       IPv6网络协议中使用的地址族
 AF_LOCAL       本地通信中采用的UNIX协议的地址族
 AF_LOCAL       只是为了说明具有多种地址族而添加的
 
 sin_port
 保存16位端口号，重点在于，它以网络字节序保存
 
 sin_addr
 保存32位IP地址信息，且也以网络字节序保存
 
 sin_zero
 无特殊含义。只是为使结构体sockaddr_in的大小与sockaddr结构体保持一到而插入的成员。必需填充为0,
 否则无法得到想要的结果
 
7.4 网络字节序与地址变换，不同CPU中，4字节整数型值1在内存空间的保存方式是不同的
 00000000  00000000  00000000  00000001
 00000001  00000000  00000000  00000000
 
 字节序(Order)与网络字节序
 网络字节序：在通过网络传输数据时约定统一方式，这种约定称为网络字节序，非常简单--统一为大端序
 CPU向内存保存数据的方式有2种，这意味着CPU解析数据的方式也分为2种
 大端序(Big Endian):高位字节存放到低位地址
 小端充(Little Endian):高位节节存放到高位地址
 
 大端序整数0x12345678中，0x12是最高位字节，0x78是最低位字节。因此大端序中先保存最高位字节0x12
 (最高位字节0x12存放低位地址)
 0x20       0x21        0x22        0x22
 0x12       0x34        0x56        0x78
 
 小端序整数0x12345678中，0x78是最低位字节
 0x20       0x21        0x22        0x22
 0x78       0x56        0x34        0x12
 
 从以上分析看出，每种CPU的数据保存方式均不同，因此代表CPU数据保存方式的主机字节序(Host Byte Order)
 在不同CPU中也各不相同，目前主流的Intel系列CPU以小端序方式保存数据
 
 字节序转换
 unsigned short htons(unsigned short); // 把short型数据从主机字节转化为网张字节序
 unsigned short ntohs(unsigned short); // 把short型数据从网络字节序转化为主机字节序
 unsigned short htonl(unsigned long);
 unsigned short ntonl(unsigned long);
 
 7.5 网络地址的初始化与分配
 将字符串信息转换为网络字节序的整数型
 sockaddr_in中保存地址信息的成员为32位整数型，为了分配IP,需要将其表示为32整数型数据
 
.in_addr_t inet_addr(const char *string); // <arpa/inet.h>
 成功时返回32位大端序整型值，失败时返回INADDR_NONE,inet_addr函数不仅可以把IP地址转成32位整数型
 而且可以检测无效的IP地址，另外，从输出结果可以验证确实转换为网络字节序
 
 inet_aton函数与inet_addr函数在功能上完全相同，也将字符串形式IP地址转换为32位网络字节序整数并返
 回，只不过函数利用了in_addr结构体，且其使用频率更高
. int inet_aton(const char *string, struct in_addr *addr);  成功时返回1,失败时返回0
 string:含有需转换的IP地址信息的字符串地址值
 addr:将保存转换结果的in_addr结构体变量的地址值
 
 实际编程中若要调用inet_addr(),需要将转换后的IP地址信息代入sockaddr_in结构体中声明的in_addr
 结构体变量。而inet_aton()则不需此过程
 
. char *inet_ntoa(struct in_addr adr);把网络字节序整数型IP地址转换成孰悉的字符串形式，
 成功时返回转换的字符串地址值，失败时返回－1
 调用时需小心，返回值类型为char指针，返回字符串地址意味着字符串已保存到内存空间，但该函数未向程序员
 要求配内存，而是在内部申请了内存并保存了字符串，若需要长期保存，则应将字符串复制到其他内存空间。j
 
 7.7
 请求方法不同意味着调用的函数也不同，服务器端的准备工作通过bind()完成，而客户端则通过connect()完成
 因此，函数调用前需准备的地址值类型也不同。服务器端声明sockaddr_in结构体变量，将其初始化为赋予服务器
 IP和套接字的端口号，然后调用bind();而客户端则声明sockaddr_in结构体，并初始化为要与之连接的服务器
 端套接字的IP和端口叼，然扣调用connect();
 
 7.8 INADDR_ANY
 利用常数INADDR_ANY分配服务器端的IP地址。采用这种方式，则可自动获取运行服务器端的计算机IP地址，不必
 亲自输入。而且，若同一计算机中已分配多个IP地址（多宿主(Multi-homed)计算机，一般路由器属于这一类)
 则只要端口号一致，就可以从不同IP地址接收数据。因此服务端中优先考虑这种方式。而客户端中除非带有一部分
 服务器端功能，否则不会采用
 同一计算机中可以分配多个IP，实际IP的个数与计算机安装的NIC的数量相等。即使是服务器端套接字，也需要决定应
 接收哪个IP传来的（哪个NIC传来的）数据。因此，服务器端套接字初始化过程中要求IP地址信息，另外，若只有1个
 NIC,则直接使用INADDR_ANY.
 
 7.9 向套接字分配网络地址
 上面用sockadr_in结构体初始化方法，接下来就把初始化的地址信息分配给套接字。bind（）负责这项操作
 int bind(int sockfd,struct sockaddr *myaddr, socklen_t addrlen)
 成功时返回0,失败时返回－1
 sockfd:要分配地址信息（IP和端口号）的套接字文件描述符
 myaddr:存有地址信息的结构体变量地址值
 addrlen:第二个结构体变量的长度
 
 
 
 // exmaple:
 int endian_conv() {
 unsigned short host_port = 0x1234;
 unsigned short net_port;
 unsigned long host_addr = 0x12345678;
 unsigned long net_addr;
 
 net_port = htons(host_port);
 net_addr = htonl(host_addr);
 
 printf("host ordered port:%#x \n",host_port);
 printf("network ordered port:%#x \n",net_port);
 printf("host ordered address:%#lx \n",host_addr);
 printf("network ordered address:%#lx \n",net_addr);
 
 // inet_addr.c
 char *addr1 = "1.2.3.4";
 char *addr2 = "1.2.3.256";
 
 unsigned long cov_addr = inet_addr(addr1);
 if (cov_addr == INADDR_NONE) {
 printf("ERROR occured! \n");
 }else {
 printf("network ordered integer addr:%#lx \n",cov_addr);
 }
 cov_addr = inet_addr(addr2);
 if (cov_addr == INADDR_NONE) {
 printf("ERROR occured! \n");
 }else {
 printf("network ordered integer addr:%#lx \n",cov_addr);
 }
 
 // inet_aton.c
 char *addr = "127.232.124.79";
 struct sockaddr_in addr_inet;
 if (!inet_aton(addr,&addr_inet.sin_addr)) {
 error_handling("Converson error");
 }else {
 printf("network ordered integer addr:%#x \n",addr_inet.sin_addr.s_addr);
 
 }
 
 // inet_ntoa.c
 struct sockaddr_in addro,addrt;
 char *str_prt;
 char str_arr[20];
 
 addro.sin_addr.s_addr = htonl(0x1020304);
 addrt.sin_addr.s_addr = htonl(0x1010101);
 str_prt = inet_ntoa(addro.sin_addr);
 strcpy(str_arr,str_prt);
 printf("Dotted-Decimal notation1: %s \n",str_prt);
 
 inet_ntoa(addrt.sin_addr);
 printf("Dotted-Decimal notation2: %s \n",str_prt);
 printf("Dotted-Decimal notation3: %s \n",str_arr);
 
 // 网络地址的初始化
 struct sockaddr_in addrinit;
 char *serv_ip = "211,127.168.13";
 char *serv_port = "9190";
 memset(&addrinit,0,sizeof(addrinit));
 
 addrinit.sin_family = AF_INET;
 addrinit.sin_addr.s_addr = inet_addr(serv_ip);
// addrinit.sin_addr.s_addr = inet_addr(INADDR_ANY);
 addrinit.sin_port = htons(atoi(serv_port));
 return 0;
 }
 
 8.基于TCP的服务端/客户端
 根据数据传输方式不同，基于网络协议的套接字一般分为TCP套接字(也叫基于流stream的套接字)和UDP套接字。
 
 TCP/IP协议栈(Stack,层）eg:
            应用层
            /   \
          TCP   UDP
           \     /
            IP层
             |
            链路层
 
 各层可能通过操作系统等软件实现，也可能通过类似NIC的硬件设备实现
0>开放系统
 以多个标准为依据设计的系统称为开放系统，TCP／IP协议栈也属于其中之一
 优点： 路由器来完成IP层交互任务，网卡：网卡制造商都会遵守链路层的协议标准
 
 1>链路层：是物理链接领或标准的结果，也是最基本的领域，专门定义LAN，WAN，MAN等网络标准
 2>IP层：准备好物理连接后就要传输数据。为了在复杂的网络中传输数据，首先需要考虑路径的选择，向目标传输
 数据需要经过哪条路径？解决此问题就是IP层，该层使用的协议就是IP。IP本身是面向消息的，不可靠的协议。每次
 传输数据时会帮我们选择路径，但并不一致。如果传输中发生路径错误，则选择其他路径；但如果发生数据丢失或
 错误，则无法解决--IP协议无法应对数据错误
 3>TCP/UDP层：IP层解决数据传输中的路径选择问题，只需照此路径传数据即可。TCP和UDP层以IP层提供的路径信息为
 基础完成实际数据传输--传输层。UDP比TCP简单
 TCP与IP层二者关系：
 IP层只关注1个数据包(数据传输的基本单位)的传输过程。因此，即使传输多个数据包，每个数据包也是由IP层实际传输的
 ，也就是说传输本身是不可靠的。若只利用IP层传输数据，则有可能导致后传输的数据包B比先传输的数据包A提早到达。另外
 ，传输的数据包A/B/C中有可能收到A和C，甚至收到的C可能已损毁
 TCP如果数据交换过程中可以确认对方已收到数据，并重传丢失的数据，那么即便IP层不保证数据传输，这类通信也是可靠的
 4>应用层：
 上述内容是套接字通信过程中自动处理的。选择数据传输路径，数据确认过程都被隐藏到套接字内部。而与其说是“隐藏”，倒不
 如“使程序员从这些细节中解放出来”的表达更为准确。程序员编程时无需考虑这些过程，但这并不意味着不用掌握这些短识。只有
 掌握了这些理论，才能编写出符合需求的网络程序
 总之，向各位提供的工具就是套接字，只需利用套接字编出程序即可。编写软件的过程中，需要根据程序特点决定服务器和客户端之
 间的数据传输规则---应用层协议。
 网络编程的大部份内容就是设计并实现应用层协议
 
 8.1 实现基于TCP的服务器端/客户端
 TCP的服务器端默认的函数调用顺序：
 socket() 创建套接字
    |
    V
 bind()分配套接字地址
    |
    V
 listen()等待连接请求状态
    |
    V
 accept() 充许连接
    |
    V
 read()/write() 数据交换
    |
    V
 close() 断开连接
 
 socket,bind前面已说明，bind()(给套接字分配了地址，接下来就要通过调用listen（）进入等待连接请求状态
 只有调用了listen(),客户端才能进入可发出连接请求的状态----这时客户端才能调用connect()(若提前调用将发生错误）
 int listen(int sock,int backlog);// 成功时返回0,失败时返回-1
 sock:希望进入等待连接状态的套接字文件描述符，传递的描述符套接字参数为服务端套接字（监听套接字）
 backlog:连接请求等待队列(Queue)的长度，若为5,则队列长度为5，表示最多使5个连接请求进入队列。（与服务端的特性有关，
 像频繁接收请求的Web服务端至少应为15.另外，连接请求队列的大小始终根据实验结果而定。）
 
 int accept(int sock,struct sockaddr *addr,socklen_t *addrlen);//成功返回创建的套接字文件描述符，失败返回-1;
 sock:服务器套接字的文件描述符
 addr:保存发起连接请求的客户端地址信息的变量地址值，调用函数后向传递来的地址变量参数填充客房端地址信息
 addrlen:第二个参数addr结构体的长度，但时存有长度的变量地址。函数调用完成后，该变量即被填入客户端地址长度 
 
 accept()受理连接请求等待队列中待处理的客户端连接请求。函数调用成功时，accetp()内部将产生用于数据I/O的套接字，并返回其
 文件描述符。需要强调的是，套接字是自动创建的，并自动与发起连接请求的客户端建立连接。
调用accept()从队头取1个连接请求与客户端建立连接，并返回创建的套接字文件描述符。另外，调用accetp()时若等待队列为空，则
 accept()不会返回，直到队列中出现新的客户端连接
 
 8.2 TCP客户端的默认函数调用顺序
 socket() 创建套接字
    |
    V
 connect()请求连接
    |
    V
 read()/write() 数据交换
    |
    V
 close() 断开连接
 
 与服务端相比，区别就在于"请求连接“，它是创建客户端套接字后向服务器端发起的连接请求。服务器端调用
 listen()创建连接请求等待队列，之后客户端即可请求连接。
 
 int connect(int sock, struct sockaddr *servaddr, socklen_t addrlen);// 成功时返回0,失败时返回-1;
 sock:客户端套接字文件描述符
 servaddr:保存目标服务器端地址信息的变量地址值
 addrlen:以字节为单位传递已传递给第二个结构体参数servaddr的地址变量找度
 
 客户端调用connect()，发生以下情况之一才会返回（完成函数调用）
 1>服务器端接收连接请求
 2>发生断网等异常情况而中断连接请求
 需要注意，所谓的“接收连接”并不意味着服务器端调用accept(),其实是服务端把连接请求信息记录到等待队列。因此connect()
 返回后并不立即进行数据交换
 
 3>实现服务端必经过过程之一就是给套接字分配IP和端口号。但客户实现过程中并未出现套接字地址分配，而是创建套接字后立即调用
 connect(). 客户端调用connect()时，操作系统，更准确地说是在内核中，IP用计算机（主机）的IP，端口随机分配地址---客户端
 的IP和端口调用connect()时自动分配，无需调用标记的bind()进行分配
 
 8.3 基于TCP的服务端／客户端函数调用关系
 前面讲解TCP服务器／客户端的实现顺序，实际上二者并非相互独立
    服务器
 socket() 创建套接字
    |
    V
 bind()分配套接字地址                      客户端
    |                                   socket() 创建套接字
    V                                         |
 listen()等待连接请求状态                        V
    |   <---------------------------—--connect()请求连接
    V                      or       /         |
 accept() 充许连接                   /
    |   <------------------------  /          |
    V                                         V
 read()/write() 数据交换  <------->     read()/write() 数据交换
    |                                         |
    V                                         V
 close() 断开连接   <------------->      close() 断开连接
 
 
 总体流程整理：服务器端创建套接字后连续调用bind，listen函数进入等待状态，客户端通过调用connect()
 发起连接请求.需要注意的是，客户端只能等到服务端调用listen()后才能调connect().同时要清楚，客户端调用
 connect()前，服务器端有可能率先调用accetp().当然，此时服务端在调用accept()时进入阻塞(blocking)状
 态，直到客户端调用connect()为止
 
  8.4实现迭代服务器端／客户端
 1>实现迭代服务器端
 编写回声（echo)服务端／客户端----服务端将客户端传输的字符串数据原封不动地传回客户端，就像回声一样。
 之前的hello world服务端处理完发1个客户端连接请求即退出，连接请求等待队列实际没有太大意义。
 设置好等待队列的大小后，应向所有客户疫提供服务。如果想继续受理后续的客户疫连接请求，最简单的办法就是
 插入循环语句反复调用accetp()
 
 socket() 创建套接字
    |
    V
 bind()分配套接字地址
    |
    V
 listen()等待连接请求状态
    | <--------------------
    V                     |
 accept() 充许连接          |
    |                     |
    V                     |
 read()/write() 数据交换    |
    |---------------------
    V
 close() 断开连接
 调用accept()后，紧接着调用I/O相关的read(),write(),然后调用close()，这并非针对服务端套接字，而
 是针对accept()调用时创建的套接字。调用close()就意味着结束了针对某一客户端的服务，此时如果还想服务于
 其他客户端，就要重新调用accept()
 
2>实现迭代服务器端/客户端
 前面讲的就是迭代服务器端。妈即使服务端以迭代方式运转，客户端代码亦无太大区别。
 程序的基本运行方式：
 .服务端在同一时刻只与一个客户端相连，并提供回声服务
 .服务端依次向5个客户端提供服务并退出
 .客户端接收用户输入的字符串并发送到服务端
 .服务端将接收到的字符串数据传回客户端，即“回声”
 .服务端与客户端之间的字符串回声一直执行到客户端输入Q为止
 
 #define BUF_SIZE 1024
 int echo_serverc(int argc,char *argv[]) {
 int serv_sock,clnt_sock;
 char message[BUF_SIZE];
 int str_len,i;
 
 struct sockaddr_in serv_adr,clnt_adr;
 socklen_t clnt_adr_sz;
 
 if (argc!=2) {
 printf("usege:%s<port>\n",argv[0]);
 exit(1);
 }
 serv_sock = socket(PF_INET, SOCK_STREAM, 0);
 if (serv_sock == -1) {
 error_handling("socket() error");
 }
 memset(&serv_adr, 0, sizeof(serv_adr));
 serv_adr.sin_family = AF_INET;
 serv_adr.sin_addr.s_addr= htonl(INADDR_ANY);
 serv_adr.sin_port= htons(atoi(argv[1]));
 if (bind(serv_sock, (struct sockaddr *)&serv_adr, sizeof(serv_adr))== -1) {
 error_handling("bind() error");
 }
 
 if (listen(serv_sock, 5) == -1) {
 error_handling("listen() error");
 }
 clnt_adr_sz = sizeof(clnt_adr);
 for ( i = 0; i < 5; i ++) {
 clnt_sock = accept(serv_sock, (struct sockaddr *)&clnt_adr, &clnt_adr_sz);
 if (clnt_sock == -1) {
 error_handling("accept() error");
 }else {
 printf("Connected client %d \n",i + 1);
 }
 while ((str_len = (int)read(clnt_sock, message, BUF_SIZE))!=0) {
 write(clnt_sock, message, str_len);
 }
 close(serv_sock);
 }
 
 return 0;
 }
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
*/
