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

    FT_HANDLE dmxPointer;
    
    FT_STATUS ftdiPortStatus;
    
    int tempV;
    
    unsigned char dmx_data[512];
    
    NSTimer *dmx_timer;
    
    //
    long mClass;

}

//-(void) connect;
//-(void) sendData;

@property (nonatomic) long mClass;

-(void) dmx_enable:(bool)yesorno;
-(void) dmx_set_channel:(unsigned int) channel value:(unsigned char)value;





@end
