# Perl toolbox for use with Portable Scripts perl code
# -*- /usr/bin/perl -*- vim:syntax=perl:tw=78:fmr=<<<,>>>
package pscr;

## BEGIN DOCUMENTATION ####################################################<<<1
# @(#)$Copyright: 2006-2007,2021 David C Black. All rights reserved. $
# @(#)$Last_Updated: 2021-Sep-12 Sun 16:52PM dcblack

=pod

=head1 NAME

pscr-utils.pm - perl module with miscellaneous support routines used in Portable scripts perl code

=head1 SYNOPSIS

 use pscr;

=head1 EXPORTS

:all - tag for all routines and variables

:report - routines used for exception reporting

:util - utilities

:lsf - load sharing facility routines

=head1 DETAILS

=cut

# SETUP MODULE # <<<1
use strict;
use warnings;
use Carp;
use Cwd;
use File::Find ();

###############################################################################
BEGIN {
  use Exporter   ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS @EXPORTS);
  # set the version for version checking
  $VERSION = do { my @r = (q$Revision: 1.64 $ =~ /\d+/g); sprintf "%d."."% 02d" x $#r, @r }; # must be all one line, for MakeMaker
  @ISA         = qw(Exporter);
  @EXPORT      = qw();
  # Things that can be requested separately for export
  # NOTE: Every item should be expressed once. The following hierarchical
  #       structure is parsed for entries of the form :NAME and all of the
  #       corresponding entries are put into that grouping.
  my %EXPORT_MAP = (
      # Reporting routines
      'report' => [ qw{
        &Banner &Box &Date &Cluck &Confess &Exit
        &Debugf &Info &Warn &Error &Croak &Carp
        &REPORT_DEBUG &REPORT_RAW &REPORT_INFO &REPORT_WARNING &REPORT_ERROR &REPORT_FATAL
        &FatalError &Internal &Open_log &Opt &opt &Verbatim &Version
        $openlog %OPT $warn_count $error_count $fatal_count
      }],
      # Utility type of stuff
      'util' => [ qw{
        &Columns &Date &Dir_file &FilterEnv &FmtSystem &Glob &KeepIfDiff
        &Mkcdslib &Mkdir &Mkhdlvar &Mkshell &path &Pipe_cmd &Quoteargs
        &Reduce_all &Save_existing &Shorten &Sec2dhms &ShortDate &Spawn &System
        &System_pipe &SystemCC &SystemParse &Trim &Unique &UniqueList
      }],
      # Stuff used for lsf
      'lsf' => [ qw{
        &ActiveJobs &EndedJobs &WaitAllJobsDone &WaitNextJobDone
        %activeLsf %endedJob
      }],
      # Version control stuff
      'version' => [ qw{
        &Clearview &Cleartool &ConfigSpec &HaveClearcase
      }],
      # Stuff used by the verify script
      'verify' => [ qw{
        :version :util :report
        &Dictionary_order &Existingbynum &FilterEnv
        $banner_pgm $runtest_pgm $toolset
      }],
      # Stuff used by the mkshell script
      'mkshell' => [ qw{
        :report $toolset
      }],
      # Stuff used by the run_test script
      'run_test' => [ qw{
        :report :util :version
        &Cargs &Def2Make &RunUserScript &Safedef &SaveEnv &Start_dir
        $toolset
      }],
      # Everything
      'all' => [ qw{
        :lsf :report :util :version
        :mkshell :run_test :verify
        &DiffMk &Handler &Lock &RC_var &ReadMk &Unlock &WrapMake
        $sig $bmake_pgm $bsub_pgm $env2_pgm $mkshell_pgm $vc2_pgm $verify_pgm
        $xterm_pgm $PSCR $start_dir $ARCH $HOST $PPID $USER $VIEW %OPT *STDLOG
      }],
  );#%EXPORT_MAP
  # Compute the exports and tags
  my %EXPORT_OK;
  for my $xtag (keys %EXPORT_MAP) {
    $EXPORT_TAGS{$xtag} = [];
    for my $word (@{$EXPORT_MAP{$xtag}}) {
      next if $word =~ m/^:\w+/;
      push @{$EXPORT_TAGS{$xtag}},$word;
      $EXPORT_OK{$word}=1;
    }#endfor
  }#endfor
  for my $xtag (keys %EXPORT_MAP) {
    for my $word (@{$EXPORT_MAP{$xtag}}) {
      next unless $word =~ m/^:(\w+)/;
      push @{$EXPORT_TAGS{$xtag}},@{$EXPORT_TAGS{$1}};
    }#endfor
  }#endfor
  @EXPORT_OK = sort keys %EXPORT_OK;
  # Tags (from above) that we allow to be exported
  for my $xtag (keys %EXPORT_MAP) {
    &Exporter::export_ok_tags($xtag);
  }#endfor
}
use vars @EXPORT_OK;
use FileHandle;
use Cwd;
use Envv qw{:basic envvfile envvopt shell $shell};
&envvfile(''); # No dumping -- city limit
&envvopt('quiet');

#------------------------------------------------------------------------------
# Proto-types
#------------------------------------------------------------------------------
sub opt(@);

#------------------------------------------------------------------------------
# non-exported package globals
#------------------------------------------------------------------------------
use FindBin qw($RealBin $RealScript);
our $PSCR = $RealBin;
$PSCR =~ s{/(bin|lib)$}{};

# Following are intended to allow us to make things safer to run.
our $banner_pgm   = "$PSCR/bin/header"; 
our $bmake_pgm    = "$PSCR/bin/bmake";  
our $bsub_pgm     = '';
    $bsub_pgm     = "$ENV{'LSF_BINDIR'}/bsub" if exists $ENV{'LSF_BINDIR'};
our $cargs_pgm    = "$PSCR/bin/cargs";  
our $env2_pgm     = "$PSCR/bin/env2";   
our $mkshell_pgm  = "$PSCR/bin/mkshell"; 
our $runtest_pgm  = "$PSCR/bin/run_test"; 
our $safedef_pgm  = "$PSCR/bin/safedef";
our $vc2_pgm      = "$PSCR/bin/vc2";    
our $verify_pgm   = "$PSCR/bin/verify"; 
our $xterm_pgm    = '/usr/bin/xterm';
    $xterm_pgm    = '/usr/X11/bin/xterm' unless -x $xterm_pgm;
our $uname_pgm    = '/bin/uname';
    $uname_pgm    = '/usr/bin/uname' unless -x $uname_pgm;
our $hostname_pgm = '/bin/hostname';
    $hostname_pgm = '/usr/bin/hostname' unless -x $hostname_pgm;

# Useful info
our $USER = getlogin() || getpwuid($<) || "Kilroy";
our $PPID = getppid();
our $VIEW = &Clearview;
our $ARCH = `$uname_pgm -a`;
chomp $ARCH;
our $HOST = `$hostname_pgm`;
chomp $HOST;
$HOST =~ s/\.*//;
our %OPT; # %OPT holds all the command-line options after parsing
our $toolset = 'osci';
our $sig = '';
our $openlog =  0;
our $logfile = 'pscr.log';
our $fatal_count = 0;
our $error_count = 0;
our $warn_count  = 0;
our @BUFLOG;
our $start_dir = &getcwd();
our $rc_var  = 'PSCRC';
#if (-r "$ENV{HOME}/.pscrrc") { 
#  do "$ENV{HOME}/.pscrrc"; # ? too dangerous ? #
#}#endif
if (exists $ENV{PSCR_LIMIT}) {
  $OPT{-limit} = $ENV{PSCR_LIMIT};
  $OPT{-limit} = 0 unless $OPT{-limit} =~ m/^\d+$/;
}#endif

###############################################################################
sub Spawn { # fork a process #<<<1
   my $pid;
   unless ($pid = fork) {
      no warnings;
      unless (fork) {
         exec(@_) or
         &REPORT_FATAL("no exec");
      }#endunless
      exit 0;
      use warnings;
   }#endunless
   waitpid($pid,0);
}#endsub Spawn

###############################################################################
sub Version { # Computes version info for a tool #<<<1
# Usage: our ($tool,$rcs,$revn,$Tool,$TOOL) = &Version('$Id$');
  my $vers = shift @_;
  my ($tool,$rcs,$revn,$Tool,$TOOL);
  if ($vers =~ m{[\$%]Id: (\S+),v (\d+)(?:\.(\d+))? [^\$%]+ (\w+) [\$%]}) {
    ($tool,$revn,$rcs)=($1,"$2.$3",$4);
    map($rcs =~ s/${$_}[0]/${$_}[1]/,(['exp'=>'proto'],['rlsd'=>'released']));
    $revn .= lc " ($rcs)";
  } elsif ($vers =~ m{[\$%]Id: (\S+) (\d+) [^\$%]+[\$%]}) {
    ($tool,$revn,$rcs)=($1,$2,'');
  }#endif
  $Tool = $tool;
  $TOOL = uc($tool);
  $Tool =~ s/^./\u$&/;
  return ($tool,$rcs,$revn,$Tool,$TOOL);
}#endsub Version

###############################################################################
sub Opt { # Determine if an option is selected #<<<1
  my $opt=shift @_;
  return 0 unless exists $OPT{$opt};
  if (scalar @_) { # optional value to compare against
    my $val=shift @_;
    return $OPT{$opt} eq $val;
  }#endif
  return $OPT{$opt}; # non-zero or non-empty string
}#endsub Opt

