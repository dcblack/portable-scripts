/**
 * @file   {:lc:NAME:}.cpp
 * @author {:AUTHOR:}
 * @date   {:DATE:}
 * @brief  {:BRIEF:}
 *
 * See {:lc:NAME:}.hpp for more information.
 *
 */
#include "{:lc:NAME:}.hpp"
#include "report.hpp" //{:DELETE THIS COMMENT, AND POSSIBLY THE LINE AS NEEDED:}
using namespace sc_core;

//------------------------------------------------------------------------------
// Constructor
{:sc:NAME:}_module::{:sc:NAME:}_module( const sc_module_name& instance_name)
: sc_module( instance_name )
//, {:OBJECT_CONSTRUCTION:}
{
  // Connectivity - NONE
  // Register processes
  SC_HAS_PROCESS( {:sc:NAME:}_module );
  SC_THREAD( {:lc:NAME:}_thread );
}//endconstructor

//------------------------------------------------------------------------------
// Destructor
{:sc:NAME:}_module::~{:sc:NAME:}_module() {
}

//------------------------------------------------------------------------------
// Processes
void {:sc:NAME:}_module::{:lc:NAME:}_thread() {

  //(/* - vim users place cursor on this line and type 0wd%
{:*/  SC_REPORT_ERROR(MSGID,"REPLACE_HERE_BELOW\n\n\n"                 //:}*/
{:*/                                                                   //:}*/
{:*/      "########################################################\n" //:}*/
{:*/      "########################################################\n" //:}*/
{:*/      "##                                                    ##\n" //:}*/
{:*/      "##   REPLACE THIS ERROR MESSAGE AND ANY OTHER         ##\n" //:}*/
{:*/      "##   PLACEHOLDERS SURROUNDED BY CURLY BRACKET-COLON   ##\n" //:}*/
{:*/      "##   PAIRS SUCH AS YOU SEE ON THESE LINES OF SOURCE   ##\n" //:}*/
{:*/      "##   CODE. DELETE UNUSED PLACEHOLDERS ENGTIRELY.      ##\n" //:}*/
{:*/      "##                                                    ##\n" //:}*/
{:*/      "########################################################\n" //:}*/
{:*/      "########################################################\n" //:}*/
{:*/                                                                   //:}*/
{:*/  "\n\nREPLACE_HERE_ABOVE\n\n" );                                  //:}*/
//)

}//end {:sc:NAME:}_module::{:lc:NAME:}_thread

//------------------------------------------------------------------------------
// Other methods - NONE

//------------------------------------------------------------------------------
// Copyright {:YEAR:} by {:COMPANY:}. All rights reserved.
// For licensing information concerning this document see LICENSE-{:LICENSE:}.txt.
//END {:FILE:} {:Id:}
