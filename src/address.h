/******************************************************************************\
__     __    ____  _ ____              ____  
\ \   / /__ |  _ \(_) ___| _   _ ___  |___ \ 
 \ \ / / _ \| | | | \___ \| | | / __|   __) |
  \ V / (_) | |_| | |___) | |_| \__ \  / __/ 
   \_/ \___/|____/|_|____/ \__, |___/ |_____|
                           |___/             
==============================================================================
 File:         address.h
 Timestamp:    2018-Jul-30
 Author:       Paolo Bosetti <paolo.bosetti@unitn.it>
 Organization: Trentino Sviluppo SpA - https://promfacility.eu
 LICENSE:      All rights reserved (C) 2018
               Contains some MIT-licensed code as prior-knowledge, see the
               header of relevant source files
\******************************************************************************/

#ifndef FFT_ADDRESS_H
#define FFT_ADDRESS_H


#ifdef __MIPSEL
  #define INTERFACE_NAME "br-wlan"
#elif __APPLE__
  #define INTERFACE_NAME "en0"
  // #warning Building for testing platform
#elif __ARM7__
  //#define INTERFACE_NAME "en0"
  #define INTERFACE_NAME "eth1"
#elif linux
  #define INTERFACE_NAME "enp1s0"
  // #warning Building for testing platform
#else
  #error UNSUPPORTED PLATFORM
#endif

void mac_eth0(char MAC_str[13], char *name);

#endif







