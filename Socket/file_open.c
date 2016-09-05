#include<stdio.h>
#include<stdlib.h>
#include<fcntl.h>
#include<unistd.h>

void f_error_handling(char *message){
    fputs(message, stderr);
    fputc('\n', stderr);
    exit(1);
}

int file_write(void) {
//int main(void)  {
    
    int fd;
    char buf[] = "let's go!\n";
    
    fd = open("data.txt", O_CREAT|O_WRONLY|O_TRUNC);
    if (fd == -1) {
        f_error_handling("open() error");
    }
     printf("file descriptor :%d \n",fd);
    
    if (write(fd, buf, sizeof(buf))==-1) {
        f_error_handling("write() error");
    }
    
    close(fd);
    
    return 0;
}
/**
 gcc file_open.c -o lopen
 ./lopen
 cat data.txt
 
 
 */

#define BUF_SIZE 100

int file_read(void) {
    int fd;
    char buf[BUF_SIZE];
    
    fd = open("data.txt", O_RDONLY);
    if (fd == -1) {
        f_error_handling("open() error");
    }
    printf("file descriptor :%d \n",fd);
    
    if (read(fd, buf, sizeof(buf))==-1) {
        f_error_handling("read() error");
    }
    printf("file data :%s \n",buf);
    close(fd);
    
    return 0;
}


#include<sys/socket.h>

int file_descriptor_and_socket (void){
    int fd1,fd2,fd3;
    fd1 = socket(PF_INET,SOCK_STREAM,0);
    fd2 = open("test.dat",O_CREAT|O_WRONLY|O_TRUNC);
    fd3 = socket(PF_INET,SOCK_STREAM,0);
    printf("file descriptor 1 :%d \n",fd1);
    printf("file descriptor 2 :%d \n",fd2);
    printf("file descriptor 3 :%d \n",fd3);
    close(fd1);
    close(fd2);
    close(fd3);
    
    return 0;
}

/**
 *  输出3，4，5
 描述符从3开始以由小到大的顺序编号（numbering),
 因为0,1,2 是分配给标准I/O的描述符
 */


