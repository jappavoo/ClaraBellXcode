//
//  ClaraBell.h
//  ClaraBell
//
//  Created by Jonathan Appavoo on 2/17/13.
//  Copyright (c) 2013 Jonathan Appavoo. All rights reserved.
//

#ifndef ClaraBell_ClaraBell_h
#define ClaraBell_ClaraBell_h

#define CB_SENSOR_MAX_DISTANCE 200

#define CB_LINELEN 4096
#define CB_CMDLEN  4096

#define CB_RIGHT_PROX_BIT 0
#define CB_FRONT_PROX_BIT 1
#define CB_LEFT_PROX_BIT  2
#define CB_BACK_PROX_BIT  3

enum CB_CONNECTION { DISCONNECTED=0, CONNECTING, CONNECTED};
enum CB_DIRECTION {NONE=0, FORWARD, BACKWARD, LEFT, RIGHT};
enum CB_SPEED {S0=0, S1=1, S2=2, S3=3, S4=4, S5=5, S6=6, S7=7, S8=8, S9=9, S10=10};

extern char *DIRCMDS[5];
extern char *SPEEDCMDS[11];

struct ClaraBell {
    char line[CB_LINELEN];
    char mcmd[CB_CMDLEN];
    char vcmd[CB_CMDLEN];
    char scmd[CB_CMDLEN];
    
    int     linelen;
    int     mcmdlen;
    int     vcmdlen;
    int     scmdlen;
    
    int     d0,d1,d2,d3,prox;
    enum CB_CONNECTION cstate;
    enum CB_DIRECTION dir;
    enum CB_SPEED speed;
};

extern struct ClaraBell cb;


static inline void
cb_reset_mcmd()
{
    cb.mcmd[0]='M';
    cb.mcmdlen=1;
}

static inline void
cb_mcmd_set_symetric_speed(enum CB_SPEED s)
{
}

static inline void
cb_mcmd_set_rotational_direction(enum CB_DIRECTION d)
{
}

static inline int
cb_mcmd_close(void)
{
    if (cb.mcmdlen >= CB_CMDLEN) return -1;
    if (cb.mcmd[0]!='M') return -1;
    cb.mcmd[cb.mcmdlen]='\n';
    cb.mcmdlen++;
    return 0;
}


static inline void
cb_reset_scmd()
{
    cb.scmd[1]='S';
    cb.scmdlen=1;
}

static inline void
cb_reset_vcmd()
{
    cb.vcmd[0]='V';
    cb.vcmdlen=1;
}

#endif
