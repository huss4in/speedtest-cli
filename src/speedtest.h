#include <sys/socket.h>
#include <netinet/in.h>
#include <sys/wait.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <netdb.h>
#include <stdio.h>

int SOCKET;

void Exit(char message[])
{
    fprintf(stderr, message, "\n");

    close(SOCKET);

    exit(1);
}

void downloadURL(char domain[], char path[], char name[])
{
    int received_size = 0, status = 0, header_size = 0, data_size = 0, data_written = 0;

    char request_buffer[1024], header_buffer[1024], data_buffer[1024];

    // printf("\nResolving Host IP Address...\n");
    const struct hostent *host_entry = gethostbyname(domain);
    if (host_entry == NULL)
        Exit("Couldn't Resolve Host IP");
    // printf("Host IP Address Resolved: %X.", host_entry->h_addr);

    struct sockaddr_in server_address;
    server_address.sin_family = AF_INET;                               // Interne Protocol
    server_address.sin_port = htons(80);                               // Port (80)
    server_address.sin_addr = *((struct in_addr *)host_entry->h_addr); // IP Address

    // printf("\n\nInitialize Connection...\n");
    if ((SOCKET = socket(AF_INET, SOCK_STREAM, 0)) == -1)
        Exit("Couldn't Initiate Connection");
    // printf("Connection initialized.");

    // printf("\n\nConnection to Host...\n");
    if (connect(SOCKET, (struct sockaddr *)&server_address, sizeof(struct sockaddr)) == -1)
        Exit("Couldn't Connect to Host");
    // printf("Connected.");

    // printf("\n\nSending Request...\n");
    snprintf(request_buffer, 1024, "GET %s HTTP/1.0\r\n"
                                   "Host: %s\r\n\r\n",
             path, domain);
    // printf("-------------------\n%s\n", request_buffer);

    if (send(SOCKET, request_buffer, strlen(request_buffer), 0) == -1)
        Exit("Couldn't Send Request");

    // printf("Receiving Response...\n");

    for (char *ptr = header_buffer;; ptr++)
    {
        if ((received_size = recv(SOCKET, ptr, 1, 0)) == -1)
            Exit("Didn't Receive Response");

        header_size += received_size;

        if (ptr[-3] == '\r' && ptr[-2] == '\n' && ptr[-1] == '\r' && ptr[0] == '\n')
        {
            ptr[-3] = '\0';
            break;
        }
    }

    // printf("-------------------\n%s\n\n\n", header_buffer);
    // char *status_line, *data_size_line;
    // if ((status_line = strstr(header_buffer, "HTTP")) != NULL)
    //     sscanf(status_line, "%*s %d", &status);
    // if ((data_size_line = strstr(header_buffer, "Content-Length")) != NULL)
    //     sscanf(data_size_line, "%*s %d", &data_size);

    FILE *file = fopen(name, "wb");

    while (received_size = recv(SOCKET, data_buffer, 1024, 0))
    {
        if (received_size == -1)
            Exit("Couldn't Download File");

        fwrite(data_buffer, 1, received_size, file);

        // printf("%s", data_buffer);
        // data_written += received_size;
    }

    fclose(file);

    // printf("\n\n---------------");
    // printf("\nStatus:  %d", status);
    // printf("\nHeader:  %d", header_size);
    // printf("\nData:    %d", data_size);
    // printf("\nWritten: %d", data_written);
    // printf("\n---------------\n");

    // printf("\nDone\n");

    close(SOCKET);
}

void exctract(char tgz[], char tar[], char file[])
{

    if (fork() == 0)
    {
        printf("\nGZIP");
        char *args[] = {"./gzip", "-d", tgz, NULL};
        execv(args[0], args);

        exit(0);
    }
    wait(NULL);

    printf("\nTAR");

    char *args[] = {"./tar", "--extract", "--file", tar, file, NULL};
    execv(args[0], args);

    exit(0);
}