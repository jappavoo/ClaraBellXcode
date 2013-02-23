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

enum CB_CONNECTION   { DISCONNECTED=0, CONNECTING, CONNECTED };
enum CB_DIRECTION    { DIR_NONE=-1, FORWARD='F', BACKWARD='B', LEFT='L', RIGHT='R' };
enum CB_MOTION_TYPE  { BEGIN='B', CHANGE='C', END='E' };
enum CB_SPEED        { SNONE=-1, S0=0, S1=1, S2=2, S3=3, S4=4, S5=5, S6=6, S7=7, S8=8, S9=9};
enum CB_SPEED_OFFSET { SOFFNONE=-1, SOFF0=0, SOFF1=1, SOFF2=2, SOFF3=3, SOFF4=4 };

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
    int     lencoder, rencoder;
    enum CB_CONNECTION cstate;
    int  volumeInit;
    enum CB_DIRECTION last_dir;
    enum CB_SPEED last_speed;
    enum CB_SPEED_OFFSET last_offset;
};

extern struct ClaraBell cb;

#endif
