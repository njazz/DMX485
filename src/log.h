#include <functional>
#include <string>
#include <vector>

class DMXLog {
    std::vector<std::function<void(std::string)> > _msgActions;
    std::vector<std::function<void(std::string)> > _errorActions;

public:
    void addMsgAction(std::function<void(std::string)> a) { _msgActions.push_back(a); };
    void addErrorAction(std::function<void(std::string)> a) { _errorActions.push_back(a); };

    void msg(std::string v)
    {
        printf("%s", v.c_str());
        for (auto a : _msgActions)
            a(v);
    };

    void errorMsg(std::string v)
    {
        printf("ERROR: %s", v.c_str());
        for (auto a : _errorActions)
            a(v);
    };
};
