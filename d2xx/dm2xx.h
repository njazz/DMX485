//
//  dm2xx.h
//
//
//  Created by Alex Nadzharov on 29/05/14.
//  Copyright (c) 2014 Alex Nadzharov. All rights reserved.
//

//  Max version

//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.

#import "ftd2xx.h"
#import <Foundation/Foundation.h>

#import <Cocoa/Cocoa.h>

#import <dispatch/base.h>
#import <dispatch/dispatch.h>
#import <dispatch/queue.h>

#include "ext.h"

@interface dm2xx : NSObject

{

    __block FT_HANDLE dmxPointer;

    FT_STATUS ftdiPortStatus;

    int tempV;

    __block unsigned char dmx_data[512];

    dispatch_source_t auto_timer;

    //
    long mClass;

    unsigned char deviceNumber;

    // device info
    FT_DEVICE ftDevice;
    LPDWORD ftDeviceID;
    PCHAR ftSerialNumber;
    PCHAR ftDeviceDescription;

    BOOL autoConnect;

    const void* timerBlock;

    NSThread* dThread;
    BOOL threadOn;
    int threadAction;
}

@property (nonatomic) long mClass;

- (void)dmx_enable:(bool)yesorno;
- (void)dmx_refresh;
- (void)dmx_set_channel:(unsigned int)channel value:(unsigned char)value;

- (void)dmx_select_device:(unsigned char)index;
- (void)dmx_set_auto_connect:(BOOL)value;

- (int)getDeviceCount;
- (void)getDeviceNameForIndex:(long int)index toString:(char*)Buffer;

@end
