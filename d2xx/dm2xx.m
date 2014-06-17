//
//  dm2xx.m
//  d2xx dmx
//
//  Created by Alex Nadzharov on 29/05/14.
//  Copyright (c) 2014 Alex Nadzharov. All rights reserved.
//
//
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

#import "dm2xx.h"

@implementation dm2xx

@synthesize mClass;

#pragma mark i/o

-(void) connect
{
//    DWORD numDevs = 0;
//    // Grab the number of attached devices
//    
//    
//    ftdiPortStatus = FT_ListDevices(&numDevs, NULL, FT_LIST_NUMBER_ONLY);
//    if (ftdiPortStatus != FT_OK)
//    {
//        NSLog(@"dmx485 error: Unable to list devices");
//        
//        object_error(self.mClass,"dmx485: unable to list devices");
//        
//        return;
//    }
//
    
    //dmxQueue = dispatch_queue_create("dmxQueue",NULL);
    //dispatch_queue_set_specific(dmxQueue, DISPATCH_QUEUE_PRIORITY_HIGH, NULL, NULL);
    
    DWORD numDevs = [self getDeviceCount];
    // Find the device number of the electronics
    for (long int currentDevice = 0; currentDevice < numDevs; currentDevice++)
    {
        char Buffer[64];
        [self getDeviceNameForIndex:currentDevice toString:(char *)&Buffer];    //sort of
        
        NSString *portDescription = [NSString stringWithCString:Buffer encoding:NSASCIIStringEncoding];
        NSLog(@"port name: %@",portDescription);
        
        //object_post(self.mClass, [[NSString stringWithFormat:@"port name: %@",portDescription] charValue]);
        
        
        
        if ( ([portDescription isEqualToString:@"FT232R USB UART"]) && (dmxPointer == NULL))
        {
            // Open the communication with the USB device
            
            object_post(self.mClass, "dmx485: connecting...");
            
            //ftdiPortStatus = FT_OpenEx("FT232R USB UART",FT_OPEN_BY_DESCRIPTION,dmxPointer);
            
            ftdiPortStatus = FT_Open(0,&dmxPointer);
            
            if (ftdiPortStatus != FT_OK)
            {
                NSLog(@"Electronics error: Can't open USB device: %d", (int)ftdiPortStatus);
                
                //object_error(self.mClass, "Electronics error: Can't open USB device");
                return;
            }
            //Turn off bit bang mode
            ftdiPortStatus = FT_SetBitMode(dmxPointer, 0x00,0);
            
            if (ftdiPortStatus != FT_OK)
            {
                NSLog(@"Electronics error: Can't set bit bang mode");
                return;
            }
            // Reset the device
            ftdiPortStatus = FT_ResetDevice(dmxPointer);
            // Purge transmit and receive buffers
            ftdiPortStatus = FT_Purge(dmxPointer, FT_PURGE_RX | FT_PURGE_TX);
            // Set the baud rate
            ftdiPortStatus = FT_SetBaudRate(dmxPointer, 250000);
            if (ftdiPortStatus != FT_OK)
            {
                NSLog(@"Electronics error: Can't set baud rate");
                //object_error(self.mClass, "Electronics error: Can't set baud rate");
                return;
            }
            
            // 1 s timeouts on read / write
            ftdiPortStatus = FT_SetTimeouts(dmxPointer, 1000, 1000);
            // Set to communicate at 8N1
            ftdiPortStatus = FT_SetDataCharacteristics(dmxPointer, FT_BITS_8, FT_STOP_BITS_2, FT_PARITY_NONE); // 8N1
            // Disable hardware / software flow control
            ftdiPortStatus = FT_SetFlowControl(dmxPointer, FT_FLOW_NONE, 0, 0);
            
            
            FT_ClrRts(dmxPointer);
            
            // Set the latency of the receive buffer way down (2 ms) to facilitate speedy transmission
            ftdiPortStatus = FT_SetLatencyTimer(dmxPointer,2);
            if (ftdiPortStatus != FT_OK)
            {
                NSLog(@"Electronics error: Can't set latency timer");
                //object_error(self.mClass, "Electronics error: Can't set latency timer");
                return;
            }
            
            FT_W32_EscapeCommFunction(dmxPointer,CLRRTS);
            
            object_post(self.mClass, "dmx485: ok");
            
            
        }
        else
        {
            object_error(self.mClass, "dmx485: USB device is not connected");
        }
    }
    
}

