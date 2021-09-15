#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <stdio.h>
// #include <unistd.h>

// http://install.speedtest.net/app/cli/ookla-speedtest-1.0.0-x86_64-linux.tgz
// const char domain[] = "install.speedtest.net", path[] = "app/cli/ookla-speedtest-1.0.0-x86_64-linux.tgz", file[] = "speedtest.tgz";
const char domain[] = "www.google.com", path[] = "favicon.ico", file_name[] = "favicon.ico";

void Exit(char message[])
{
	fprintf(stderr, message, "\n");

	exit(1);
}

int ReadHttpStatus(int sock)
{
	char buff[1024], *ptr;
	int bytes_received, status;

	for (ptr = buff; bytes_received = recv(sock, ptr, 1, 0); ptr++)
	{
		if (bytes_received == -1)
			Exit("Didn't Receive Response");

		if (*ptr == '\n' && ptr[-1] == '\r')
			break;
	}
	*ptr = 0, ptr = buff;

	sscanf(ptr, "%*s %d ", &status); // printf("%s\t%d\n", ptr, status);

	return bytes_received > 0 ? status : 0;
}

//the only filed that it parsed is 'Content-Length'
int ParseHeader(int sock)
{
	char buff[1024], *ptr;
	int bytes_received, status;

	for (ptr = buff; bytes_received = recv(sock, ptr, 1, 0); ptr++)
	{
		if (bytes_received == -1)
			Exit("Didn't Receive Response");

		if (*ptr == '\n' && ptr[-1] == '\r' && ptr[-2] == '\n' && ptr[-3] == '\r')
			break;
	}
	*ptr = 0, ptr = buff;

	if (bytes_received)
		if (ptr = strstr(ptr, "Content-Length:"))
			sscanf(ptr, "%*s %d", &bytes_received);
		else
			bytes_received = -1; //unknown size

	// printf("Content-Length: %d\n", bytes_received);
	return bytes_received;
}

void download()
{
	printf("\n");
	for (int i = 0; i < 50; i++)
		printf("-");
	printf("\n");

	int sock, bytes_received;
	char request[1024], recv_data[1024];
	struct sockaddr_in server_addr;
	struct hostent *host_entry;

	host_entry = gethostbyname(domain);

	if (host_entry == NULL)
		Exit("Couldn't resolve host ip");

	if ((sock = socket(AF_INET, SOCK_STREAM, 0)) == -1)
		Exit("Couldn't initiate connection");

	server_addr.sin_family = 2, server_addr.sin_addr = *((struct in_addr *)host_entry->h_addr), server_addr.sin_port = 20480; // Interne Protocol, Port (80)
	// bzero(&(server_addr.sin_zero), 8);

	// printf("Connecting ...\n");
	if (connect(sock, (struct sockaddr *)&server_addr, sizeof(struct sockaddr)) == -1)
		Exit("Couldn't connect to host");

	snprintf(request, sizeof(request), "GET /%s HTTP/1.1\r\nHost: %s\r\n\r\n", path, domain);

	// printf("Sending data ...\n");
	if (send(sock, request, strlen(request), 0) == -1)
		Exit("Couldn't Send Request");

	// printf("Downloading file...\n\n");
	int content_length;
	if (ReadHttpStatus(sock) && (content_length = ParseHeader(sock)))
	{
		FILE *file = fopen(file_name, "wb");

		for (int bytes = 0; bytes_received = recv(sock, recv_data, 1024, 0);)
		{
			if (bytes_received == -1)
				Exit("Couldn't Download File");

			fwrite(recv_data, 1, bytes_received, file);
			bytes += bytes_received;
			// printf("Bytes received: %d from %d\n", bytes, content_length);
			if (bytes == content_length)
				break;
		}
		fclose(file);
	}

	close(sock);

	printf("Downloaded.\n");
}

int main(void)
{
	download();

	return 0;
}