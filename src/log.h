#include <string>

class DMXLog
{
public:
  void registerObserver();

    void post(std::string v);
    void error(std::string v);
};
