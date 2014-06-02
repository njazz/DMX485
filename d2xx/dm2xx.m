//
//  dm2xx.m
//  d2xx dmx test
//
//  Created by Alex Nadzharov on 29/05/14.
//  Copyright (c) 2014 Alex Nadzharov. All rights reserved.
//

#import "dm2xx.h"

@implementation dm2xx

@synthesize mClass;

-(void) connect
{
DWORD numDevs = 0;
// Grab the number of attached devices
    
        
ftdiPortStatus = FT_ListDevices(&numDevs, NULL, FT_LIST_NUMBER_ONLY);
if (ftdiPortStatus != FT_OK)
{
    NSLog(@"Electronics error: Unable to list devices");
    
    object_error(self.mClass,"Electronics error: Unable to list devices");
    
    return;
}

// Find the device number of the electronics
for (long int currentDevice = 0; currentDevice < numDevs; currentDevice++)
{
    char Buffer[64];
    ftdiPortStatus = FT_ListDevices((PVOID)currentDevice,Buffer,FT_LIST_BY_INDEX|FT_OPEN_BY_DESCRIPTION);
    NSString *portDescription = [NSString stringWithCString:Buffer encoding:NSASCIIStringEncoding];
    
    NSLog(@"port name: %@",portDescription);
    
    //object_post(self.mClass, [[NSString stringWithFormat:@"port name: %@",portDescription] charValue]);
    
    
    
    if ( ([portDescription isEqualToString:@"FT232R USB UART"]) && (dmxPointer == NULL))
    {
        // Open the communication with the USB device
        
        object_post(self.mClass, "DMX485: connecting...");
        
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
    
        object_post(self.mClass, "DMX485: ok");

        
    }
    else
    {
        object_error(self.mClass, "DMX485: USB device is not connected");
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
        object_error(self.mClass, "DMX485: error disconnecting");
        return;
    }
    else
    {
    object_post(self.mClass, "DMX485: disconnected");
    }
    
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


-(void) dmx_enable:(bool)yesorno
{
    if (yesorno)
    {
        if (!dmx_timer)
        {
            [self connect];
            
            dmx_timer = [NSTimer scheduledTimerWithTimeInterval:1/30 target:self selector:@selector(sendData) userInfo:nil repeats:YES];
            
            [[NSRunLoop mainRunLoop] addTimer:dmx_timer forMode:NSRunLoopCommonModes];

            NSLog(@"starting serial port");
            
        }
        
        
    }
    else
    {
        [dmx_timer invalidate];
        dmx_timer = nil;
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

@end
