//
//  dm2xx.h
//
//
//  Created by Alex Nadzharov on 04/02/17.
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

#include <stdio.h>
#include <string>

#import "ftd2xx.h"

//TODO FIX
#include "../MaxSDK-6.1.4/c74support/max-includes/ext.h"

//temp while both obj-c & c++
//typedef int BOOL;
//typedef DWORD FT_HANDLE typedef unsigned int FT_HANDLE;
//typedef struct ftdi_device* FT_HANDLE;

#include "pthread.h"

class dm2xx {
private:
    FT_HANDLE dmxPointer;

    FT_STATUS ftdiPortStatus;

    //int tempV;

    unsigned char dmx_data[512];

    // todo thread
    //dispatch_source_t auto_timer;

    unsigned char deviceNumber;

    // device info
    FT_DEVICE ftDevice;
    LPDWORD ftDeviceID;
    PCHAR ftSerialNumber;
    PCHAR ftDeviceDescription;

    BOOL autoConnect;

    //thread:

    //const void* timerBlock;

    pthread_t dThread;
    //NSThread* dThread;
    bool threadOn;
    int threadAction;

    //int getDeviceCount();
    //#pragma mark internal

    dm2xx()
    {
        printf("--->    object init");

        deviceNumber = 0;

        ftDeviceID = NULL;
        ftSerialNumber = NULL;
        ftDeviceDescription = NULL;

        for (int i = 0; i < 512; i++)
            dmx_data[i] = 0;

        dmxPointer = 0;

        printf("--");

        pthread_create(&this->dThread, NULL, &dm2xx::thread, NULL);
        //todo thread
        //        dThread = [[NSThread alloc] initWithTarget:self selector:@selector(dmx_thread) object:nil];
        //        [dThread setThreadPriority:0.85];
        //        [dThread start];
    }
    dm2xx(dm2xx const&){};
    void operator=(dm2xx const&){};

#pragma mark main actions

    void connect_stage1()
    {
        // connect section 1 - open device

        {
            printf(" *** connect 1");

            DWORD numDevs = this->getDeviceCount();

            if ((numDevs > 0) && (dmxPointer == NULL)) {
                char Buffer[64] = "FT232R USB UART";
                printf("dmx485: connecting to device: %i", deviceNumber);

                //[self getDeviceNameForIndex:deviceNumber toString:(char *)&Buffer];    //sort of
                //FT_STATUS f1 = FT_ListDevices(deviceNumber,Buffer,FT_LIST_BY_INDEX|FT_OPEN_BY_DESCRIPTION);

                std::string portDescription = Buffer; //[NSString stringWithCString:Buffer encoding:NSASCIIStringEncoding];
                printf("port name: %s", portDescription.c_str());
                //object_post(this->mClass, [[NSString stringWithFormat:@"port name: %s",portDescription] charValue]);

                if ((portDescription == "FT232R USB UART") && (dmxPointer == NULL)) {

                    object_post(this->mClass, "dmx485: connecting...");

                    FT_HANDLE tdmxPointer = NULL;
                    int idx = deviceNumber;

                    printf("idx p %i %li %li", idx, &tdmxPointer, tdmxPointer);

                    FT_STATUS cftdiPortStatus;

                    cftdiPortStatus = FT_Open(idx, &tdmxPointer);
                    printf("open");

                    if (ftdiPortStatus != FT_OK) {
                        printf("Electronics error: Can't open USB device: %d", (int)ftdiPortStatus);
                        dmxPointer = 0;
                        return;
                    }

                    ftdiPortStatus = FT_SetBitMode(tdmxPointer, 0x00, 0);
                    if (ftdiPortStatus != FT_OK) {
                        printf("Electronics error: Can't set bit bang mode");
                        dmxPointer = 0;
                        return;
                    }

                    // reset etc.
                    ftdiPortStatus = FT_ResetDevice(tdmxPointer);
                    ftdiPortStatus = FT_Purge(tdmxPointer, FT_PURGE_RX | FT_PURGE_TX);
                    ftdiPortStatus = FT_SetBaudRate(tdmxPointer, 250000);

                    if (ftdiPortStatus != FT_OK) {
                        printf("Electronics error: Can't set baud rate");
                        dmxPointer = 0;
                        return;
                    }

                    // settings
                    ftdiPortStatus = FT_SetTimeouts(tdmxPointer, 1000, 1000);
                    ftdiPortStatus = FT_SetDataCharacteristics(tdmxPointer, FT_BITS_8, FT_STOP_BITS_2, FT_PARITY_NONE); // 8N1
                    ftdiPortStatus = FT_SetFlowControl(tdmxPointer, FT_FLOW_NONE, 0, 0);
                    FT_ClrRts(tdmxPointer);

                    ftdiPortStatus = FT_SetLatencyTimer(tdmxPointer, 2);
                    if (ftdiPortStatus != FT_OK) {
                        printf("Electronics error: Can't set latency timer");
                        dmxPointer = 0;
                        return;
                    }

                    FT_W32_EscapeCommFunction(tdmxPointer, CLRRTS);

                    FT_GetDeviceInfo(tdmxPointer, &ftDevice, ftDeviceID, ftSerialNumber, ftDeviceDescription, NULL);

                    object_post(this->mClass, "dmx485: ok");
                    printf("dmx485: ok");

                    dmxPointer = tdmxPointer;
                    return;

                } else {
                    //            object_error(this->mClass, "dmx485: USB device is not connected");
                    printf("dmx485: USB device is not connected");
                    dmxPointer = 0;
                    return;
                }

            } else {
                object_error(this->mClass, "dmx485: no USB device found");
                printf("dmx485: no USB device found");
                dmxPointer = 0;
                return;
            }
        }
        //);
    }

