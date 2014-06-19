//
//  dm2xx.h
//
//
//  Created by Alex Nadzharov on 29/05/14.
//  Copyright (c) 2014 Alex Nadzharov. All rights reserved.
//

//  Max version

#import <Foundation/Foundation.h>
#import "ftd2xx.h"


#import <Cocoa/Cocoa.h>

#import <dispatch/dispatch.h>
#import <dispatch/queue.h>
#import <dispatch/base.h>

#include "ext.h"


@interface dm2xx : NSObject

{
    //NSData *command;

    __block FT_HANDLE dmxPointer;
    
    FT_STATUS ftdiPortStatus;
    
    int tempV;
    
    __block unsigned char dmx_data[512];
    
    //NSTimer *dmx_timer;
    
    dispatch_source_t dmx_timer;
    dispatch_source_t auto_timer;
    dispatch_queue_t dmxQueue;
    
    //
    long mClass;
    
    unsigned char deviceNumber;
    
    // device info
    FT_DEVICE ftDevice;
    LPDWORD ftDeviceID;
    PCHAR ftSerialNumber;
    PCHAR ftDeviceDescription;
    
    
    
    
    
    BOOL autoConnect;
    
//    BOOL dmxEnabled;
//
//    __block BOOL isConnected;

}

//-(void) connect;
//-(void) sendData;

@property (nonatomic) long mClass;

//@property (atomic) BOOL isConnected;


-(void) dmx_enable:(bool)yesorno;
-(void) dmx_set_channel:(unsigned int) channel value:(unsigned char)value;

-(void) dmx_select_device:(unsigned char)index;
-(void) dmx_set_auto_connect:(BOOL)value;

-(int) getDeviceCount;
-(void) getDeviceNameForIndex:(long int)index toString:(char*)Buffer;

//-(void) connect;
//-(void) disconnect;








@end
