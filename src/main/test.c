#include <stdio.h>
#include "../defines.h"
#include "../address.h"

int main(int argc, char* argv[]) {
  char mac[13];
  get_mac_addr(mac, INTERFACE_NAME);
  printf("Version: %s\nMAC address: %s\n", GIT_COMMIT_HASH, mac);
  return 0;
}
