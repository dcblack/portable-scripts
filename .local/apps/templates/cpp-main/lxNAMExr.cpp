/** @brief {:BRIEF:}
 *
 * {:LONGER-DESCRIPTION:}
 */

#if __cplusplus < 201703L /* Verify minimum C++ */
#error Requires at least C++17
#endif

#include "{:lc:NAME:}.hpp" /*< {:** DELETE IF NOT USED **:} */
//{:PROJECT_INCLUDES_HERE:} {:** DELETE IF NOT USED **:}
#include <string>
#include <iostream>
#include <iomanip>
#include <fmt/format.h>

using namespace std::literals;

int main( [[maybe_unused]]int argc, [[maybe_unused]]const char* argv[] )
{
  size_t status{ 0 };

  //{:BODY_HERE:}

  if ( status == 0 ) std::cout << "Success" << std::endl;
  else               std::cout << "FAILURE" << std::endl;
  return status?1:0;
}

///////////////////////////////////////////////////////////////////////////////
// Copyright {:YEAR:} by {:COMPANY:}. All rights reserved.
//END {:FILE:} {:Id:}
