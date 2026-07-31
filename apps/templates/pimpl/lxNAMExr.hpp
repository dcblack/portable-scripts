#pragma once

#include <memory>

class {:sc:NAME:} {
  class impl;
  std::unique_ptr<impl> pimpl;
public:
  void {:METHOD:}({:FORMAL_ARGS:}); // public API that will be forwarded to the implementation
  {:sc:NAME:}({:FORMAL_CTOR:}); // defined in the implementation file
  // Rule of 5 if needed
  ~{:sc:NAME:}();   // defined in the implementation file, where impl is a complete type
  {:sc:NAME:}({:sc:NAME:}&&) noexcept; // defined in the implementation file
  {:sc:NAME:}(const {:sc:NAME:}&) = delete;
  {:sc:NAME:}& operator=({:sc:NAME:}&&) noexcept; // defined in the implementation file
  {:sc:NAME:}& operator=(const {:sc:NAME:}&) = delete;
};
//TAF!
