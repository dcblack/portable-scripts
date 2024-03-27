#ifdef  REMOVE_THIS_LINE/*CHANGING CONTENTS AS NEEDED FOR YOUR DESIGN*/
#include "top.hpp"
using Top = Top_module;
#endif/*REMOVE_THIS_LINE*/
#include <systemc>
#include <string>
#include <memory>
using namespace sc_core;
using namespace std::literals;

namespace {
  const char* const msg_type{ "/{:COMPANY:}/{:NAME:}/main" };
}
/**
 * @author {:EMAIL:}
 * @date   {:DATE:}
 * @brief  sc_main is the entry point for SystemC
 *
 * This implementation checks for errors and exceptions during elaboration and simulation.
 *
 * A summary is displayed before exiting with "SUCCESS" or "FAILURE" if there were errors.
 *
 * Recommended practice is to instantiate one top-level module with
 * no ports and instantiate the rest of the design from there. Then if instantiation
 * was successful, invoke sc_core::sc_start(). A good design will eventually invoke
 * sc_core::sc_stop() and return here.
 */

//------------------------------------------------------------------------------
[[maybe_unused]]
int sc_main( [[maybe_unused]]int argc, [[maybe_unused]]char* argv[] )
{

  SC_REPORT_WARNING( msg_type, "STANDARD SC_MAIN -- PLEASE REPLACE THIS LINE WITH YOUR CODE" ); // Hint: The sc-top template
  bool elaboration_error = false;
  std::string message;
  std::unique_ptr<Top> top;
  /**
   * Instantiate design
   */
  try {
    top = std::make_unique<Top>( "top" );
  } catch( std::exception& e ) {
    elaboration_error = true;
    message = "\n";
    message += e.what();
    message += "\n\n*** Please fix elaboration errors and retry. ***";
    SC_REPORT_INFO( msg_type, message.c_str() );
  }
  catch ( ... ) {
    elaboration_error = true;
    message = "Error: *** Caught unknown exception during elaboration. ***\n\n*** Please fix elaboration errors and retry. ***";
    SC_REPORT_ERROR( msg_type, message.c_str() );
  }//endtry
  if( not elaboration_error ) {
    /**
     * Simulate until sc_core::c_stop() or something bad happens.
     */
    try {
      SC_REPORT_INFO( msg_type, "Starting kernel" );
      sc_start();
      message = "Exited kernal at " + sc_time_stamp().to_string();
      SC_REPORT_INFO( msg_type, message.c_str() );
    }
    catch ( sc_exception& e ) //< includes std::exception's
    {
      message = "Caught exception during active simulation.\n";
      message += e.what();
      SC_REPORT_WARNING( msg_type, message.c_str() );
    }
    catch ( ... )
    {
      SC_REPORT_ERROR( msg_type, "Caught unknown exception during active simulation." );
    }//endtry
  }

  /**
   * Clean up
   */
  if ( not elaboration_error and not sc_end_of_simulation_invoked() )
  {
    SC_REPORT_WARNING( msg_type, "\nSimulation stopped without explicit sc_stop()" );

    try {
      sc_stop(); //< this will invoke end_of_simulation() callbacks
    }
    catch ( sc_exception& e ) //< includes std::exception's
    {
      message = "Caught exception while stopping.\n";
      message += e.what();
      SC_REPORT_ERROR( msg_type, message.c_str() );
    }
    catch(...) {
      SC_REPORT_ERROR( msg_type, "Caught unknown exception while stopping." );
    }
  }//endif

  /**
   * Report summary
   */
  auto warn_count = sc_report_handler::get_count( SC_WARNING );
  message = "There "s + ( warn_count == 1 ? "was " : "were " );
  if( warn_count > 0 ) {
    message += std::to_string( warn_count );
  } else {
    message += "no";
  }
  message += " warning"s + ( warn_count > 1 ? "s" : "" );
  message += '\n';

  auto error_count = sc_report_handler::get_count( SC_FATAL );
  auto had_fatal = error_count > 0;
  error_count += sc_report_handler::get_count( SC_ERROR );
  message += "There "s + ( error_count == 1 ? "was " : "were " );
  if( error_count > 0 ) {
    message += std::to_string( error_count );
  } else {
    message += "no";
  }
  message += " error"s + ( error_count > 1 ? "s" : "" );
  message += had_fatal ? " including at least one fatal" : "";
  message += "\n{:NAME:} simulation ";
  if( error_count > 0 ) {
    message += "FAILED due to ERRORS";
  } else {
    message += "PASSED SUCCESSFULLY" + (warn_count > 0 ? ", but with warnings" : "");
  }
  SC_REPORT_INFO( msg_type, message.c_str() );
  return error_count > 0 ? 1 : 0;
}

///////////////////////////////////////////////////////////////////////////////
// Copyright {:YEAR:} by {:COMPANY:}. All rights reserved.
//END {:FILE:} {:Id:}
