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

//@synthesize isConnected = isConnected;

#pragma mark -
#pragma mark i/o

-(id) init
{
    NSLog(@"--->    object init");
    
    deviceNumber = 0;
    
    ftDeviceID = NULL;
    ftSerialNumber = NULL;
    ftDeviceDescription = NULL;
    
    for (int i=0;i<512;i++) dmx_data[i]=0;
    
    dmxPointer = 0;
    
    NSLog(@"--");
    
    
    dThread = [[NSThread alloc] initWithTarget:self selector:@selector(dmx_thread) object:nil];
    [dThread setThreadPriority:0.85];
    [dThread start];
    
    return self;
}

#pragma mark -

-(void) dmx_thread
{
    while(YES)
    {
        
        if (threadAction==1)
        {
            threadAction=0;
            [self b_connect_1];
            [self b_connect_2];
            
        }
        
        if (threadAction==2)
        {
            threadAction=0;
            [self b_disconnect_1];
            
            
        }
        
        if (threadAction==3)
        {
            threadOn = 0;
            
            [self b_disconnect_1];
            threadAction = 0;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    
                threadAction = 1;
});
            
            
            
            
            
        }
        

        
        if(threadOn) [self dmx_timer_action];
        
        [NSThread sleepForTimeInterval:1/50 * NSEC_PER_SEC];
        
    }
}

#pragma mark -


-(FT_HANDLE) get_dmx_pointer
{
    @synchronized (self) { return dmxPointer; }
}


#pragma mark -

-(void) dmx_timer_action
{
    FT_HANDLE qDmxPointer = [self get_dmx_pointer];
    
    if ( (qDmxPointer>0) )
    {
        
        {
            
            DWORD bytesWrittenOrRead;
            unsigned char start;
            
            start = 0;
            
            DWORD s1 = 1;
            
            //todo packet size
            DWORD s2 = 512;
            
            FT_STATUS qftdiPortStatus;
            
            qftdiPortStatus = -1;
            
            if (dmxPointer!=0)
            {
                
                FT_SetBreakOff(qDmxPointer);
                qftdiPortStatus = FT_Write((qDmxPointer), &start, s1, &bytesWrittenOrRead);
                qftdiPortStatus = FT_Write((qDmxPointer), &dmx_data, s2, &bytesWrittenOrRead);
                
                FT_SetBreakOn(dmxPointer);
                qftdiPortStatus = FT_Purge(qDmxPointer, FT_PURGE_RX | FT_PURGE_TX);
                
            }
            
            if (qftdiPortStatus!=FT_OK)
            {
                // todo
                
            }
        }
    }
    
}

#pragma mark -

-(int) getDeviceCount
{
    
    DWORD numDevs=0;
    FT_HANDLE iftdiPortStatus = FT_ListDevices(&numDevs, NULL, FT_LIST_NUMBER_ONLY);
    if (iftdiPortStatus != FT_OK)
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
    //char * tempBuffer = malloc(64);
    
    FT_ListDevices((PVOID)index,Buffer,FT_LIST_BY_INDEX); //|FT_OPEN_BY_DESCRIPTION
    
    NSLog(@"device name: %s", Buffer);
    
    //Buffer = tempBuffer;
    
}


#pragma mark -
#pragma mark basic public functions

- (void) dmx_select_device:(unsigned char)index
{
    deviceNumber = index;
}

-(void) dmx_enable:(bool)yesorno
{
    
    if (yesorno)
    {
        NSLog(@"starting serial port");
        
        if (dmxPointer==0)
        {
            
            threadAction = 1;
            
            
        }
    }
    
    else
        
    {
        threadAction = 2;
        
        NSLog(@"stopped serial port");
        
    }
}

-(void) dmx_refresh
{
    NSLog(@"--refresh");
    
    threadAction = 3;
}


-(void) dmx_set_channel:(unsigned int) channel value:(unsigned char)value
{
    
    if ( (channel<513) )
    {
        dmx_data[channel] = value;
    }
    
}

-(void) dmx_set_auto_connect:(BOOL)yesorno
{
    autoConnect = yesorno;
}


#pragma mark -