###############################################################################
sub opt(@) { # determine if option selected and return its value #<<<
  # NOTE: returns concatenated values separated by $; if multiple found
  # NOTE: leading hyphen optional to allow use with Getopts::Long
  my $result = '';
  my $opts = \%OPT;
  $opts = shift if ref $_[0] eq 'HASH';
  for (@_) {
    my $opt = $_;
    $result .= $opts->{$opt}.$; if exists $opts->{$opt} and $opts->{$opt} !~ m{^0?$};
    $opt =~ s{^-}{} unless exists $OPT{'-'};
    $result .= $opts->{$opt}.$; if exists $opts->{$opt} and $opts->{$opt} !~ m{^0?$};
  }#endfor
  chop $result; # remove trailing $;
  return $result;
}

############################################################################>>>
sub Start_dir { # Establish the starting directory #<<<1
  $start_dir = &getcwd();
}#endsub Start_dir

###############################################################################
sub RC_var { # Establish $rc_var #<<<1
  $rc_var = shift @_;
}#endsub RC_var

###############################################################################
sub HaveClearcase { # returns true/false #<<<1
  for my $path (split(':',$ENV{'PATH'})) {
    next unless -r "$path/cleartool" and -x "$path/cleartool";
    return 1;
  }#endfor
  return 0;
}#endsub RC_var

###############################################################################
sub Cleartool { # executes cleartool command #<<<1
  my $cmnd = shift @_;
  for my $path (split(':',$ENV{'PATH'})) {
    next unless -r "$path/cleartool" and -x "$path/cleartool";
    my $text = qx{cleartool $cmnd};
    chomp $text;
    return $text;
  }#endfor
  return '';
}#endsub Cleartool

###############################################################################
sub Clearview { # Returns the name of the current working directory's view #<<<1
  my $cwd = &getcwd;
  $cwd = shift @_ if @_;
  &Confess("Non-existant directory '$cwd'!?") unless -d $cwd;
  my $owd = &getcwd();
  chdir $cwd if defined $cwd;
  my $view = &Cleartool('pwv -short -setview');
  chdir $owd;
  $view =~ s/^[^:]+:\s*//;
  $view = '' if $view eq '** NONE **';
  return $view;
}#endsub Clearview

###############################################################################
sub ConfigSpec { # Display config specification #<<<1
  return sprintf"%s",&Cleartool('catcs');
}#endsub ConfigSpec

###############################################################################
sub Reduce_all { # Remove duplicate entries in environment #<<<1
  # Removes duplicates in $PATH, $LD_LIBRARY_PATH, etc..
  for my $var (@_) {
    &reduce($var);
  }#endfor
}#endsub Reduce_all

###############################################################################
sub Handler { # 1st argument is signal name #<<<1
  ($sig) = @_;
  &REPORT_ERROR("Caught a SIG$sig -- attempting to gather logs!\n");
}#endsub Handler

###############################################################################
sub FilterEnv { # scans & removes dangerous environment variable names #<<<1
  my $DANGEROUS = join('|',qw(
    DISPLAY HOME LOGNAME MAIL PWD SHLVL SSH_ASKPASS SSH_CLIENT SSH_CONNECTION
    SSH_TTY TZ USER
  ));
  return grep(!m/^($DANGEROUS)$/,@_);
}#endsub FilterEnv

###############################################################################
sub SaveEnv { # Saves environment variables in specified file #<<<1
  my ($base,$shell) = @_;
  $shell = 'sh' unless defined $shell;
  #$shell = $ENV{'SHELL'} if exists $ENV{'SHELL'}; # {:TODO - future, but needs translation below:}
  my $file = "$base.$shell";
  open   ENVFILE,">$file-tmp";
  ENVFILE->autoflush(1);
  printf ENVFILE "#!/bin/sh\n";
  printf ENVFILE "#\n";
  printf ENVFILE "# Environment variables\n";
  printf ENVFILE "#\n";
  printf ENVFILE "# --- AUTOMAGICALLY GENERATED ---\n";
  printf ENVFILE "#\n";
  printf ENVFILE "# TESTNAME: %s\n",$OPT{-testname} if defined $OPT{-testname};
  printf ENVFILE "# CREATED:  %s\n",$main::start_time;
  printf ENVFILE "# USER:     %s\n",$USER;
  printf ENVFILE "# HOST:     %s\n",$HOST;
  printf ENVFILE "# WORKDIR:  %s\n",$start_dir;
  printf ENVFILE "\n";
  # Ignore variables that might mess up environment for user
  my @IGNORE = qw(
    DISPLAY HISTFILE HISTSIZE HOME HOST LOGNAME 
    LSB_ACCT_FILE LSB_CHKFILENAME LSB_JOBFILENAME LSB_JOBID LS_JOBPID
    NAME OSTYPE PS1 PS2 PWD REALNAME
    REPLYTO SECURITYSESSIONID TTY TZ USER
  );
  for my $var (sort keys %ENV) {
    next if grep($var eq $_,@IGNORE);
    my $val = $ENV{$var};
    $val =~ s/\\/\\\\/g;
    $val =~ s/'/\\'/g;
    printf ENVFILE "%s='%s'; export %s;\n",$var,$val,$var;
  }#endfor
  printf ENVFILE "#\n";
  printf ENVFILE "# --- AUTOMAGICALLY GENERATED ---\n";
  printf ENVFILE "\n";
  printf ENVFILE "# END $file\n";
  close  ENVFILE;
  &KeepIfDiff($file);
}#endsub SaveEnv

###############################################################################
sub Shorten { # reduces length of string by inserting environment variable #<<<1
  my $str = shift @_;
  my @EXCEPT = @_;
  push @EXCEPT,qw(PWD OLDPWD lwd);
  my $tmp = $str;
  my $shortest = $str;
  for my $env_var (keys %ENV) {
    next if grep($env_var eq $_,@EXCEPT); # Skip transient variables
    my $env_val = $ENV{$env_var};
    next unless $env_val =~ m{^[-+0-9a-zA-Z_/]+$};
    next unless $tmp =~ s{^$env_val/}{\$$env_var/};
    $shortest = $tmp if length $tmp < length $shortest;
    $tmp = $str;
  }#endfor
  return $shortest;
}#endsub Shorten

###############################################################################
sub Date { # Returns a formatted date/time w/ AM/PM <<<1
  my $date = scalar localtime;
  if (@_ == 1 and $_[0] =~ m/\a/) {
    $date = shift(@_);
  } elsif (@_ == 1) {
    $date = localtime shift(@_);
  }#endif
  if ($date =~ m{ (\d+):}) {
    my $hr = $1;
    if ($hr > 12) {
      $hr -= 12;
      $date =~ s{ (\d+):(\d+:\d+) }{ $hr:$2 PM };
    } else {
      $date =~ s{ (\d+:\d+:\d+) }{ $1 AM };
    }#endif
  }#endif
  return $date;
}#endsub Date

###############################################################################
sub Debugf { # alias for REPORT_DEBUG <<<1
  REPORT_DEBUG(@_);
}#endsub Debugf
###############################################################################
# Exception reporting subroutines #<<<2
sub REPORT_DEBUG { # prints if supplied level <= global debug level #<<<3
  # USAGE: &REPORT_DEBUG(LEVEL,FMT,ARG...); use sprintf within if needed
  my $level = shift @_;
  return unless exists $OPT{-debug};
  return if $OPT{-debug} == 0;
  return unless $OPT{-debug} >= $level;
  if ($OPT{-debug} =~ m/^\d+([a-z])$/) {
    my $tag = $1;
    return unless $level =~ m/^\d+[$tag]$/;
  }#endif
  my $fmt = "DEBUG($level): ".shift @_;
  chomp $fmt; chomp $fmt;
  my $fmtd = sprintf($fmt,$_[0],$_[1],$_[2],$_[3],$_[4],$_[5],$_[6],$_[7],$_[8],$_[9]);
  $fmtd .= "\n";
  if ($openlog) {
    print STDLOG $fmtd;
  } else {
    push @BUFLOG,$fmtd;
  }#endif
  return if $OPT{-quiet};
  print STDOUT $fmtd;
}#endsub REPORT_DEBUG

###############################################################################
sub Info { # alias for REPORT_INFO <<<1
  # Deprecated
  REPORT_INFO(@_);
}#endsub Info
###############################################################################
sub REPORT_INFO { # print INFO message to stdout & log if open <<<1
  # USAGE: &REPORT_INFO(MESSAGE...); use sprintf within if needed
  my @msgs = @_;
  my $fmtd = '';
  for my $msg (@msgs) {
    next unless defined $msg;
    chomp $msg;
    $fmtd = 'INFO: ' unless ($fmtd.$msg) =~ m{^INFO: };
    $fmtd .= sprintf("%s\n",$msg);
    if ($openlog) {
      print STDLOG $fmtd;
    } else {
      push @BUFLOG,$fmtd;
    }#endif
    print STDOUT $fmtd unless $OPT{-quiet};
  }#endfor
}#endsub REPORT_INFO

###############################################################################
sub Note { # print NOTE message to stdout & log if open <<<1
  # USAGE: &Note(MESSAGE...); use sprintf within if needed
  my @msgs = @_;
  my $fmtd = '';
  for my $msg (@msgs) {
    next unless defined $msg;
    chomp $msg;
    $fmtd = 'NOTE: ' unless ($fmtd.$msg) =~ m{^NOTE: };
    $fmtd .= sprintf("%s\n",$msg);
    if ($openlog) {
      print STDLOG $fmtd;
    } else {
      push @BUFLOG,$fmtd;
    }#endif
    print STDOUT $fmtd unless $OPT{-quiet};
  }#endfor
}#endsub Note

