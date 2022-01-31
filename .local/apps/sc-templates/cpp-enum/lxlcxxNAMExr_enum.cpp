#include "{:lc:NAME:}_enum.hpp"
#include <algorithm>
#include <exception>

#define {:uc:NAME:}_KEY(_a) #_a,
namespace {
using cstr = const char * const;
cstr s_{:lc:NAME:}_str[] = {
  {:uc:NAME:}_ENUMS({:uc:NAME:}_KEY)
};
}
#undef KEY

//------------------------------------------------------------------------------
std::string str( const {:sc:NAME:}& elt )
{
  return s_{:lc:NAME:}_str[ static_cast<{:TYPE:}>( elt ) ];
}

//------------------------------------------------------------------------------
std::ostream& operator<<( std::ostream& os, const {:sc:NAME:}& rhs )
{
  os << str( rhs );
  return os;
}

//------------------------------------------------------------------------------
bool is_{:sc:NAME:}( const std::string& str ) noexcept
{
  int size = sizeof( s_{:lc:NAME:}_str ) / sizeof( char* );
  cstr* begin = s_{:lc:NAME:}_str;
  cstr* end = begin + size;
  cstr* ptr = find( begin, end, str );
  return (ptr != end);
}

namespace {
  class str_exception
  : public std::exception
  {
  public:
    str_exception( const char* msg ): m_msg(msg) {}
    const char* what() const noexcept { return m_msg; }
  private:
    const char* m_msg;
  };
}

//------------------------------------------------------------------------------
{:sc:NAME:} to_{:sc:NAME:}( const std::string& str )
{
  static str_exception e{ "{:sc:NAME:} out of bounds!" };
  int size = sizeof( s_{:lc:NAME:}_str ) / sizeof( char* );
  cstr* begin = s_{:lc:NAME:}_str;
  cstr* end = begin + size;
  cstr* ptr = find( begin, end, str );
  if( ptr==end ) throw e;
  return static_cast<{:sc:NAME:}>( ptr - begin );
}

//------------------------------------------------------------------------------
std::istream& operator>>( std::istream& is, {:sc:NAME:}& rhs )
{
  std::string str;
  is >> str;
  rhs = to_{:sc:NAME:}( str );
  return is;
}

// {:DELETE THE FOLLOWING IF YOU DON'T WANT BIST -- DELETE THIS LINE:}
#ifdef {:uc:NAME:}_ENUM_EXAMPLE
#include <sstream>
#include <iomanip>
int main()
{
  std::string input;
  std::istringstream is;
  {:sc:NAME:} vu, v0, v1, v2{ {:sc:NAME:}::{:ELT2:} };
  std::cout << "v1=" << v1 << std::endl;
  std::cout << "v2=" << v2 << std::endl;
  input = str( v2 );
  is.str( input );
  is >> v0;
  is.str("bad entry");
  is.seekg( 0, is.beg );
  try {
    is >> v0;
  }
  catch( std::exception& e ) {
    std::cout << "Successfully caught " << e.what() << std::endl;
  }
  std::cout << "{:sc:NAME:}s:" << std::endl;
  for( auto elt : {:sc:NAME:}() ) {
    std::cout << "   " << elt << std::endl;
  }
  // User testing
  do {
    std::cout << "Enter an enum name ('q' to quit): " << std::flush;
    std::cin >> input;
    size_t pos;
    if( not is_{:sc:NAME:}( input ) ) {
      if( input != "" ) std::cout << "Not a {:sc:NAME:}" << std::endl;
      continue;
    }
    is.str( input );
    is.seekg( 0, is.beg );
    v0 = vu;
    try {
      is >> v0;
    }
    catch( std::exception& e ) {
      std::cout << "Caught " << e.what() << std::endl;
    }
    std::cout << "Converted result of '" << input << "' is {:sc:NAME:}::" << v0 << std::endl;
  } while ( input != "q" );
  return 0;
}
#endif/*{:uc:NAME:}_ENUM_EXAMPLE*/

///////////////////////////////////////////////////////////////////////////////
// Copyright {:YEAR:} by {:COMPANY:}. All rights reserved.
//END {:FILE:} {:Id:}
