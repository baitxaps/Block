//
//  socket.m
//  Block
//
//  Created by hairong chen on 16/2/23.
//  Copyright © 2016年 hairong chen. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#import "client_socket.h"
#import "socket_manager.h"

@implementation client_socket

int main_client_socket(int argc,char *argv[])
{
    int sock;
    struct sockaddr_in serv_addr;
    char message[30];
    int str_len;
    
    if(argc!=3){
        printf("usege :%s <IP><port> \n",argv[0]);
        exit(1);
    }
    
    sock = socket(PF_INET, SOCK_STREAM, 0);
    if (sock==-1) {
        error_handling("socket() error");
    }
    
    memset(&serv_addr, 0, sizeof(serv_addr));
    
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr =inet_addr(argv[1]);
    serv_addr.sin_port = htons(atoi(argv[2]));
    
    if (connect(sock, (struct sockaddr *)&serv_addr, sizeof(serv_addr))==-1) {
        error_handling("socket() error");
    }
    
    str_len = read(sock, message, sizeof(message)-1);
    if (str_len ==-1) {
        error_handling("read() error");
    }
    
    printf("Message from server :%s \n",message);
    
    close(sock);
    
    
    return 0;
}



int fileMain(void)  {
    
    int fd;
    char buf[] = "let's go!\n";
    
    fd = open("data.txt", O_CREAT|O_WRONLY|O_TRUNC);
    if (fd == -1) {
        error_handling("open() error");
    }
     printf("file descriptor :%d \n",fd);
    
    if (write(fd, buf, sizeof(buf))==-1) {
        error_handling("write() error");
    }
    
    close(fd);
    
    return 0;
}

// endian_conv.c

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
    
    
// initional
    struct sockaddr_in addrinit;
    char *serv_ip = "211,127.168.13";
    char *serv_port = "9190";
    memset(&addrinit,0,sizeof(addrinit));
    
    addrinit.sin_family = AF_INET;
    addrinit.sin_addr.s_addr = inet_addr(serv_ip);
    addrinit.sin_port = htons(atoi(serv_port));
    
    bind(serv_sock,(struct sockaddr *)&serv_addr,sizeof(serv_addr));
    // ...
    
    return 0;
}


@end

