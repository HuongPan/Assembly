#define _GNU_SOURCE
#include <dirent.h>     /* Defines DT_* constants */
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/syscall.h>
#include <string.h>

#include <sys/types.h>



#define handle_error(msg) \
        do { perror(msg); exit(EXIT_FAILURE); } while (0)

struct linux_dirent {
    long           d_ino;
    off_t          d_off;
    unsigned short d_reclen;
    char           d_name[];
};
#define BUF_SIZE 1024

char pathCmd[30];
char cmd[201];
char pathStatus[30];
char status[1001];
char* parentId;

int main(int argc, char *argv[])
{
    int fd, nread, fd_1, fd_2;
    char buf[BUF_SIZE];
    struct linux_dirent *d;
    int bpos;
    char d_type;
    int result;
    
    fd = open("/proc", O_RDONLY | O_DIRECTORY);
    if (fd == -1)
        handle_error("open");
    printf("pid\tppid\tcmd\n");
    for ( ; ; ) {
        nread = syscall(SYS_getdents, fd, buf, BUF_SIZE);
        if (nread == -1)
            handle_error("getdents");

        if (nread == 0)
            break;

        for (bpos = 0; bpos < nread;) {
            d = (struct linux_dirent *) (buf + bpos);
            d_type = *(buf + bpos + d->d_reclen - 1);
            if(atoi(d->d_name) != 0 && d_type == DT_DIR){
            
                sprintf(pathCmd,"/proc/%s/cmdline",d->d_name);
                sprintf(pathStatus,"/proc/%s/status",d->d_name);
                fd_1 = open(pathCmd, O_RDONLY);
                if (fd_1 != -1){
                    result = read(fd_1,&cmd,200);
                    if(result < 1){
                        cmd[0] = '\x00';
                    }   
                    close(fd_1);
                    fd_2 = open(pathStatus, O_RDONLY);
                    if(fd_2 != -1){   
                        result = read(fd_2,status,1000);    
                        if(result <1){
                            status[0] = '\x00';
                        }
                        parentId = strstr(status,"PPid:");
                        if(parentId != NULL){
                            //printf("%d\n",atoi(parentId+6));
                            
                        }
                        printf("%s\t%d\t%s\n",d->d_name,atoi(parentId+6),cmd);    
                        close(fd_2);
                    }
                }
                
            }
            bpos += d->d_reclen;
        }
    }

    exit(EXIT_SUCCESS);
}