-(void) b_connect_1
{
    // connect section 1 - open device
    
    {
        NSLog(@" *** connect 1");
        
        DWORD numDevs = [self getDeviceCount];
        
        if ( (numDevs>0)&&(dmxPointer == NULL) )
        {
            char Buffer[64] = "FT232R USB UART";
            NSLog(@"dmx485: connecting to device: %i", deviceNumber);
            
            //[self getDeviceNameForIndex:deviceNumber toString:(char *)&Buffer];    //sort of
            //FT_STATUS f1 = FT_ListDevices(deviceNumber,Buffer,FT_LIST_BY_INDEX|FT_OPEN_BY_DESCRIPTION);
            
            NSString *portDescription = [NSString stringWithCString:Buffer encoding:NSASCIIStringEncoding];
            NSLog(@"port name: %@",portDescription);
            //object_post(self.mClass, [[NSString stringWithFormat:@"port name: %@",portDescription] charValue]);
            
            if ( ([portDescription isEqualToString:@"FT232R USB UART"]) && (dmxPointer == NULL))
            {
                
                object_post(self.mClass, "dmx485: connecting...");
                
                FT_HANDLE tdmxPointer=NULL;
                int idx = deviceNumber;
                
                NSLog(@"idx p %i %li %li", idx, &tdmxPointer, tdmxPointer);
                
                
                
                
                FT_STATUS cftdiPortStatus;
                
                cftdiPortStatus = FT_Open(idx,&tdmxPointer);
                NSLog(@"open");
                
                if (ftdiPortStatus != FT_OK)
                {
                    NSLog(@"Electronics error: Can't open USB device: %d", (int)ftdiPortStatus);
                    dmxPointer = 0;
                    return;
                }
                
                ftdiPortStatus = FT_SetBitMode(tdmxPointer, 0x00,0);
                if (ftdiPortStatus != FT_OK)
                {
                    NSLog(@"Electronics error: Can't set bit bang mode");
                    dmxPointer = 0;
                    return;
                }
                
                // reset etc.
                ftdiPortStatus = FT_ResetDevice(tdmxPointer);
                ftdiPortStatus = FT_Purge(tdmxPointer, FT_PURGE_RX | FT_PURGE_TX);
                ftdiPortStatus = FT_SetBaudRate(tdmxPointer, 250000);
                
                if (ftdiPortStatus != FT_OK)
                {
                    NSLog(@"Electronics error: Can't set baud rate");
                    dmxPointer = 0;
                    return;
                }
                
                // settings
                ftdiPortStatus = FT_SetTimeouts(tdmxPointer, 1000, 1000);
                ftdiPortStatus = FT_SetDataCharacteristics(tdmxPointer, FT_BITS_8, FT_STOP_BITS_2, FT_PARITY_NONE); // 8N1
                ftdiPortStatus = FT_SetFlowControl(tdmxPointer, FT_FLOW_NONE, 0, 0);
                FT_ClrRts(tdmxPointer);
                
                ftdiPortStatus = FT_SetLatencyTimer(tdmxPointer,2);
                if (ftdiPortStatus != FT_OK)
                {
                    NSLog(@"Electronics error: Can't set latency timer");
                    dmxPointer = 0;
                    return;
                }
                
                FT_W32_EscapeCommFunction(tdmxPointer,CLRRTS);
                
                FT_GetDeviceInfo(tdmxPointer, &ftDevice, ftDeviceID, ftSerialNumber, ftDeviceDescription, NULL);
                
                object_post(self.mClass, "dmx485: ok");
                NSLog(@"dmx485: ok");
                
                dmxPointer = tdmxPointer;
                return;
                
                
            }
            else
            {
                //            object_error(self.mClass, "dmx485: USB device is not connected");
                NSLog(@"dmx485: USB device is not connected");
                dmxPointer = 0;
                return;
            }
            
        }
        else
        {
            object_error(self.mClass, "dmx485: no USB device found");
            NSLog(@"dmx485: no USB device found");
            dmxPointer = 0;
            return;
        }
        
    }
    //);
    
}

-(void) b_connect_2
{
    
    if (dmxPointer>0)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            NSLog(@"setting timer");
            
            
            NSLog(@"result %li",*dmxPointer);
            
            threadOn = YES;
            
            
            
        });
    }
    
    
}


-(void) b_disconnect_1
{
    {
        threadOn = NO;
        
        
        FT_HANDLE cPointer = dmxPointer;
        
        if (cPointer!=NULL)
        {
            ftdiPortStatus = FT_Close(cPointer);
        }
        else
        {
            ftdiPortStatus = FT_OK;
        }
        
        if (ftdiPortStatus != FT_OK)
        {
            NSLog(@"error disconnecting: %li", ftdiPortStatus);
            object_error(self.mClass, "dmx485: error disconnecting");
            
        }
        else
        {
            dmxPointer = 0;
            object_post(self.mClass, "dmx485: disconnected");
            NSLog(@"dmx485: disconnected");
            
        }
        
    }
    //);
    
}




@end