    void connect_stage2()
    {

        if (dmxPointer > 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

                printf("setting timer");

                printf("result %li", dmxPointer);

                //this->threadOn = true;

            });
        }
    }

    void disconnect()
    {
        {
            threadOn = false;

            FT_HANDLE cPointer = dmxPointer;

            if (cPointer != NULL) {
                ftdiPortStatus = FT_Close(cPointer);
            } else {
                ftdiPortStatus = FT_OK;
            }

            if (ftdiPortStatus != FT_OK) {
                printf("error disconnecting: %li", ftdiPortStatus);
                object_error(this->mClass, "dmx485: error disconnecting");

            } else {
                dmxPointer = 0;
                object_post(this->mClass, "dmx485: disconnected");
                printf("dmx485: disconnected");
            }
        }
        //);
    }

#pragma mark -

    static void* thread(void*)
    {
        while (true) {

            dm2xx obj = dm2xx::instance();

            if (obj.threadAction == 1) {
                obj.threadAction = 0;
                obj.connect_stage1();
                obj.connect_stage2();
            }

            if (obj.threadAction == 2) {
                obj.threadAction = 0;
                obj.disconnect();
            }

            if (obj.threadAction == 3) {
                obj.threadOn = 0;

                obj.disconnect();
                obj.threadAction = 0;

                //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

                usleep(10000);

                obj.threadAction = 1;
                //});
            }

            if (obj.threadOn)
                obj.timer_action();

            usleep(50000);
            //[NSThread sleepForTimeInterval:1 / 50 * NSEC_PER_SEC];
        }
    }

#pragma mark -

    void timer_action()
    {
        FT_HANDLE qDmxPointer = this->dmxPointer; //[self get_dmx_pointer];

        if ((qDmxPointer > 0)) {

            {

                DWORD bytesWrittenOrRead;
                unsigned char start;

                start = 0;

                DWORD s1 = 1;

                //todo packet size
                DWORD s2 = 512;

                FT_STATUS qftdiPortStatus;

                qftdiPortStatus = -1;

                if (dmxPointer != 0) {

                    FT_SetBreakOff(qDmxPointer);
                    qftdiPortStatus = FT_Write((qDmxPointer), &start, s1, &bytesWrittenOrRead);
                    qftdiPortStatus = FT_Write((qDmxPointer), &dmx_data, s2, &bytesWrittenOrRead);

                    FT_SetBreakOn(dmxPointer);
                    qftdiPortStatus = FT_Purge(qDmxPointer, FT_PURGE_RX | FT_PURGE_TX);
                }

                if (qftdiPortStatus != FT_OK) {
                    // todo
                }
            }
        }
    }

public:
    //
    static dm2xx& instance()
    {
        static dm2xx instance;
        return instance;
    }

    t_object* mClass;

#pragma mark -

#pragma mark basic public functions

    int getDeviceCount()
    {

        DWORD numDevs = 0;
        FT_HANDLE iftdiPortStatus = FT_ListDevices(&numDevs, NULL, FT_LIST_NUMBER_ONLY);

        //TODO: move to object
        if (iftdiPortStatus != FT_OK) {
            printf("dmx485 error: Unable to list devices");

            object_error(this->mClass, "dmx485: unable to list devices");

            return -1;
        } else
            return numDevs;
    }

    void getDeviceNameForIndex(long int index, char* Buffer)
    {
        //char * tempBuffer = malloc(64);

        FT_ListDevices((PVOID)index, Buffer, FT_LIST_BY_INDEX); //|FT_OPEN_BY_DESCRIPTION

        printf("device name: %s", Buffer);

        //Buffer = tempBuffer;
    }

    void select_device(unsigned char index)
    {
        this->deviceNumber = index;
    }

    void enable(bool yesorno)
    {

        if (yesorno) {
            printf("starting serial port");

            if (this->dmxPointer == 0) {

                this->threadAction = 1;
            }
        }

        else

        {
            this->threadAction = 2;

            printf("stopped serial port");
        }
    }

    void refresh()
    {
        printf("--refresh");

        this->threadAction = 3;
    }

#pragma mark setters

    void set_channel(unsigned int channel, unsigned char value)
    {

        if ((channel < 513)) {
            this->dmx_data[channel] = value;
        }
    }

    void set_auto_connect(bool yesorno)
    {
        this->autoConnect = yesorno;
    }
};
