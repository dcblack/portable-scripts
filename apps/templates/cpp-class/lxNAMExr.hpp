#ifndef {:uc:NAME:}_HPP
#define {:uc:NAME:}_HPP

class {:wc:NAME:}
{
public:
  // Special methods
  {:wc:NAME:}(); //< Default constructor

  // Rule of 5
  ~{:wc:NAME:}(); //< Destructor
  {:wc:NAME:}({:wc:NAME:} const&); //< Copy constructor
  {:wc:NAME:}({:wc:NAME:}&& ); //< Move constructor
  {:wc:NAME:}& operator=({:wc:NAME:} const&); //< Copy assignment
  {:wc:NAME:} operator=({:wc:NAME:}&&); //< Move assignment

private:
  // Attributes
};

#endif/*{:uc:NAME:}_HPP*/
