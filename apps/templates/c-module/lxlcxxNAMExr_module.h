#ifndef {:uc:NAME:}_H
#define {:uc:NAME:}_H

  //----------------------------------------------------------------------------
  // Types
  typedef struct {
    // Config
  } {:lc:NAME:}_config_t;

  typedef struct {
    // Data
  } {:lc:NAME:}_obj_t;

  //----------------------------------------------------------------------------
  // Method declarations

  /**
   * @brief Construct {:lc:NAME:}
   */
  void {:uc:NAME:}_init( {:lc:NAME:}_config_t* config );

  /**
   * @brief Construct {:lc:NAME:}
   */
  void {:uc:NAME:}_destroy( {:lc:NAME:}_config_t* config );

  /**
   * @brief {:PURPOSE_AND_USAGE:}
   */
  {:TYPE:} {:uc:NAME:}_{:FUNC:}( {:lc:NAME:}_obj_t* this );

#endif/*{:uc:NAME:}_H*/

//------------------------------------------------------------------------------
/**
 * @copyright
 * {:COPYRIGHT:}
 */

//------------------------------------------------------------------------------
// The end