###############################################################################
sub Verbatim { # alias for REPORT_INFO <<<1
  # Deprecated
  REPORT_RAW(@_);
}#endsub Info
###############################################################################
sub REPORT_RAW { # print exact message to stdout & log if open <<<1
  # USAGE: &REPORT_RAW(MESSAGE...); use sprintf within if needed
  my @msgs = @_;
  for my $msg (@msgs) {
    if ($openlog) {
      print STDLOG $msg;
    } else {
      push @BUFLOG,$msg;
    }#endif
    print STDOUT $msg unless $OPT{-quiet};
  }#endfor
}#endsub REPORT_RAW

###############################################################################
sub Warn { # alias for REPORT_WARNING <<<1
  REPORT_WARNING(@_);
}#endsub Warn
###############################################################################
sub REPORT_WARNING { # print WARNING message to stdout & log if open <<<1
  # USAGE: &REPORT_WARNING(MESSAGE[,TAG]); use sprintf within if needed
  my $msg = shift @_;
  chomp $msg;
  my $tag = '';
  $tag = shift @_ if scalar @_ > 0;
  my $fmtd = '';
  $fmtd = sprintf("WARNING%s: ",$tag) unless $msg =~ m{^WARNING\b};
  $fmtd .= sprintf("%s\n",$msg);
  if ($openlog) {
    print STDLOG $fmtd;
  } else {
    push @BUFLOG,$fmtd;
  }#endif
  print STDOUT $fmtd;
  ++$warn_count;
}#endsub REPORT_WARNING

###############################################################################
sub Error { # alias for REPORT_ERROR <<<1
  REPORT_ERROR(@_);
}#endsub Error
###############################################################################
sub REPORT_ERROR { # print ERROR message to stdout & log if open <<<1
  # USAGE: &REPORT_ERROR(MESSAGE[,TAG]); use sprintf within if needed
  my $msg = shift @_;
  chomp $msg;
  my $tag = '';
  $tag = shift @_ if scalar @_ > 0;
  my $fmtd = '';
  $fmtd = sprintf("ERROR%s: ",$tag) unless $msg =~ m{^ERROR\b};
  $fmtd .= sprintf("%s\n",$msg);
  if ($openlog) {
    print STDLOG $fmtd;
  } else {
    push @BUFLOG,$fmtd;
  }#endif
  print STDOUT $fmtd;
  ++$error_count;
}#endsub REPORT_ERROR

###############################################################################
sub FatalError { # print FATAL message to stdout & log if open, but no exit (see REPORT_FATAL) <<<1
  # USAGE: &FatalError(MESSAGE[,TAG]); use sprintf within if needed
  my $msg = shift @_;
  chomp $msg;
  my $tag = '';
  $tag = shift @_ if scalar @_ > 0;
  my $fmtd = '';
  $fmtd = sprintf("FATAL%s: %s\n",$tag) unless $msg =~ m{^FATAL\b};
  $fmtd .= sprintf("%s\n",$msg);
  if ($openlog) {
    print STDLOG $fmtd;
  } else {
    push @BUFLOG,$fmtd;
  }#endif
  print STDOUT $fmtd;
  ++$fatal_count;
}#endsub FatalError

###############################################################################
sub Carp { # alias for REPORT_ERROT <<<1
  &REPORT_ERROR(@_);
}#endsub Carp

###############################################################################
sub Cluck { # print ERROR message with stack trace to stdout & log if open <<<1
  # USAGE: &Cluck(MESSAGE[,TAG]); use sprintf within if needed
  my $msg = shift @_;
  chomp $msg;
  $msg = Carp::longmess($msg);
  my $tag = '';
  $tag = shift @_ if scalar @_ > 0;
  my $fmtd = '';
  $fmtd = sprintf("ERROR%s: %s\n",$tag) unless $msg =~ m{^ERROR\b};
  $fmtd .= sprintf("%s\n",$msg);
  if ($openlog) {
    print STDLOG $fmtd;
  } else {
    push @BUFLOG,$fmtd;
  }#endif
  print STDOUT $fmtd;
  ++$error_count;
}#endsub Cluck

###############################################################################
sub Internal { # print INTERNAL ERROR message with stack trace <<<1
  # USAGE: &Internal(MESSAGE[,TAG]); use sprintf within if needed
  my $msg = shift @_;
  chomp $msg;
  $msg = Carp::longmess($msg);
  my $tag = '';
  $tag = shift @_ if scalar @_ > 0;
  my $fmtd = sprintf("INFERNAL ERROR%s: %s\n",$tag,$msg);
  if ($openlog) {
    print STDLOG $fmtd;
  } else {
    push @BUFLOG,$fmtd;
  }#endif
  print STDOUT $fmtd;
  ++$error_count;
}#endsub Internal

###############################################################################
sub Croak { # alias for REPORT_ERROR <<<1
  &REPORT_FATAL(@_);
}#endsub Croak
###############################################################################
sub REPORT_FATAL { # print FATAL message to stdout & log if open <<<1
  # USAGE: &REPORT_FATAL(MESSAGE); use sprintf within if needed
  # See 'perldoc carp' for information that motivated this routine
  # NOTE: No need to buffer because we're exiting anyhow.
  my ($msg) = @_;
  chomp $msg;
  print STDERR "FATAL: $msg\n";
  print STDLOG "FATAL: $msg\n" if $openlog;
  ++$fatal_count;
  exit 2;
}#endsub REPORT_FATAL

###############################################################################
sub Confess { # print FATAL message with stack trace to stdout & log if open <<<1
  # See 'perldoc carp' for information that motivated this routine
  # NOTE: No need to buffer because we're exiting anyhow.
  my ($msg) = @_;
  chomp $msg;
  $msg = Carp::longmess($msg);
  print STDERR "FATAL: $msg\n";
  print STDLOG "FATAL: $msg\n" if $openlog;
  ++$fatal_count;
  exit 3;
}#endsub Confess

###############################################################################
sub Banner { # Creates and returns a string banner <<<1
  return if exists $OPT{-nobanner} or exists $OPT{-quiet};
  my @in;
  push @in,shift(@_);
  my $max = 12;
  while (@_) {
    my $arg = shift @_;
    if ($arg =~ m{^-(\d)}) {
      $max = $1;
    } else {
      push @in,$arg;
    }#endif
  }#endwhile
  my @out;
  for my $in (@in) {
    while (length($in) > $max and rindex($in,' ',$max)>0) {
      push @out,substr($in,0,rindex($in,' ',$max));
      substr($in,0,rindex($in,' ',$max)+1) = '';
    }#endwhile
    push @out,$in;
  }#endfor
  my $rslt = '';
  for my $msg (@out) {
    open BANNER,"$banner_pgm $msg|" or &Confess("Unable to pipe banner!?");
    BANNER->autoflush(1);
    $rslt .= join('',<BANNER>);
    close BANNER;
  }#endfor
  return $rslt;
}#endsub Banner

###############################################################################
sub Box { # add a box around text #<<<1
=pod

=head2 $text = B<&Box>(I<OPTIONS,>@MSG...);

 -border => #    character to use for border
 -center => 0|1  whether to center each line
 -width  => #    width of border
 -max    => #    width of message (defaults to max length of @MSG

=cut

  my %arg;
  my $msg = '';
  while (scalar @_) {
    my $opt = shift @_;
    if ($opt =~ m{^-(border|center|width|max)$} and not defined $arg{$opt}) {
      $arg{$opt} = shift @_;
    } else {
      chomp $opt; chomp $opt;
      $msg .= $opt."\n";
    }#endif
  }#endwhile
  $arg{-border} = '#' unless exists $arg{-border};
  $arg{-center} = 1 unless exists $arg{-center};
  $arg{-width}  = 1 unless exists $arg{-width};
  my @msg = split(m{\n},$msg);
  if (not exists $arg{-max}) {
    $arg{-max} = 0;
    foreach (@msg) {
      $arg{-max} = length if length > $arg{-max};
    }#endforeach
  }#endif
  my ($fl,$fr);
  foreach $msg (@msg) {
    if ($arg{-center}) {
      $fr = ($arg{-max}-length($msg))/2;
      $fl = int($fr);
      $fr = ($fr > $fl) ? ($fl+1) : ($fl);
    } else {
      $fl = 0;
      $fr = $arg{-max} - length($msg);
    }#endif
    $msg = ($arg{-border} x $arg{-width}).(' ' x $arg{-width})
         . (' ' x $fl).$msg.(' ' x $fr)
         . (' ' x $arg{-width}).($arg{-border} x $arg{-width});
  }#endforeach
  $arg{-max} += 4 * $arg{-width};
  push(@msg,$arg{-border} x $arg{-max});
  unshift(@msg,$arg{-border} x $arg{-max});
  join("\n",@msg) . "\n";
}#endsub Box

###############################################################################
our $do_exit = 0; # <<<1
sub Exit { $do_exit = 1; exit $_[0]; } # (backward compatible) <<<1 
END { &do_exit if $do_exit; }
sub do_exit { # exit closing log with warning/error count <<<1
  &REPORT_INFO(sprintf("%s %s exited with %d warnings, %d errors, and %d fatals",
                $FindBin::RealScript,&Quoteargs(@main::ORIG),$warn_count,$error_count,$fatal_count));
  if ($openlog) {
    print STDLOG "\n#EOF $logfile\n";
    close STDLOG;
  }#endif
  rename $logfile."-tmp#$$", $logfile;
  sleep 1; # ensure this log file is older than caller's
  $? = 127 if $error_count != 0 and $? == 0;
}#endsub Exit

###############################################################################
sub Dir_file { # alias for &path <<<1
  # Deprecated
  return wantarray ? &path(@_) : scalar &path(@_);
}#endsub Dir_file

