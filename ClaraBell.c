//
//  ClaraBell.c
//  ClaraBell
//
//  Created by Jonathan Appavoo on 2/18/13.
//  Copyright (c) 2013 Jonathan Appavoo. All rights reserved.
//

#include <stdio.h>
#include "ClaraBell.h"


char *DIRCMDS[5] = { "H", "f", "b", "lbrf", "rblf" };
char *SPEEDCMDS[11] = { "-", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9" };

struct ClaraBell cb = {
    .linelen = 0, .mcmdlen = 0, .vcmdlen = 0, .scmdlen = 0,
    .d0 = 0, .d1 = 0, .d2 = 0, .d3 = 0, .prox = 0,
    .cstate = DISCONNECTED,
    .dir = NONE,
    .speed = S0
};

