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
    
#pragma mark connection timer
    
    if (!auto_timer)
    {
        
        // connection
        auto_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
        dispatch_source_set_timer(auto_timer, DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC, 0.5 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(auto_timer, ^{
            
            if (autoConnect) {
                
                //[self connect];
                
            }
            
        });
        
        dispatch_resume(auto_timer);
        dispatch_retain(auto_timer);
        
    }
    
    return self;
}

-(void (^)(void))dmx_block

{
    return Block_copy( ^(void)
                      {
                          __block FT_HANDLE qdmxPointer = dmxPointer;
                          
                          if ( (qdmxPointer>0) )
                          {
                              
                              {
                                  
                                  __block DWORD bytesWrittenOrRead;
                                  __block unsigned char start;
                                  
                                  start = 0;
                                  
                                  __block DWORD s1 = 1;
                                  __block DWORD s2 = 512;
                                  
                                  
                                  __block FT_STATUS qftdiPortStatus;
                                  __block unsigned char qdmx_data[512], *pqdmx_data;
                                  for (int i=0;i<512;i++) qdmx_data[i]=dmx_data[i];
                                  pqdmx_data=qdmx_data;
                                  
#pragma mark data timer
                                  
                                  qftdiPortStatus = -1;
                                  
                                  if (qdmxPointer!=0)
                                  {
                                      
                                      FT_SetBreakOff(qdmxPointer);
                                      qftdiPortStatus = FT_Write((qdmxPointer), &start, s1, &bytesWrittenOrRead);
                                      qftdiPortStatus = FT_Write((qdmxPointer), pqdmx_data, s2, &bytesWrittenOrRead);
                                      FT_SetBreakOn(qdmxPointer);
                                      qftdiPortStatus = FT_Purge(qdmxPointer, FT_PURGE_RX | FT_PURGE_TX);
                                      
                                  }
                                  
                                  if (qftdiPortStatus!=FT_OK)
                                  {
                                      [self disconnect];
                                  }
                              }
                          }
                      });
}

-(void) connect
{
    
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
            NSLog(@"dmx485: connecting...");
            
            FT_HANDLE tdmxPointer=NULL;
            
            ftdiPortStatus = FT_Open(deviceNumber,&tdmxPointer);
            //NSLog(@"open");
            
            if (ftdiPortStatus != FT_OK)
            {
                NSLog(@"Electronics error: Can't open USB device: %d", (int)ftdiPortStatus);
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
            //            NSLog(@"dmx485: USB device is not connected");
            return;
        }
        
    }
    else
    {
        //object_error(self.mClass, "dmx485: no USB device found");
        return;
    }
}

-(void) disconnect
{
    
    if (dmxPointer!=0)
    {
        
        dispatch_queue_t cqueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_group_t cgroup = dispatch_group_create();
        
        dispatch_group_async(cgroup,cqueue,^{
            
            FT_HANDLE cPointer = dmxPointer;
            ftdiPortStatus = FT_Close(cPointer);
            
        });
        
        dispatch_group_notify(cgroup,cqueue,^{
            
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
                NSLog(@"dmx485: disconnected");
                
            }
            
        });
        
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
    
    FT_ListDevices((PVOID)index,&Buffer,FT_LIST_BY_INDEX|FT_OPEN_BY_DESCRIPTION);
    
}


#pragma mark -
#pragma mark basic public functions

- (void) dmx_select_device:(unsigned char)index
{
    
    deviceNumber = index;
    
}
-(void) dmx_enable:(bool)yesorno
{
    
    dispatch_suspend(auto_timer);
    
    if (dmx_timer)
    {
        NSLog(@"timer cancel");
        dispatch_source_cancel(dmx_timer);
        dispatch_release(dmx_timer);
        dmx_timer = nil;
    }
    
    if (yesorno)
    {
        NSLog(@"starting serial port");
        
        
        
        if (dmxPointer==0)
        {
            
            dispatch_queue_t cqueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
            dispatch_group_t cgroup = dispatch_group_create();
            
            dispatch_group_async(cgroup,cqueue,^{
                
                [self connect];
                
            });
            
            dispatch_group_notify(cgroup,cqueue,^{
                
                NSLog(@"setting timer");
                
                dmx_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
                dispatch_source_set_timer(dmx_timer, DISPATCH_TIME_NOW, 1/20 * NSEC_PER_SEC, 1/20 * NSEC_PER_SEC);
                dispatch_source_set_event_handler(dmx_timer, [self dmx_block]);
                dispatch_resume(dmx_timer);
                
                NSLog(@"result %i",(dmxPointer>0));
                
            });
            
            
            
        }
    }
    else
    {
        
        [self disconnect];//[self performSelectorOnMainThread:@selector(disconnect) withObject:nil waitUntilDone:YES];
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

-(void) dmx_set_auto_connect:(BOOL)yesorno
{
    autoConnect = yesorno;
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

void runHigh(void (^block)(void))
{
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, nil), block);
}

@end
