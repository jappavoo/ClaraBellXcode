//
//  ClaraBell.c
//  ClaraBell
//
//  Created by Jonathan Appavoo on 2/18/13.
//  Copyright (c) 2013 Jonathan Appavoo. All rights reserved.
//

#include <stdio.h>
#include "ClaraBell.h"


struct ClaraBell cb = {
    .linelen = 0, .mcmdlen = 0, .vcmdlen = 0, .scmdlen = 0,
    .d0 = 0, .d1 = 0, .d2 = 0, .d3 = 0, .prox = 0,
    .lencoder = 0, .rencoder=0,
    .last_speed = SPEED_NONE, .last_dir=DIR_NONE,
    .last_offset=SPEED_OFF_NONE, .last_div = DIV_NONE,
    .cstate = DISCONNECTED,
    .volumeInit = 0,
};