###############################################################################
our %PATHSEEN;
our $searching=0;
sub path { # Return full path given the current directory & a file relative to it <<<1
  ++$searching;
  my ($dir);
  my $owd = &getcwd();
  my ($cwd,$file,$follow) = ('','',0);
  for my $arg (@_) {
    if ($arg eq '-follow') {
      $follow=1;
    } elsif ($arg eq '-nfollow') {
      $follow=0;
    } elsif ($file eq '') {
      $file = $arg;
    } elsif ($cwd eq '') {
      $cwd  = $file;
      $file = $arg;
    } else {
      &REPORT_ERROR("Extra argument passed to &pscr::path()");
    }#endif
  }#endfor
  $cwd = '' if $file =~ m{^/};
  $file =~ s{/(\./)+}{/}g; # remove crap (e.g. a/./b/././c becomes a/b/c)
  $file =~ s{//+}{/}g; # remove extra slashes (e.g. a/////b becomes a/b)
  $file =~ s{/(\.?)$}{}; # remove trailing / or /.
  &Confess("Empty filename '$file'!?") unless $file =~ m/\S/;
  unless ($file =~ m{.*/}) {
    # Simple filename
    chdir $cwd;
    $dir = &getcwd();
    if ($follow and -l $file and not exists $PATHSEEN{$cwd,$file}) {
      $PATHSEEN{$cwd,$file}=1;
      ($cwd,$file) = &path($cwd,readlink($file),"-follow");
    }#endif
    %PATHSEEN = () unless --$searching;
    chdir $owd;
    return wantarray ? ($cwd,$file) : "$cwd/$file";
  }#endunless
  # Has some directory path elements
  ($dir,$file) = ($&,$'); # separate the directory from the filename
  chdir $cwd if defined $cwd and $cwd ne '' and -d $cwd;
  if (! -d $dir) {
    &REPORT_ERROR("Unable to locate $dir!?");
    chdir $owd;
    if ($follow and -l $file and not exists $PATHSEEN{$dir,$file}) {
      $PATHSEEN{$dir,$file}=1;
      ($dir,$file) = &path($dir,readlink($file),"-follow");
    }#endif
    %PATHSEEN = () unless --$searching;
    return wantarray ? ($dir,$file) : "$dir/$file";
  }#endif
  chdir $dir;
  $dir = &getcwd();
  &REPORT_ERROR("Unable to read file '$file' $!!?") unless -r $file;
  chdir $owd;
  if ($follow and -l $file and not exists $PATHSEEN{$dir,$file}) {
    $PATHSEEN{$dir,$file}=1;
    ($dir,$file) = &path($dir,readlink($file),"-follow");
  }#endif
  %PATHSEEN = () unless --$searching;
  return wantarray ? ($dir,$file) : "$dir/$file";
}#endsub path

###############################################################################
sub Glob { # return file glob matching regex <<<1
  my $re = shift @_;
  my $dir = './';
  $dir = $& if $re =~ s{.*/}{};
  chop $dir;
  $dir = '/' if $dir eq '';
  opendir DIR,$dir;
  my @dir = grep(m{$re},readdir DIR);
  closedir DIR;
  return @dir;
}#endsub Glob

###############################################################################
sub Dictionary_order { #<<<1
  my ($a,$b) = @_;
  return (defined $a cmp defined $b) unless defined $a and defined $b;
  if ($a =~ m{\d} and $b =~ m{\d}) {
    my ($A,$B) = ($a,$b);
    my (@a,@b);
    @a=();
    while (length $A) {
      if ($A=~s{^\d+}{}) {
        push @a,$&;
      } elsif ($A=~s{^\D+}{}) {
        push @a,$&;
      }#endif
    }#endwhile
    @b=();
    while (length $B) {
      if ($B=~s{^\d+}{}) {
        push @b,$&;
      } elsif ($B=~s{^\D+}{}) {
        push @b,$&;
      }#endif
    }#endwhile
    while (scalar(@a) && scalar(@b)) {
      $A=shift @a;
      $B=shift @b;
      next if $A eq $B;
      if ($A=~m{^\d} and $B=~m{^\d}) {
        return ($A <=> $B);
      } else {
        return ($A cmp $B);
      }#endif
    }#endwhile
    return (scalar(@a) <=> scalar(@b));
  } else {
    return ($a cmp $b);
  }#endif
}#endsub Dictionary_order

#-----------------------------------------------------------------------------
sub Existingbynum { # sort existing files numerically <<<1
  $a =~ m/-#(\d+)/;
  my $A = $1;
  $b =~ m/-#(\d+)/;
  my $B = $1;
  return ($A <=> $B);
}#endsub Existingbynum

###############################################################################
sub Quoteargs { # quote arguments for CMND logging <<<1
  my $result = '';
  for my $arg (@_) {
    if ($arg =~ m/[ \t"'\\]/) {
      $arg =~ s/\\/\\\\/g;
      $arg =~ s/'/\\'/g;
      $result .= qq{'$arg' };
    } else {
      $result .= qq{$arg };
    }#endif
  }#endfor
  chop $result;
  return $result;
}#endsub Quoteargs

###############################################################################
sub Save_existing { # Rename existing filenames to prepare for new <<<1
  for my $targ (@_) {
    my $existing_file = $targ;
    next if not -e $existing_file;
    my $i;
    my $extn = '.log';
    $extn = $& if $existing_file =~ s{\.[^.]+$}{};
    $i = 1;
    my @old = sort Existingbynum &Glob(qq{$existing_file-#\\d+$extn});
    if (@old) {
      $old[$#old] =~ m/-#(\d+)/;
      $i = $1;
    }#endif
    while (-e "$existing_file-#$i$extn") {
      ++$i;
    }#endif
    my ($fm,$to) = ("$existing_file$extn","$existing_file-#$i$extn");
    &REPORT_INFO("mv $fm $to\n");
    rename $fm,$to;
    if (exists $OPT{-limit} and $OPT{-limit} > 0) {
      while (@old >= $OPT{-limit}) {
        my $f = shift @old;
        unlink $f;
      }#endwhile
    }#endif
  }#endfor
}#endsub Save_existing

###############################################################################
sub Open_log { # Opens the STDLOG file stream <<<1
  $do_exit = 1;
  my $log = shift @_;
  $log .= '.log' unless $log =~ m/\.\w+$/;
  $log =  $start_dir.'/'.$log if index($log,'/') < 0;
  $logfile = $log;
  &Save_existing($log);
  my $logdir = $log;
  $logdir =~ s{/[^/]+$}{};
  if ((-r $log and not -w $log) or not -w $logdir) {
     &REPORT_INFO("Unable to write to $log -> redirecting to /tmp");
     $log =~ s:.*/:/tmp/:;
  }#endif
  open STDLOG,">$log-tmp#$$" or &REPORT_FATAL("Unable to open $log-tmp#$$ for writing!?");
  STDLOG->autoflush(1);
  printf STDLOG "#%s\n",('#' x 60);
  printf STDLOG "# %s log file\n",$main::RealScript;
  printf STDLOG "# \n";
  printf STDLOG "# TESTNAME: %s\n",$OPT{-testname} if exists $OPT{-testname};
  no warnings;
  if (defined $main::start_time) {
    printf STDLOG "# CREATED:  %s\n",$main::start_time;
  } else {
    printf STDLOG "# CREATED:  %s\n",scalar localtime;
  }#endif
  if (defined $main::tool) {
    printf STDLOG "# TOOL:     %s %s\n",$main::tool,$main::revn;
  } else {
    printf STDLOG "# TOOL:     %s/%s\n",$main::RealBin,$main::RealScript;
  }#endif
  printf STDLOG "# USER:     %s\n",$USER;
  printf STDLOG "# HOST:     %s\n",$HOST;
  printf STDLOG "# ARCH:     %s\n",$ARCH;
  use warnings;
  printf STDLOG "# WORKDIR:  %s\n",$start_dir;
  printf STDLOG "# ENV:      %s=%s\n",$rc_var,$ENV{$rc_var} if exists $ENV{$rc_var};
  no warnings;
  printf STDLOG "# CMND:     %s/%s %s\n",$FindBin::RealBin,$FindBin::RealScript,&Quoteargs(@main::ORIG);
  use warnings;
  printf STDLOG "\n";
  &REPORT_INFO("Logging to $log");
  print  STDLOG @BUFLOG;
  @BUFLOG = ();
  $openlog = 1;
}#endsub Open_log

###############################################################################
sub Columns { # reorder table for specified number of columns <<<1
  # Allows nicer formatted tables when sorting
  # 2,(1 2 3 4 5 6 7) => (1 5 2 6 3 7 4 undef)
  # 3,(1 2 3 4 5 6 7) => (1 4 7 2 5 undef 3 undef undef)
  my $nc = shift @_;
  &Internal("Columns must be non-zero count") if $nc <= 0;
  my $ne = scalar(@_);
  &Internal("No elements to reorder") if $ne == 0;
  my $nr = ($ne + ($nc-$ne%$nc))/$nc;
  my @result = ();
  for my $r (0..$nr-1) {
    for my $c (0..$nc-1) {
      my $i = $c*$nr + $r;
      push @result,($i < $ne)?$_[$i]:undef;
    }#endfor
  }#endfor
  return @result
}#endsub Columns

###############################################################################
sub Trim { # remove leading/trailing whitespace <<<1
  my $text = shift @_;
  $text =~ s/^\s+//s;
  $text =~ s/\s+$//s;
  return $text;
}#endsub Trim

###############################################################################
sub FmtSystem { # Format system calls for printing <<<1
  @_ = split(' ',$_[0]) if @_ == 1;
  my @args = @_;
  my $rslt = shift(@args);
  my $posn = length $rslt;
  while (@args) {
    my $arg = shift(@args);
    $posn += 1 + length $arg;
    if ($posn > 40 or $arg =~ m/=/ or ($arg =~ m/^-/ and $args[0] !~ m/^-/)) {
      if (not $OPT{-nowrap}) {
        $rslt .= "\\\n ";
        $posn = 1 + length $arg;
      }#endif
    }#endif
    $rslt .= " ".$arg;
    if ($arg =~ m/^-/) {
      next if @args and $args[0] =~ m/^-/;
      next unless @args;
      $arg = shift(@args);
      $rslt .= " ".$arg;
      $posn += 1+ length $arg;
    }#endif
  }#endwhile
  return $rslt;
}#endsub FmtSystem

###############################################################################
sub SystemParse { #<<<1
  # This subroutine parses a command line passed to &System and makes
  # sure to properly handle quotes (' & ").
  return '' unless scalar(@_) > 0;
  my $cmd = shift @_;
  my $inq = '';
  my $word = '';
  my @tokens;
  for my $c (split('',$cmd)) {
    if ($inq ne '') {
      if ($c eq $inq) {
        $inq = '';
      } else {
        $word .= $c;
      }#endif
    } elsif ($c =~ m/['"$;]/) {
      $inq = $c;
    } elsif ($c =~ m/\s/) {
      push @tokens,$word if $word ne '';
      $word = '';
    } else {
      $word .= $c;
    }#endif
  }#endfor
  push @tokens,$word if $word ne '';
  &REPORT_FATAL("System parse error for {$cmd}") if $inq ne '';
  return @tokens;
}#endsub SystemParse

###############################################################################
sub System { # Execute system command after logging/displaying <<<1
  my $verbose = 0;
  my $cmd = shift @_;
  if (@_ > 0 and $_[0] eq '-verbose') {
    $verbose = 1;
    shift @_;
  }#endif
  $verbose = 1 if exists $OPT{-verbose} and $OPT{-verbose};
  my @cmd = &SystemParse($cmd);
  @cmd = ($cmd,@_) if scalar @_;
  my $fmtd = sprintf("INFO: %s\n",&FmtSystem(@cmd));
  if ($OPT{-notreally}) { $fmtd =~ s{INFO:}{INFO-NOT:}; }
  if ($openlog) {
    print STDLOG $fmtd;
  } else {
    push @BUFLOG,$fmtd;
  }#endif
  print STDOUT $fmtd if $verbose and not $OPT{-quiet};
  return if exists $OPT{-notreally} and $OPT{-notreally} == 1;
  return system(@cmd)
}#endsub System

###############################################################################
sub WrapMake { # Wrap lines created for Makefile to improve readability of output <<<1
  my $val = shift @_;
  my $len = shift @_;
  $len = 80 unless defined $len;
  if (length($val) < $len or index($val,' ',$len) == -1) {
    return $val;
  }#endif
  my $result = '';
  my $prev = '';
  for my $part (split(m{\s+},$val)) {
    if ($prev =~ m/^[-+]/ and $part !~ m/^[-]/) {
      $result .= ' '.$part;
    } else {
      $result .= "\\\n  ".$part;
    }#endif
    $prev = $part;
  }#endfor
  $result .= "\n";
  return $result;
}#endsub WrapMake

###############################################################################
sub Pipe_cmd { # Display and execute a command returning output string <<<1
  my $pgm = shift @_;
  my $result = '';
  my $cmd = "$pgm @_";
  my $pnm = $pgm;
  $pnm =~ s{.*/}{};
  my $fmtd = sprintf("INFO: %s\n",$cmd);
  if ($openlog) {
    print STDLOG $fmtd;
  } else {
    push @BUFLOG,$fmtd;
  }#endif
  print STDOUT $fmtd if $OPT{-verbose};
# return if $OPT{-notreally};
  my $errf = "/tmp/pipe-$pnm-$$";
  open PIPE,"$cmd 2>$errf |"
    or &REPORT_FATAL("Unable to pipe $pgm!?\n");
  PIPE->autoflush(1);
  while (<PIPE>) {
    chomp; chomp;
    no warnings;
    ++$main::pgm_errors if m/ERROR:/;
    ++$main::pgm_fatals if m/FATAL:/;
    use warnings;
#?  $result .= $_."\n  ";
    $result .= $_.' ';
  }#endwhile
  close PIPE;
  open  ERRF,"<$errf" or &REPORT_FATAL("Unable to read $errf!?");
  while (<ERRF>) {
    &REPORT_WARNING($_);
  }#endwhile
  close ERRF;
  unlink $errf;
  chop $result; # Remove last trailing space
  return $result;
}#endsub Pipe_cmd

sub System_pipe { # Display and execute a command logging the output <<<1
  my $pipelog = 'pipe.log';
  if (scalar @_ > 1 and $_[0] eq '-log') {
    shift @_;
    $pipelog = shift @_;
  }#endif
  my $pgm = shift @_;
  my $status = 0;
  my $cmd = "$pgm @_";
  my $pnm = $pgm;
  $pnm =~ s{.*/}{};
  my @cmd = &SystemParse($cmd);
  @cmd = ($cmd,@_) if scalar @_;
  my $fmtd = sprintf("INFO: %s\n",&FmtSystem(@cmd));
  if ($openlog) {
    print STDLOG $fmtd;
  } else {
    push @BUFLOG,$fmtd;
  }#endif
  print STDOUT $fmtd if $OPT{-verbose};
# return if $OPT{-notreally};
  open PIPELOG,">$pipelog"
    or &REPORT_FATAL("Unable to write $pipelog!?\n");
  open PIPE,"$cmd 2>&1 |"
    or &REPORT_FATAL("Unable to pipe $pgm!?\n");
  PIPE->autoflush(1);
  while (<PIPE>) {
    print;
    print PIPELOG $_;
    chomp; chomp;
    no warnings;
    if (m/ERROR:/) { ++$main::pgm_errors; $status |= 1; }
    if (m/FATAL:/) { ++$main::pgm_fatals; $status |= 2; }
    use warnings;
  }#endwhile
  close PIPE;
  $status |= 3 if $?;
  close PIPELOG;
  return $status;
}#endsub System_pipe

###############################################################################
sub FileSignature { # return a unique state for a file #<<<1
  my ($path) = @_;
  if (-r $path) {
    my $sum = qx{cksum $path};
    chomp $sum;
    $sum =~ s/ /./;
    $sum =~ s/ .*//;
    return sprintf("%d.%s",(-s $path),$sum);
  } else {
    return 'nonexistant';
  }#endif
}#endsub FileSignature

###############################################################################
sub WaitFileChanged { # Wait for a file to change #<<<1
  my %state;
  for my $path (@_) {
    $path = &path(&getcwd,$path);
    $state{$path} = &FileSignature($path);
  }#endfor
  while (1) {
    sleep 6;
    for my $path (@_) {
      next unless $state{$path} ne &FileSignature($path);
      &REPORT_INFO("File $path changed") if &Opt('-verbose') or &Opt('-squeal');
      return $path;
    }#endfor
  }#endwhile
}#endsub WaitFileChanged

###############################################################################
our %activeLsf;
our %endedJob;

###############################################################################
sub Bsub { # Run a process under LSF #<<<1
  my ($lsfq,$log,$mail,$tool,@ARGS) = @_;
  return system("$bsub_pgm -q $lsfq -o $log -J bmake $mail $tool @ARGS");
}#endsub Bsub

###############################################################################
sub WaitAllJobsDone { # Wait until the status of active jobs changes # <<<1
  return unless &ActiveJobs;
  my $jn = 'WtAllDone';
  my $wait_cmd = qq{$bsub_pgm -I -J $jn};
  # Set mail if requested
  $wait_cmd .= " -N -u $ENV{MAILTO}" if defined $ENV{MAILTO};
  # Set up the condition that allows this job to proceed
  my @jobs = keys %activeLsf;
  $wait_cmd .= " -w 'ended($jobs[0])";
  for my $jdx (1..$#jobs) {
    $wait_cmd .= " && ended($jobs[$jdx])";
  }#endfor
  $wait_cmd .= q{' sleep 2 >/dev/null 2>&1};
  &REPORT_INFO("Waiting for all jobs in @jobs to finish");
  system($wait_cmd);
}#endsub WaitAllJobsDone

###############################################################################
sub WaitNextJobDone { # Wait until the status of active jobs changes # <<<1
  my $jn = 'WtNxtDone';
  my $wait_cmd = qq{$bsub_pgm -I -J $jn -w '};
  # Set up the condition that allows this job to proceed
  my @jobs = keys %activeLsf;
  return unless @jobs;
  $wait_cmd .= "ended($jobs[0])";
  for my $jdx (1..$#jobs) {
    $wait_cmd .= " || ended($jobs[$jdx])";
  }#endfor
  $wait_cmd .= q{' exit >/dev/null 2>&1};
  &REPORT_INFO('Waiting for completion of any of the LSF jobs '.join(', ',@jobs).'.');
  system($wait_cmd);
}#endsub WaitNextJobDone

###############################################################################
sub ActiveJobs { # Add a job to the list of active jobs & return count # <<<1
  my %test = @_;
  for my $job (keys %test) {
    $activeLsf{$job} = $test{$job};
  }#endfor
  return scalar keys %activeLsf;
}#endsub ActiveJobs

###############################################################################
sub EndedJobs { # Compare actual jobs vs. active # <<<1
  return () unless &ActiveJobs;
  my $lsf_cmd = "bjobs";
  my $pgm = $lsf_cmd;
  my $pnm = $lsf_cmd;
  $pnm =~ s{.*/}{};
  my $fmtd = sprintf("INFO: %s\n",$lsf_cmd);
  if ($openlog) {
    print STDLOG $fmtd;
  } else {
    push @BUFLOG,$fmtd;
  }#endif
  my %actual;
  open PIPE,"$lsf_cmd 2>/dev/null |"
    or &REPORT_FATAL("Unable to pipe $pgm!?\n");
  PIPE->autoflush(1);
  while (<PIPE>) {
    chomp; chomp;
    next unless m/^(\d+)\s+/;
    $actual{$1} = 1;
  }#endwhile
  close PIPE;
  my @ended;
  for my $job (keys %activeLsf) {
    next if exists $actual{$job};
    push @ended,$activeLsf{$job};
    delete $activeLsf{$job};
  }#endfor
  return @ended; # So we can examine the results
}#endsub EndedJobs

###############################################################################
sub Cargs { # Pipe arguments thru cargs program <<<1
  return &Pipe_cmd($cargs_pgm,@_);
}#endsub Cargs

###############################################################################
sub Safedef { # Pipe arguments thru safedef program <<<1
  return &Pipe_cmd($safedef_pgm,@_);
}#endsub Safedef

###############################################################################
sub ReadMk { # read a makefile and return the essentials <<<1
  my ($f) = @_;
  my @F;
  open F,"<$f" or &REPORT_FATAL("Unable to read $f");
  while (<F>) {
    chomp;
    next if m/^\s*$/ or m/^\s*#/; # Ignore comments and whitespace
    s/\s+$//;
    s/ +/ /g; # compress whitespace
    push @F,@_;
  }#endwhile
  close F;
  return @F;
}#endsub ReadMk

###############################################################################
sub DiffMk { # compare two makefiles and return 1 if different 0 else <<<1
  my ($f1,$f2) = @_;
  my @F1 = &ReadMk($f1);
  my @F2 = &ReadMk($f2);
  return 1 if scalar(@F1) != scalar(@F2); # Different number of lines
  while (@F1 and @F2) {
    return 1 if $F1[0] ne $F2[0];
    shift @F1;
    shift @F2;
  }#endwhile
  return 0;
}#endsub DiffMk

###############################################################################
sub Def2Make { # Convert -Dmacro to %Var entries <<<1
  my $val;
  for my $var (split(m/\s+/,$_[0])) {
    next unless $var =~ s/^-D//;
    $val = '';
    $val = $1 if $var =~ s/=(.*)//;
    no warnings;
    $main::Var{$var} = $val;
    use warnings;
  }#endfor
}#endsub Def2Make

###############################################################################
sub ShortDate { # localtime to YYYY-MM-DD HH:MM <<<1
  if (scalar(@_) == 1) {
    my $when = $_[0];
    return "-" unless defined $when and $when =~ m{\w{3} \w{3}\s{1,2}\d{1,2} \d{2}:\d{2}:\d{2} [AP]M \d{4}};
    my %MO = (
      'Jan' => 1, 'Feb' =>  2, 'Mar' =>  3, 'Apr' =>  4,
      'May' => 5, 'Jun' =>  6, 'Jul' =>  7, 'Aug' =>  8,
      'Sep' => 9, 'Oct' => 10, 'Nov' => 11, 'Dec' => 12,
    );
    my @when=split(m/ +/,$when);
    my @tim = split(m/:/,$when[3]);
    $tim[0] += 12 if $when[4] eq 'PM' and $tim[0] < 12;
    $tim[0] -= 12 if $when[4] eq 'AM' and $tim[0] == 12;
    my $tim = join(':',@tim);
    return sprintf("%4d-%02d-%02d %s",$when[5],$MO{$when[1]},$when[2],$tim);
  } else {
    my  ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = @_;
    return sprintf("%4d-%02d-%02d %0d:%02d",$year+1900,$mon,$mday,$hour,$min);
  }#endif
}#endsub ShortDate

###############################################################################
sub Sec2dhms { # Convert seconds to printable days hours:minutes:seconds <<<1
  my $time = int($_[0]+0.5);
  my $sec = $time % 60; $time = int($time/60);
  my $min = $time % 60; $time = int($time/60);
  my $hrs = $time % 24; $time = int($time/24);
  my $day = $time;
  if ($day > 0) {
    return sprintf("%d %d:%02d:%02d",$day,$hrs,$min,$sec);
  } else {
    return sprintf("%d:%02d:%02d",$hrs,$min,$sec);
  }#endif
}#endsub Sec2dhms

###############################################################################
#sub Unique - ensure string contains only unique words <<<1
# Given a whitespace delimited string, split it into tokens and ensure
# that each token appears only once (i.e. it is unique). First occurence
# of each token is kept. Thus 'a b b c a' becomes 'a b c'.
sub Unique {
  my $str = shift @_;
  my @list;
  for my $elt (split(m/\s+/,$str)) {
    next if grep($elt eq $_,@list);
    push @list,$elt;
  }#endfor
  return join(' ',@list);
}#endsub Unique

###############################################################################
sub UniqueList { # ensure list contains only unique values #<<<1
  my (@list,%list);
  for my $value (@_) {
    next if exists $list{$value};
    push @list,$value;
    $list{$value} = 1;
  }#endfor
  return @list;
}#endsub UniqueList

###############################################################################
sub Parent_dirs { # Return list of all parent directories #<<<1
  #----------------------------------------------------------------------------
  # Example: &Parent_dirs('/A/B/C/D') returns ('/A/B/C','/A/B','/A')
  #----------------------------------------------------------------------------
  my (@dirs) = @_;
  my $tdir;
  my (@list);
  foreach $tdir (@dirs) {
    $tdir =~ s:/\./:/:g; # Change */./* to */*
    $tdir =~ s://+:/:g;  # Change *//*  to */*
    push(@list,$tdir) while ($tdir =~ s:/[^/]+$::);
  }#endforeach $tdir
  return @list;
}#endsub Parent_dirs

###############################################################################
sub KeepIfDiff { #<<<1
  my $file1 = shift @_;
  my $file2 = "$file1-tmp";
  $file2 = shift @_ if @_;
  if (-r $file1 && system("cmp $file1 $file2") == 0) {
    # Same
    &REPORT_INFO("No change in $file1");
    unlink "$file2"
  } else {
    # Different
    &REPORT_INFO("Updating $file1");
    &Save_existing($file1);
    rename $file2,$file1;
  }#endif
}#endsub KeepIfDiff

###############################################################################
sub Mkhdlvar { # Create Cadence hdl.var file if needed #<<<1
  my $hdl_var = shift @_;
  open   HDLVAR,">$hdl_var-tmp";
  HDLVAR->autoflush(1);
  printf HDLVAR "define VIEW_MAP ( \$VIEW_MAP, .v => v)\n";
  printf HDLVAR "define VIEW_MAP ( \$VIEW_MAP, .vh => vh)\n";
  if (-r "hdlvar.args") {
    open HDLARGS,"<hdlvar.args" or &REPORT_FATAL("Unable to read hdlvar.args!?");
    while (<HDLARGS>) {
      # Skip comments & whitespace
      s{//.*}{};
      s{#.*}{};
      next if m{^\s*$};
      # Options become commands
      if (m/^\s*--(\w+\s+)/) {
        printf HDLVAR "%s %s",uc($1),$';
      }#endif
    }#endwhile
    close HDLARGS;
  }#endif
  close  HDLVAR;
  &KeepIfDiff($hdl_var);
}#endsub Mkhdlvar

###############################################################################
sub Mkcdslib { # Create Cadence cds.lib file if needed #<<<1
  my ($cds_lib,$lib,$work_dir) = @_;
  open   CDSLIB,">$cds_lib-tmp";
  CDSLIB->autoflush(1);
  printf CDSLIB "define $lib %s\n",$work_dir;
  if (-r "cdslib.args") {
    open CDSARGS,"<cdslib.args" or &REPORT_FATAL("Unable to read cdslib.args!?");
    while (<CDSARGS>) {
      # Skip comments & whitespace
      s{//.*}{};
      s{#.*}{};
      next if m{^\s*$};
      # Options become commands
      if (m/^\s*--(\w+\s+)/) {
        printf CDSLIB "%s %s",uc($1),$';
      }#endif
    }#endwhile
    close CDSARGS;
  }#endif
  close  CDSLIB;
  &KeepIfDiff($cds_lib);
}#endsub Mkcdslib

###############################################################################
sub Mkshell { # #<<<1
  my $owd = &getcwd();
  my $worklib = 'work';
  my $tmpdir = "$start_dir/shell";
  mkdir $tmpdir,0777;
  chdir $tmpdir;
  &Mkhdlvar('hdl.var');
  &Mkcdslib('cds.lib',$worklib,$tmpdir);

  #------------------------------------------------------------------------------
  # Remove duplicate work (kludge) - also scan for --limit
  #------------------------------------------------------------------------------
  my @ARGV2;
  my $has_work = 0;
  my ($top_vlg);
  while (@_) {
    my $arg = shift @_;
    if ($arg =~ m{^-WORK$}i) {
      $arg = shift @_; # grab the library name
      push @ARGV2,'-WORK',$arg unless $has_work;
      $has_work = 1;
    } elsif ($arg =~ m/^-+limit\b/) {
      if ($arg =~ m/^-+limit=?(\d+)$/) {
        $OPT{-limit} = $1;                   
      } elsif ($_[0] !~ m/^\d+$/) {
        $OPT{-limit} = shift @_;
      } else {
        $OPT{-limit} = 3;                   
      }#endif
    } elsif (defined $top_vlg) {
      push @ARGV2,$arg;
    } else {
      $top_vlg = $arg;
    }#endif
  }#endwhile
  my $top_hdr = $top_vlg;
  $top_hdr =~ s{\.v$}{.h};
  $top_hdr .= '.h' unless $top_hdr =~ m{\.h$};
  $top_hdr =~ s{.*/}{};
  my $top_mdl = $top_hdr;
  $top_mdl =~ s{\.h$}{};
  my $status = 0;

  #------------------------------------------------------------------------------
  # Process top level verilog with ncvlog
  #------------------------------------------------------------------------------
  my $ncvlog_cmd = "ncvlog -messages";
  $ncvlog_cmd .= "-work $worklib" unless $has_work;
  $ncvlog_cmd .= " $top_vlg @ARGV2 2>&1";
  &REPORT_INFO('% '.$ncvlog_cmd);
  open NCVLOG,"$ncvlog_cmd 2>&1 |" or &REPORT_FATAL("Unable to pipe ncvlog");
  NCVLOG->autoflush(1);
  while (<NCVLOG>) {
    if (m/\w+: \*F,\w+:/) {
      &FatalError($_);
      $status = 1;
      last;
    } elsif (m/\w+: \*E,\w+:/) {
      &REPORT_ERROR($_);
    } elsif (m/\w+: \*W,\w+:/) {
      &REPORT_WARNING($_);
    } else {
      &REPORT_INFO($_);
    }#endif
  }#endwhile
  close NCVLOG;
  $status = $?;
  if ($status != 0) {
    chdir $owd;
    return $status;
  }#endif

  #------------------------------------------------------------------------------
  # Process with ncshell
  #------------------------------------------------------------------------------
  my $ncshell_cmd = "ncshell -nocompile -messages -work $worklib -import verilog -into systemc";
  $ncshell_cmd .= "  $worklib.$top_mdl 2>&1";
  &REPORT_INFO('% '.$ncshell_cmd);
  open NCSHELL,"$ncshell_cmd 2>&1 |" or &REPORT_FATAL("Unable to pipe ncshell");
  NCSHELL->autoflush(1);
  while (<NCSHELL>) {
    if (m/\w+:\s+\*F,\w+:/) {
      &FatalError($_);
      $status = 1;
      last;
    } elsif (m/\w+:\s+\*E,\w+:/) {
      &REPORT_ERROR($_);
    } elsif (m/\w+:\s+\*W,\w+:/) {
      &REPORT_WARNING($_);
    } else {
      &REPORT_INFO($_);
    }#endif
  }#endwhile
  close NCSHELL;
  $status += $?;
  if ($status != 0) {
    chdir $owd;
    return $status;
  }#endif

  &KeepIfDiff("$start_dir/$top_hdr","$tmpdir/$top_hdr") unless $status != 0;

  chdir $owd;
  return $status;

}#endsub Mkshell

###############################################################################
#sub locks_wanted { # For use by Lock & Unlock # <<<1
our @LOCKS_FOUND;
sub locks_wanted {
  push @LOCKS_FOUND,$File::Find::name if m/^.*\.lck\z/s and -l $_;
}#endsub locks_wanted

###############################################################################
sub Lock { # Establish a mutex via a file #<<<1
  #----------------------------------------------------------------------------
  # SYNTAX: $id = &Lock([-nb,]FILE,ID[,-nb]);
  #         &Lock(-list[=>DIRECTORY]);
  # Returns nil if nonblocking (-nb) and fails
  #----------------------------------------------------------------------------
  #
  if ($_[0] =~ m{^-(list)$}) {
    #--------------------------------------------------------------------------
    # Handle the 'lock -list' syntax
    #--------------------------------------------------------------------------
    my ($where) = @_;
    $where = '.' unless defined $where;
    @LOCKS_FOUND = ();
    File::Find::find({wanted => \&locks_wanted}, $where);
    for my $path (sort @LOCKS_FOUND) {
      printf "%s -> %s\n",$path,readlink($path);
    }#endfor
    return 'LISTED';
  }#endif

  #----------------------------------------------------------------------------
  # Ignore locking unless ALLOW_LOCKS is defined and NOLOCKS is not defined.
  #----------------------------------------------------------------------------
  return('IGNORED') unless defined $ENV{'ALLOW_LOCKS'} and not defined $ENV{'NOLOCKS'};

  my $nonblocking = shift @_ if $_[0]  eq '-nb'; # Allow 'non-blocking' option
  $nonblocking = pop @_ if $_[$#_] eq '-nb';
  my ($lock_file,$requested_id) = @_;
  my $dir = '.';
  $dir = $& if $lock_file =~ m{.*/};
  chop $dir if length($dir) > 1;
  my $VIEW = &Clearview(&path(&getcwd,$dir));
  $requested_id .= ($VIEW ne ''?"-$VIEW":'')."-$HOST-$USER.$PPID" 
    unless $requested_id =~ m{-$USER\.\d+$};
  $lock_file .= '.lck' unless $lock_file =~ m{\.lck$};
  #
  # ASSERT: We now know the lock file's name and the locking identifier
  #
  my $start=time; # So we can report how long we wait if blocked
  my ($curr_id,$prev_id); # So we can track pre-existing lock identifiers

  #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  &REPORT_INFO("Attempting to lock $lock_file with <$requested_id>");#if &Opt('-verbose');
  ATTEMPT: while (1) {
    # Attempt to use system lockfile to create NFS resistance
    system("lockfile $lock_file-nfs");
    if (symlink $requested_id,$lock_file) {
      unlink "$lock_file-nfs";
      last ATTEMPT; # SUCCESS!
    }#endif
    # If it exists, who put it there?
    unlink "$lock_file-nfs";
    if (-l $lock_file) {
      # Somebody else might own it
      $curr_id = readlink($lock_file);
      last ATTEMPT if $curr_id eq $requested_id; # Nope it's ours - SUCCESS!
    }#endif
    &REPORT_WARNING("$lock_file currently owned by <$curr_id>\n") 
      if not defined $prev_id or $curr_id ne $prev_id;
    return '' if defined $nonblocking and $nonblocking;
    $prev_id = $curr_id;
    sleep 10;
  }#endwhile
  #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  LOCK_SUCCESS:
  &REPORT_RAW("INFO: Locked $lock_file with $requested_id");
  if (time - $start > 2) {
    &REPORT_RAW(sprintf(" waited %s",&Sec2dhms(time-$start)));
  }#endif
  &REPORT_RAW("\n");
  return $requested_id;
}#endsub Lock

###############################################################################
sub Unlock { # Remove a lock/mutex file (opposite of Lock) #<<<1
  #----------------------------------------------------------------------------
  # SYNTAX: &Unock([-[no]force,][-existing,][-file=>]FILE,[-id=]ID[,-when=>FILE]);
  #         &Unock(-mine[=>DIRECTORY]);
  #         &Unock(-all[=>DIRECTORY]);
  #----------------------------------------------------------------------------
  # # EXISTS LINK READ MATCH REMOVE = TYPE  MESSAGE       UNLESS
  # 1   N     -    -     -     -    = Fatal Missing lock  -existing
  # 2   Y     N    -     -     -    = Fatal Bad lock      
  # 3   Y     N    N     -     -    = Fatal can't read
  # 4   Y     Y    Y     N     -    = Fatal Not a match   -force
  # 5   Y     Y    Y     -     N    = Error Can't remove
  # 6   Y     Y    Y     Y     Y    = Info  Success       !-verbose
  #----------------------------------------------------------------------------
  my (%opt,$opt);
  $opt{-force} = 1 if &Opt('-force'); # Allow master default
  while (@_) {
    $opt = shift @_;
    if ($opt eq '-all') {
      $opt{-all} = 1;
      $opt{-force} = 1;
    } elsif ($opt eq '-mine') {
      $opt{-mine} = $opt;
    } elsif ($opt eq '-force') {
      $opt{-force} = 1;
    } elsif ($opt eq '-noforce') {
      $opt{-force} = 0;
    } elsif ($opt eq '-existing') {
      $opt{-existing} = 1;
    } elsif ($opt eq '-when') {
      $opt{-when} = shift @_;
    } elsif ($opt eq '-id') {
      $opt{-id} = shift @_;
    } elsif ($opt eq '-file') {
      $opt{-file} = shift @_;
    } elsif (not exists $opt{-file}) {
      $opt{-file} = $opt;
    } elsif (not exists $opt{-id}) {
      $opt{-id} = $opt;
    } else {
      &REPORT_FATAL("Bad &Unlock arguments");
    }#endif
  }#endwhile
  $opt{-force} = 0 if &Opt('-noforce'); # Allow master default
  #----------------------------------------------------------------------------
  # Handle -all & -mine
  #----------------------------------------------------------------------------
  if (exists $opt{-all} or exists $opt{-mine}) {
    $OPT{-squeal} = 1; # Be verbose
    $opt{-file} = '.' unless exists $opt{-file};
    @LOCKS_FOUND = ();
    File::Find::find({wanted => \&locks_wanted}, $opt{-file});
    # Assert all found are existing links
    for my $path (sort @LOCKS_FOUND) {
      my $locked_id = readlink($path);
      next if exists $opt{-mine} and not $locked_id =~ m{-$USER\.\d+$};
      if (exists $opt{-force}) {
        &Unlock($locked_id,$path,-force);
      } else {
        &Unlock($locked_id,$path);
      }#endif
    }#endfor
    return 0;
  }#endif
  #----------------------------------------------------------------------------
  # Basic unlock functionality starts here
  #----------------------------------------------------------------------------
  my $requested_id = $opt{-id};
  my $lock_file = $opt{-file};
  if (exists $opt{-when}) {
    my $path = shift @_;
    &REPORT_INFO("Waiting on $opt{-when}");
    &WaitFileChanged($opt{-when});
    &REPORT_INFO("Found change in $opt{-when}");
  }#endif
  my $dir = '.';
  $dir = $& if $lock_file =~ m{.*/}; # Extract directory portion
  chop $dir if length($dir) > 1;
  my $VIEW = &Clearview(&path(&getcwd,$dir));
  $requested_id .= ($VIEW ne ''?"-$VIEW":'')."-$HOST-$USER.$PPID" 
    unless $requested_id =~ m{-\w+\.\d+$};
  $lock_file .= '.lck' 
    unless $lock_file =~ m{\.lck$};
  #
  # ASSERT: We now know the lock file's name and the locking identifier
  #
  # Output messages:
  #----------------------------------------------------------------------------
  # # EXISTS LINK READ MATCH REMOVE = TYPE  MESSAGE       UNLESS
  # 1   N     -    -     -     -    = Fatal Missing lock  -existing
  # 2   Y     N    -     -     -    = Fatal Bad lock      
  # 3   Y     N    N     -     -    = Fatal can't read
  # 4   Y     Y    Y     N     -    = Fatal Not a match   -force
  # 5   Y     Y    Y     -     N    = Error Can't remove
  # 6   Y     Y    Y     Y     Y    = Info  Success       !-verbose
  #----------------------------------------------------------------------------
  my $existing_id;
  unless (scalar lstat $lock_file) { #1 missing
    return 0 if $opt{-existing};
    &REPORT_FATAL("(unlock): missing lock file $lock_file");
  }#endunless
  unless (-l $lock_file) { #2 not symlink
    &REPORT_FATAL("(unlock): bad lock file $lock_file - not symlink");
  }#endunless
  unless ($existing_id = readlink($lock_file)) { #3 not readable
    &REPORT_FATAL("(unlock): unable to read lock $lock_file") 
  }#endunless
  unless ($requested_id eq $existing_id or $opt{-force}) { #4 requested
    &REPORT_FATAL("(unlock): $lock_file is not your lock ($requested_id ne $existing_id)");
  }#endunless
  unless (unlink $lock_file) { #5 Can't remove
    &REPORT_ERROR("Unable to unlock $lock_file");
  } else { #6 Success
    &REPORT_INFO("Unlocked $lock_file") if &Opt('-verbose') or &Opt('-squeal');
    return 1;
  }#endif
  return 0;
}#endsub Unlock

###############################################################################
sub Ncsc { # #<<<1
  #------------------------------------------------------------------------------
  # SYNTAX: $status = &Ncsc($directory,$cpp_command,@cpp_options,$source);
  #------------------------------------------------------------------------------
  my $status = 0;
  my ($cdir);
  my $owd = &getcwd();
  if ($_[0] eq '-cd') {
    shift @_;
    $cdir = shift @_;
    chdir $cdir;
  }#endif
  my $ncsc_pgm = shift @_;
  my $worklib = 'work';
  my $ncsc_cmd = $ncsc_pgm;
  $ncsc_cmd .= " -messages"      unless "@_" =~ m/-messages\b/;
  $ncsc_cmd .= " -work $worklib" unless "@_" =~ m/-work /;
  for my $arg (@_) {
    if ($arg =~ m/\s/) {
      my $opt = $arg;
      $opt =~ s/"/\\"/g;
      $ncsc_cmd .= qq{ "$opt"};
    } else {
      $ncsc_cmd .= qq{ $arg};
    }#endif
  }#endfor
  my $source = $_[$#_];
  &REPORT_RAW("\n" , '#' x 78,"\n");
  &REPORT_INFO("Compiling $source");
  &REPORT_INFO('% '.$ncsc_cmd);
  open NCSC,"$ncsc_cmd 2>&1 |" or &REPORT_FATAL("Unable to pipe ncsc");
  NCSC->autoflush(1);
  my $line;
  while ($line = <NCSC>) {
    if ($line =~ m/\w+:\s+\*F,\w+:/) {
      &FatalError($line);
      ++$status;
      last;
    } elsif ($line =~ m/\w+:\s+\*E,\w+:/) {
      &REPORT_ERROR($line);
      ++$status;
    } elsif ($line =~ m/\w+:\s+\*W,\w+:/) {
      &REPORT_WARNING($line);
    } elsif ($line =~ m/error:/) {
      &REPORT_ERROR($line);
      ++$status;
    } elsif ($line =~ m/\bNo such file/) { 
      &REPORT_ERROR($line);
      ++$status;
    } else {
      &REPORT_INFO($line);
    }#endif
  }#endwhile
  close NCSC;
  $status += $?;
  chdir $owd;
  return $status;
}#endsub Ncsc

###############################################################################
sub Cpp { # #<<<1
  #----------------------------------------------------------------------------
  # SYNTAX: $status = &Cpp($directory,$cpp_command,@cpp_options,-c => $source);
  #----------------------------------------------------------------------------
  my $status = 0;
  my ($cdir);
  my $owd = &getcwd();
  if ($_[0] eq '-cd') {
    shift @_;
    $cdir = shift @_;
    chdir $cdir;
  }#endif
  my $cpp_pgm = shift @_;
  my $source = $_[$#_];
  &REPORT_RAW("\n" , '#' x 78,"\n");
  &REPORT_INFO("Compiling $source");
  my $cpp_cmd = $cpp_pgm;
  $cpp_cmd .= " @_";
  &REPORT_INFO('% '.$cpp_cmd);
  open CPP,"$cpp_cmd 2>&1 |" or &REPORT_FATAL("Unable to pipe $cpp_pgm");
  CPP->autoflush(1);
  my $line;
  while ($line = <CPP>) {
    if ($line =~ m/\berror\b/) { 
      &REPORT_ERROR($line);
      ++$status;
    } elsif ($line =~ m/\bwarning:/) { 
      &REPORT_WARNING($line);
    } elsif ($line =~ m/\bNo such file/) { 
      &REPORT_ERROR($line);
      ++$status;
    } else {
      &REPORT_INFO($line);
    }#endif
  }#endwhile
  close CPP;
  $status += $?;
  chdir $owd;
  return $status;
}#endsub Cpp

###############################################################################
sub SystemCC { # #<<<1
=pod

=head2 B<&SystemCC>

This utility serves to compile C++ files for a variety of backends.

 $status = &SystemCC>(@ARGS);

=cut

  my $status = 0;
  my $source = $_[$#_];
  our $base = $source;
  $base =~ s/\.\w+$//;
  my $dir = '.';
  $dir = $& if $source =~ m{.*/};
  chop $dir if length($dir) > 1;
  $VIEW = &Clearview(&path(&getcwd,$dir));
  my $SIGINT;
  $SIGINT = $SIG{'INT'} if defined $SIG{'INT'};
  sub HandleLock { &Unlock(-force,-id=>"compile-$VIEW-$HOST-$USER.$PPID",$base); }
  $SIG{'INT'} = \&HandleLock;
  &Lock($base,"compile-$VIEW-$HOST-$USER.$PPID");
  if ("@_" =~ m/\bncsc\b/) {
    $status = &Ncsc(@_);
  } else {
    $status = &Cpp(@_);
  }#endif
# &Savesig($base,"@_");
  #rosa
  &Unlock(-existing,-id=>"compile-$VIEW-$HOST-$USER.$PPID",$base);
  if (defined $SIGINT) {
    $SIG{'INT'} = $SIGINT;
  } else {
    delete $SIG{'INT'};
  }#endif
  return $status;
}#endsub SystemCC

###############################################################################
sub RunUserScript { # Runs a script and collects errors - returns error count #<<<1
  my $type = shift @_;
  my $TYPE = uc $type;
  my $script_errors = 0;
  return 0 unless exists $OPT{"-script.$type"};
  &REPORT_RAW
  ( "\n"
  , '#' x 78
  , "\n"
  , &Banner($TYPE)
  , '#' x 78
  , "\n"
  , sprintf("RUNNING $TYPE SCRIPT FOR TEST %s\n",$OPT{-testname})
  , '#' x 78
  , "\n"
  );
  &REPORT_INFO($OPT{"-script.$type"});
  my $line;
  open  PIPE,qq($OPT{"-script.$type"} 2>&1 |) or &REPORT_FATAL("Unable to pipe $type script!?");
  PIPE->autoflush(1);
  while ($line = <PIPE>) {
    &REPORT_RAW("$TYPE: ");
    if ($line =~ m/ERROR:/) {
      ++$script_errors;
      &REPORT_ERROR($line);
    } elsif ($line =~ m/WARNING:/) {
      &REPORT_WARNING($line);
    } else {
      &REPORT_RAW($line);
    }#endif
  }#endwhile
  close PIPE;
  return $script_errors;
}#endsub RunUserScript

###############################################################################
sub Mkdir { # Create a directory #<<<1
  my $dirpath = shift @_;
  $dirpath = $start_dir.'/'.$dirpath unless substr($dirpath,0,1) eq '/';
  $dirpath =~ s{/\./}{/}g;
  while ($dirpath =~ s{/[^/]+/\.\./}{/}) {};
  my @PATH = split(m{/+},$dirpath);
  &Internal("Oops") unless $PATH[0] eq ''; # assert first element is non-empty
  shift @PATH;
  $dirpath = '';
  for my $elt (@PATH) {
    $dirpath .= '/'.$elt;
    if (not -d $dirpath) {
      mkdir $dirpath and &REPORT_INFO("Created directory $dirpath");
    }#endif
  }#endfor
  &REPORT_ERROR("Unable to create directory $dirpath!?") unless -d $dirpath;
}#endsub Mkdir

###############################################################################
#>>>
###############################################################################
1;

__END__
=pod

=head1 AUTHOR

David C Black <dcblack@mac.com>

=cut
