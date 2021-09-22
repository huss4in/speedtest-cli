#include "speedtest.h"

#ifndef ARCH
#define ARCH "x86_64"
#endif

#ifndef SPT
#define SPT "speedtest"
#endif

#ifndef GPZ
#define GPZ "gzip"
#endif

#ifndef TAR
#define TAR "tar"
#endif

#ifndef CAC
#define CAC "ca-certificates"
#endif

int main(int argc, char *argv[])
{
	for (int i = 0; i < 50; i++)
		printf("-");
	printf("\n");

	pid_t download_speedtestcli, extract_certificates, extract_speedtestcli;

	printf("\n1. Downloading Speedtest...\n");

	if ((download_speedtestcli = fork()) == 0)
	{
		downloadURL("install.speedtest.net", "/app/cli/ookla-speedtest-1.0.0-" ARCH "-linux.tgz", SPT ".tgz");

		exit(0);
	}

	printf("\n2. Extracting CA Certificates...\n");

	if ((extract_certificates = fork()) == 0)
	{
		if (fork() == 0)
			execl("./gzip", "./gzip", "-d", CAC ".tgz", NULL);

		wait(NULL);
		execl("./tar", "./tar", "--extract", "--file", CAC ".tar", NULL);

		exit(0);
	}

	waitpid(download_speedtestcli, NULL, 0);

	printf("\n3. Extracting Speedtest...\n");

	if ((extract_speedtestcli = fork()) == 0)
	{
		if (fork() == 0)
			execl("./gzip", "./gzip", "-d", SPT ".tgz", NULL);

		wait(NULL);
		execl("./tar", "./tar", "--extract", "--file", SPT ".tar", "speedtest", NULL);

		exit(0);
	}

	waitpid(extract_certificates, NULL, 0);
	waitpid(extract_speedtestcli, NULL, 0);

	printf("\n4. Running Speedtest...\n");

	execl("./speedtest", "./speedtest", "--ca-certificate=" CAC ".crt", argv[1]);

	return 0;
}
