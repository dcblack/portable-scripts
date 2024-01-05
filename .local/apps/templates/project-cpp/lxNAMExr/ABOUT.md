This is the top-level of the {:NAME:} project.

{:ADD DESCRIPTION OF THE PROJECT HERE AND DELETE THIS LINE:}

Directory organization:

{:MODIFY THE FOLLOWING TO SUITE YOUR NEEDS AND DELETE THIS LINE:}


  {:NAME:}/
  ├── .git/
  ├── .gitignore
  ├── ABOUT.md
  ├── cmake/
  │   ├── ABOUT.md
  │   ├── project_defaults.cmake
  │   └── set_target.cmake
  ├── extern/
  │   ├── ABOUT.md
  │   ├── bin/
  │   │   ├── ABOUT.md
  │   │   ├── build
  │   │   ├── build-fmt
  │   │   └── build-gtest
  │   ├── include/
  │   │   └── ABOUT.md
  │   └── lib/
  │       ├── ABOUT.md
  │       └── cmake
  ├── setup.profile
  │
  │ ####################################
  │ # OPTION 1: Simple project organization
  ├── {:IMPLEMENTATION:}.cpp
  ├── {:HEADER:}.hpp
  │
  │ ####################################
  │ # OPTION 2: Examples
  ├── ex1/
  │   ├── CMakeLists.txt
  │   ├── {:EXAMPLE1:}.cpp
  │   └── {:EXAMPLE1:}.hpp
  │
  │ ####################################
  │ # OPTION 3: Slightly more organized
  ├── includes/
  │   ├── CMakeLists.txt
  │   └── {:HEADER:}.hpp
  └── srcs/
      ├── CMakeLists.txt
      └── {:IMPLEMENTATION:}.cpp

{:ADD CODING GUIDELINES HERE AND DELETE THIS LINE:}

#### End of file
