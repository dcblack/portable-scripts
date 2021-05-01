#ifdef  REMOVE_THIS_LINE/*CHANGING CONTENTS AS NEEDED FOR YOUR DESIGN*/
#include "top.hpp"
using Top = Top_module;
#endif/*REMOVE_THIS_LINE*/
#include <systemc>
#include <string>
#include <memory>
using namespace sc_core;

namespace {
  const char* const MSGID{ "/{:COMPANY:}/{:NAME:}/main" };
}
/**
 * @author {:EMAIL:}
 * @date   {:DATE:}
 * @brief  sc_main is the entry point for SystemC
 *
 * Recommended practice is to instantiate one top-level module with
 * no ports that instantiates the rest of the design. Then if instantiation
 * was successful, invoke sc_core::sc_start(). A good design will eventually invoke
 * sc_core::sc_stop() and return here.
 */

//------------------------------------------------------------------------------
int sc_main( [[maybe_unused]]int argc, [[maybe_unused]]char* argv[] )
{

  SC_REPORT_WARNING( MSGID, "STANDARD SC_MAIN -- PLEASE REPLACE THIS LINE WITH YOUR CODE" ); // Hint: The sc-top template
  bool elaboration_error = false;
  std::string message;
  std::unique_ptr<Top> top;
  /**
   * Instantiate design
   */
  try {
    top = new Top( "top" );
  } catch( std::exception& e ) {
    elaboration_error = true;
    message = "\n";
    message += e.what();
    message += "\n\n*** Please fix elaboration errors and retry. ***";
    SC_REPORT_INFO( MSGID, message.c_str() );
  }
  catch ( ... ) {
    elaboration_error = true;
    message = "Error: *** Caught unknown exception during elaboration. ***\n\n*** Please fix elaboration errors and retry. ***";
    SC_REPORT_ERROR( MSGID, message.c_str() );
  }//endtry
  if( not elaboration_error ) {
    /**
     * Simulate until sc_core::c_stop() or something bad happens.
     */
    try {
      SC_REPORT_INFO( MSGID, "Starting kernel" );
      sc_start();
      message = "Exited kernal at " + to_string( sc_time_stamp() );
      SC_REPORT_INFO( MSGID, message.c_str() );
    }
    catch ( sc_exception& e ) //< includes std::exception's
    {
      message = "Caught exception during active simulation.\n";
      message += e.what();
      SC_REPORT_WARNING( MSGID, message.c_str() );
    }
    catch ( ... )
    {
      SC_REPORT_ERROR( MSGID, "Caught unknown exception during active simulation." );
    }//endtry
  }

  /**
   * Clean up
   */
  if ( not elaboration_error and not sc_end_of_simulation_invoked() )
  {
    SC_REPORT_WARNING( MSGID, "\nSimulation stopped without explicit sc_stop()" );

    try {
      sc_stop(); //< this will invoke end_of_simulation() callbacks
    }
    catch ( sc_exception& e ) //< includes std::exception's
    {
      message = "Caught exception while stopping.\n";
      message += e.what();
      SC_REPORT_ERROR( MSGID, message.c_str() );
    }
    catch(...) {
      SC_REPORT_ERROR( MSGID, "Caught unknown exception while stopping." );
    }
  }//endif

  /**
   * Report summary
   */
  unsigned int error_count = sc_report_handler::get_count( SC_ERROR ) + sc_report_handler::get_count( SC_FATAL );
  message = "There were ";
  if( error_count > 0 ) {
    message += to_string( error_count );
  } else {
    message += "no";
  }
  message += " error messages including fatal\n{:NAME:} ";
  if( error_count > 0 ) {
    message += "FAILED";
  } else {
    message += "PASSED";
  }
  SC_REPORT_INFO( MSGID, message.c_str() );
  return error_count > 0 ? 1 : 0;
}

///////////////////////////////////////////////////////////////////////////////
// Copyright {:YEAR:} by {:COMPANY:}. All rights reserved.
//END {:FILE:} {:Id:}
