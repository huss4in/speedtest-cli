#include "speedtest.h"

// http://install.speedtest.net/app/cli/ookla-speedtest-1.0.0-x86_64-linux.tgz
// const char domain[] = "install.speedtest.net", path[] = "app/cli/ookla-speedtest-1.0.0-x86_64-linux.tgz", file[] = "speedtest.tgz";

char domain[] = "www.google.com", path[] = "favicon.ico", name[] = "favicon.ico";

int main()
{
	printf("\n");
	for (int i = 0; i < 50; i++)
		printf("-");
	printf("\n");

	download(domain, path, name);

	return 0;
}