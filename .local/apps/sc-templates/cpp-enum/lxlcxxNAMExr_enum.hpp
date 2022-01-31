#ifndef {:uc:NAME:}_ENUM_HPP
#define {:uc:NAME:}_ENUM_HPP

#if __cplusplus < 201103L
  #error Requires C++11 or better
#endif

#include <cstdint>
#include <string>
#include <iostream>

//{:EDIT BELOW AND DELETE/COPY AS NEEDED -- DELETE THIS LINE:}
#define {:uc:NAME:}_ENUMS(ENUM)\
  ENUM( {:ELT0:}       )\
  ENUM( {:ELT1:}       )\
  ENUM( {:ELT2:}       )\
  ENUM( {:ELT3:}       )\
  ENUM( {:ELT4:}       )\
  ENUM( {:ELT5:}       )\
  ENUM( {:ELT6:}       )\
  ENUM( {:ELT7:}       )\
  ENUM( {:ELT8:}       )\
  ENUM( {:ELT9:}       )\
  ENUM( {:ELTA:}       )\
  ENUM( {:ELTB:}       )\
  ENUM( {:ELTC:}       )\
  ENUM( {:ELTD:}       )\
  ENUM( {:ELTE:}       )\
  ENUM( {:ELTF:}       )\
  ENUM( {:LAST:}       ) //< required

#define {:uc:NAME:}_KEY(_a) _a,
enum class {:sc:NAME:} : {:TYPE:} {
  {:uc:NAME:}_ENUMS({:uc:NAME:}_KEY)
  };
#undef {:uc:NAME:}_KEY

std::string str( const {:sc:NAME:}& elt );
bool is_{:sc:NAME:}( const std::string& str ) noexcept;
{:sc:NAME:} to_{:sc:NAME:}( const std::string& str );
std::ostream& operator<<( std::ostream& os, const {:sc:NAME:}& rhs );
std::istream& operator>>( std::istream& is, {:sc:NAME:}& rhs );
inline {:sc:NAME:} operator++({:sc:NAME:}& x) {
  return x = ({:sc:NAME:})(std::underlying_type<{:sc:NAME:}>::type(x) + 1); 
}
inline {:sc:NAME:} operator*({:sc:NAME:} c) {
  return c;
}
inline {:sc:NAME:} begin({:sc:NAME:} r) {
  return ({:sc:NAME:})std::underlying_type<{:sc:NAME:}>::type(0);
}
inline {:sc:NAME:} end({:sc:NAME:} r) {
  return {:sc:NAME:}::{:LAST:};
}

#endif /*{:uc:NAME:}_ENUM_HPP*/
