#include "log.h"

struct DMXImplementation;

// ---

class DMXObjectCore {

    unsigned char _data[512];
    unsigned char _deviceNumber;

    bool _autoConnect;
    bool _enabled;

    DMXImplementation* _impl = NULL;

public:
    bool extraDebug = false;
    DMXLog log;

    DMXObjectCore();
    ~DMXObjectCore();

    void connect();
    void disconnect();

    size_t deviceCount();
    std::string deviceNameAt(size_t idx);

    //
    void setEnabled(bool value);
    bool enabled();

    void setAutoConnect(bool value);
    bool autoConnect();

    void setDeviceNumber(size_t idx);
    unsigned int deviceNumber();

    void refresh();

    //
    void setChannel(unsigned int channel, unsigned char value);
};
