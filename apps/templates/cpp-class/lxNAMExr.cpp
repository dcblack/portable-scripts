#include "{:lc:NAME:}.hpp"

//------------------------------------------------------------------------------
// Default constructor
{:wc:NAME:}::{:wc:NAME:}()
: {:INITIALIZER_LIST:}
{
}

// Rule of 5
~{:wc:NAME:}::{:wc:NAME:}() = default;
{:wc:NAME:}::{:wc:NAME:}({:wc:NAME:} const&) = default;
{:wc:NAME:}::{:wc:NAME:}({:wc:NAME:}&& ) = default;
{:wc:NAME:}& {:wc:NAME:}::operator=({:wc:NAME:} const&) = default;
{:wc:NAME:} {:wc:NAME:}::operator=({:wc:NAME:}&&) = default;

//EOF