-(void) disconnect
{
    
    
    ftdiPortStatus = FT_Close(dmxPointer);
    dmxPointer = 0;
    if (ftdiPortStatus != FT_OK)
    {
        NSLog(@"error disconnecting: %li", ftdiPortStatus);
        object_error(self.mClass, "dmx485: error disconnecting");
        return;
    }
    else
    {
        object_post(self.mClass, "dmx485: disconnected");
    }
    
    //dispatch_release(dmxQueue);
    
}

-(void) sendData
{
    
    __block DWORD bytesWrittenOrRead;
    __block unsigned char start;
    
    start = 0;
    
    FT_SetBreakOff(dmxPointer);
    
    runOnMainQueueWithoutDeadlocking(^{
        
        
        DWORD s1 = 1;
        DWORD s2 = 512;
        
        FT_SetBreakOff(dmxPointer);
        
        ftdiPortStatus = FT_Write((dmxPointer), &start, s1, &bytesWrittenOrRead);
        ftdiPortStatus = FT_Write((dmxPointer), &dmx_data, s2, &bytesWrittenOrRead);
        
        FT_SetBreakOn(dmxPointer);
        
        ftdiPortStatus = FT_Purge(dmxPointer, FT_PURGE_RX | FT_PURGE_TX);
        
    });
    
}

#pragma mark -

-(int) getDeviceCount
{

    DWORD numDevs=0;
    ftdiPortStatus = FT_ListDevices(&numDevs, NULL, FT_LIST_NUMBER_ONLY);
    if (ftdiPortStatus != FT_OK)
    {
        NSLog(@"dmx485 error: Unable to list devices");
        
        object_error(self.mClass,"dmx485: unable to list devices");
        
        return -1;
    }
    else
        return numDevs;
}

-(void) getDeviceNameForIndex:(long int)index toString:(char*)Buffer
{
    
    ftdiPortStatus = FT_ListDevices((PVOID)index,Buffer,FT_LIST_BY_INDEX|FT_OPEN_BY_DESCRIPTION);

}


#pragma mark -
#pragma mark basic functions

-(void) dmx_enable:(bool)yesorno
{
    if (yesorno)
    {
        if (!dmx_timer)
        {
            [self connect];
            
            
            timer1 = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
            dispatch_source_set_timer(timer1, DISPATCH_TIME_NOW, 1/60 * NSEC_PER_SEC, 1/60 * NSEC_PER_SEC);
            dispatch_source_set_event_handler(timer1, ^{
                [self sendData];
            });
            dispatch_resume(timer1);
            
            //NSTimer version
            
            //            dmx_timer = [NSTimer scheduledTimerWithTimeInterval:1/30 target:self selector:@selector(sendData) userInfo:nil repeats:YES];
            //
            //            [[NSRunLoop mainRunLoop] addTimer:dmx_timer forMode:NSRunLoopCommonModes];
            
            NSLog(@"starting serial port");
            
        }
        
        
    }
    else
    {
        dispatch_source_cancel(timer1);
//        [dmx_timer invalidate];
//        dmx_timer = nil;
        [self disconnect];
        NSLog(@"stopped serial port");
    }
}

-(void) dmx_set_channel:(unsigned int) channel value:(unsigned char)value
{
    
    if ( (channel<513) )
    {
        dmx_data[channel] = value;
    }
}

#pragma mark -
#pragma mark utilities

void runOnMainQueueWithoutDeadlocking(void (^block)(void))
{
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

@end
