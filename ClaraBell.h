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
#define CB_MAX_IMAGE_BYTES (200 * 2024)

#define CB_RIGHT_PROX_BIT 0
#define CB_FRONT_PROX_BIT 1
#define CB_LEFT_PROX_BIT  2
#define CB_BACK_PROX_BIT  3

enum CB_CONNECTION   { DISCONNECTED=0, CONNECTING, CONNECTED };
enum CB_DIRECTION    { DIR_NONE=-1, FORWARD='F', BACKWARD='B', LEFT='L', RIGHT='R' };
enum CB_MOTION_TYPE  { BEGIN='B', CHANGE='C', END='E' };
enum CB_SPEED        { SPEED_NONE=-1, S0=0, S1=1, S2=2, S3=3, S4=4, S5=5, S6=6, S7=7, S8=8, S9=9};
enum CB_SPEED_OFFSET { SPEED_OFF_NONE=-1, SOFF0=0, SOFF1=1, SOFF2=2, SOFF3=3, SOFF4=4 };
enum CB_POLAR_DIVISION { DIV_NONE=-1, D0=0, D1=1, D2=2, D3=3, D4=4, D5=5, D6=6, D7=7,
    D8=8, D9=9, D10=10, D11=11, D12=12, D13=13, D1414, D15=15 };
#define CB_POLAR_DIVSIONS 16

extern char *DIRCMDS[5];
extern char *SPEEDCMDS[11];

struct ClaraBell {
    char image[CB_MAX_IMAGE_BYTES];
    char line[CB_LINELEN];
    char mcmd[CB_CMDLEN];
    char vcmd[CB_CMDLEN];
    char scmd[CB_CMDLEN];
    
    int     imagelenbytes;
    int     imagelen;
    int     imagebytes;
    
    int     linelen;
    int     mcmdlen;
    int     vcmdlen;
    int     scmdlen;
    
    int     d0,d1,d2,d3,prox;
    int     lencoder, rencoder;
    enum CB_CONNECTION cstate;
    int  volumeInit;
    int  imageInit;
    enum CB_DIRECTION last_dir;
    enum CB_SPEED last_speed;
    enum CB_SPEED_OFFSET last_offset;
    enum CB_POLAR_DIVISION last_div;
};

extern struct ClaraBell cb;

#endif
