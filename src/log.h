#include <string>

class DMXLog {
public:
    void registerObserver(){};

    void msg(std::string v) { printf("%s", v.c_str()); };
    void errorMsg(std::string v){ printf("ERROR: %s", v.c_str()); };
};
