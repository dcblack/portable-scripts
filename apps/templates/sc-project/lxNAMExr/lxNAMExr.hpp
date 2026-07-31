#pragma once

#include <tlm>
#include <string_view>

// Declarations
SC_MODULE( Top_module ) {
  explicit {:sc:NAME:}(std::string_view const& instance);
};
