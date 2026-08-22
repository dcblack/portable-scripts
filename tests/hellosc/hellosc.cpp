#include <systemc>

SC_MODULE( HelloWorld ) {
  // Constructor
  SC_CTOR( HelloWorld )
  {
    //SC_HAS_PROCESS( HelloWorld );
    SC_THREAD( hello );
  }

  // Process
  void hello() {
    SC_REPORT_INFO( "/Doulos/SystemC/hello", "Hello SystemC!" );
    sc_core::sc_stop();
  }
};

int sc_main( [[maybe_unused]]int argc, [[maybe_unused]]char* argv[] )
{
  HelloWorld SC_NAMED(hello);
  sc_core::sc_start();
  return 0;
}
