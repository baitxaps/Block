//
//  server_socket.m
//  Block
//
//  Created by hairong chen on 16/2/23.
//  Copyright © 2016年 hairong chen. All rights reserved.
//

#import "server_socket.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#import "socket_manager.h"

@implementation server_socket

int main_server_socket(int argc,char *argv[])
{
    int serv_sock;
    int clnt_sock;
    
    struct sockaddr_in serv_addr;
     struct sockaddr_in clnt_addr;
    socklen_t clnt_addr_size;
    
    char message[] = "Hello World!";
    if (argc !=2) {
        printf("usege :%s <port> \n",argv[0]);
        exit(1);
    }
    
    serv_sock = socket(PF_INET, SOCK_STREAM, 0);
    if (serv_sock==-1) {
        error_handling("socket() error");
    }
    memset(&serv_addr, 0, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr =htonl(INADDR_ANY);
    serv_addr.sin_port = htons(atoi(argv[1]));
    
    if (bind(serv_sock,(struct sockaddr *)&serv_addr,sizeof(serv_addr))==-1) {
        error_handling("bind() error");
    }
    
    if (listen(serv_sock, 5)==-1) {
         error_handling("listen() error");
    }
    
    clnt_addr_size = sizeof(clnt_addr);
    
    clnt_sock = accept(serv_sock, (struct sockaddr *)&clnt_addr, &clnt_addr_size);
    if (clnt_sock==-1) {
         error_handling("accept() error");
    }

    write(clnt_sock, message, sizeof(message));// 用于传输数据
    close(clnt_sock);
    close(serv_sock);
    
    return 0;
}

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
    // 处理5个客户端连接而添加的循环语句,共调用5次accetp()，依次向5个客户端提供服务
    for ( i = 0; i < 5; i ++) {
        clnt_sock = accept(serv_sock, (struct sockaddr *)&clnt_adr, &clnt_adr_sz);
        if (clnt_sock == -1) {
            error_handling("accept() error");
        }else {
            printf("Connected client %d \n",i + 1);
        }
        // 完成回声服务的代码，原封不动地传输读取的字符串
        while ((str_len = (int)read(clnt_sock, message, BUF_SIZE))!=0) {
            write(clnt_sock, message, str_len);
        }
        close(clnt_sock); // 针对套接字调用close()，向连接的相应套接字发送EOF。客户端套接字若调用close(),循环条件变假
       
    }
     close(serv_sock);
    return 0;
}























@end

