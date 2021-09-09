/**
 * @file   {:lc:NAME:}.hpp
 * @author {:AUTHOR:}
 * @date   {:DATE:}
 * @brief  {:BRIEF:}
 *
 * {:LONGER_DESCRIPTION:}
 *
 */
#ifndef {:uc:NAME:}_HPP
#define {:uc:NAME:}_HPP

#include <systemc>

struct {:sc:NAME:}_module
: sc_core::sc_module
{
  // Ports - NONE

  // Constructor
  explicit {:sc:NAME:}_module( const sc_core::sc_module_name& instance_name );

  // Destructor
  virtual ~{:sc:NAME:}_module();

private:
  // Processes
  void {:lc:NAME:}_thread();

  // Local methods - NONE

  // Local channels - NONE

  // Attributes - NONE

  static constexpr const char* const MSGID
  { "/{:COMPANY:}/{:$PROJECT:}/{:sc:NAME:}" };
};//end {:sc:NAME:}_module

#endif/*{:uc:NAME:}_HPP*/

//------------------------------------------------------------------------------
// Copyright {:YEAR:} by {:COMPANY:}. All rights reserved.
// For licensing information concerning this document see LICENSE-{:LICENSE:}.txt.
//END {:FILE:} {:Id:}
