#include "{:lc:NAME:}.hpp"

class {:sc:NAME:}::impl {
  {:DATA_TYPE:} {:DATA_FIELD:}{{:DATA_ARGS:}}; // private data
public:
  void {:METHOD:}({:FORMAL_ARGS:}& w) {
    {:BODY:}
  }
   impl({:FORMAL_CTOR:}) 
     : {:DATA_FIELD}{{:DATA_ARGS:} {}
};

void {:sc:NAME:}::{:METHOD:}({:FORMAL_ARGS:}) { pimpl->{:METHOD:}(*this); }

{:sc:NAME:}::{:sc:NAME:}({:FORMAL_CTOR:}) : pimpl{std::make_unique<impl>({:ACTUAL_CTOR:})} {}

{:sc:NAME:}::{:sc:NAME:}({:sc:NAME:}&&) noexcept = default;

{:sc:NAME:}::~{:sc:NAME:}() = default;

{:sc:NAME:}& {:sc:NAME:}::operator=({:sc:NAME:}&&) noexcept = default;
