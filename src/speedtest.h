#include <sys/socket.h>
#include <netinet/in.h>
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

int get_content_length(int sock)
{
    int buffer_size = 1024, received, status;
    char buff[buffer_size], *ptr = buff;

    for (ptr = buff;; ptr++)
    {
        if ((received = recv(sock, ptr, 1, 0)) == -1)
            Exit("Didn't Receive Response");

        if (*ptr == '\n' && ptr[-1] == '\r')
            break;
    }
    *ptr = 0, ptr = buff;

    sscanf(ptr, "%*s %d ", &status); // printf("%s\t%d\n", ptr, status);

    for (int i = 0; i < buffer_size; ptr++, i++)
    {
        if ((received = recv(sock, ptr, 1, 0)) == -1)
            Exit("Didn't Receive Response");

        if (ptr[0] == '\n' && ptr[-1] == '\r' && ptr[-2] == '\n' && ptr[-3] == '\r')
        {
            *ptr = '\0';
            break;
        }
    }

    sscanf(strstr(buff, "Content-Length:"), "%*s %d", &received);

    printf("\nStatus: %d", status);
    printf("\nTotal: %d\n\n", received);

    return received;
}

void download(char domain[], char path[], char file_name[])
{
    const short request_length = 512;
    char request[request_length];

    snprintf(request, request_length, "GET /%s HTTP/1.1\r\nHost: %s\r\n\r\n", path, domain);

    const struct hostent *host_entry = gethostbyname(domain);

    if (host_entry == NULL)
        Exit("Couldn't Resolve Host IP");

    if ((SOCKET = socket(AF_INET, SOCK_STREAM, 0)) == -1)
        Exit("Couldn't Initiate Connection");

    struct sockaddr_in server_address;
    server_address.sin_family = 2;                                     // Interne Protocol
    server_address.sin_port = 20480;                                   // Port (80)
    server_address.sin_addr = *((struct in_addr *)host_entry->h_addr); // IP Address

    // printf("Connecting ...\n");
    if (connect(SOCKET, (struct sockaddr *)&server_address, sizeof(struct sockaddr)) == -1)
        Exit("Couldn't Connect to Host");

    // printf("Sending data ...\n");
    if (send(SOCKET, request, strlen(request), 0) == -1)
        Exit("Couldn't Send Request");

    const int total = get_content_length(SOCKET);
    if (total)
    {
        const short buffer_length = 1024;
        char buffer[buffer_length];
        int received, written;

        FILE *file = fopen(file_name, "wb");

        do
        {
            if ((received = recv(SOCKET, buffer, buffer_length, 0)) != -1)
                fwrite(buffer, 1, received, file);
            else
                Exit("Couldn't Download File");

            written += received;
        }

        while (written < total);

        printf("Written: %db / %db\n", written, total);

        fclose(file);
    }

    close(SOCKET);

    printf("Downloaded.\n");
}