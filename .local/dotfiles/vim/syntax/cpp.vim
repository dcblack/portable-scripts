" Vim syntax file
" Language:     SystemC (C++ library)
" Maintainer:   David C Black <dcblack@hldwizard.com>
" Last Updated: Thu Feb 23 06:50:33 CST 2012 dcblack

" INSTALLATION
"
"   Copy cpp.vim to $HOME/.vim/syntax/cpp.vim
"   Copy systemc.dict to $HOME/.vim/etc/systemc.dict
"   :syntax on
"
" NOTES
"
"   Assumes $VIMRUNTIME/syntax/cpp.vim
"
" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif
"let file_syntax = SystemC_or_CPP(50)
"if(file_syntax == "cpp")
"  finish
"endif

"-" Read the C++ syntax to start with
"-if version < 600
"-  so <sfile>:p:h/cpp.vim
"-else
"-  runtime! syntax/cpp.vim
"-  unlet b:current_syntax
"-endif

" SystemC extensions
" vim: ts=8;nospell

"setlocal makeprg=scc\ compile
"setlocal errorformat="%f:%l: %m"
"setlocal errorfile="build/log.dir/error.log"
"setlocal nospell
setlocal dict=$HOME/.vim/etc/systemc.dict

syntax match   template  /{:.\{-}:}/ containedin=cString,cComment,cCommentL
syntax match   statement /\(\/\/\)\@<=\<end\w*/ containedin=cComment,cCommentL
"yntax region  cString   start=+L\="+ skip=+\\\\\|\\"+ end=+"+ contains=cSpecial,cFormat,@Spell,template

let b:has_boost = 0
let b:has_greensocs = 0
let b:has_my = 1
let b:has_tlm = 0
let b:has_systemc = 1
if b:has_tlm
  let b:has_systemc = 1
endif

if b:has_systemc
  syntax match   scTime        /\<\d\+_\(sec\|[MKmunpfa]s\)\>/
endif

if b:has_tlm
  syntax match   scMethCall    /\<sc_dt::\w\+/       contains=scMethod
  syntax match   scMethCall    /\<sc_core::\w\+/     contains=scMethod
  syntax match   scMethCall    /->\w\+\b/            contains=scMethod,stlMethod
  syntax match   scMethCall    /\.\w\+\b/            contains=scMethod,stlMethod
  syntax match  tlmMethCall    /\<tlm_utils::\w\+\b/ contains=tlmMethod,tlmType
  syntax match  tlmMethCall    /\<tlm::\w\+\b/       contains=tlmMethod
  syntax match  tlmMethCall    /->\w\+\b/            contains=tlmMethod
  syntax match  tlmMethCall    /\.\w\+\b/            contains=tlmMethod
endif

syntax keyword cppStructure  literals
syntax keyword cppAttribute  maybe_unused noreturn
syntax keyword stlType       byte array hash valarray vector list map set multiset multimap bitset deque forward_list unordered_map unordered_set
syntax keyword stlType       ios_base openmode trunc app ate in out future queue
syntax keyword stlType       iterator const_iterator pair std tr1 string string_view byte numeric_limits
syntax keyword stlType       stringstream ostringstream istringstream ofstream ifstream ostream istream
syntax keyword stlType       initializer_list tie tuple make_tuple thread future promise chrono 
syntax keyword stlType       mutex lock_guard unique_lock scoped_lock lock condition_variable
syntax keyword stlType       atomic atomic_flag duration time_point system_clock steady_clock high_resolution_clock
syntax keyword stlType       hours minutes seconds milliseconds microseconds nanoseconds
syntax keyword cppConstant   ATOMIC_FLAG_INT ATOMIC_VAR_INT this_thread
syntax keyword stlMethod     sleep_for duration_cast time_point_cast make_shared
syntax keyword stlMethod     is_lock_free store load exchange compare_exchange_weak compare_exchange_strong
syntax keyword stlMethod     store_explict load_explict exchange_explict compare_exchange_weak_explict compare_exchange_strong_explict
syntax keyword stlMethod     fetch_add fetch_sub fetch_and fetch_or fetch_xor atomic_flag_test_and_set
syntax keyword stlMethod     fetch_add_explicit fetch_sub_explicit fetch_and_explicit fetch_or_explicit fetch_xor_explicit atomic_flag_test_and_set_explicit
syntax keyword stlMethod     atomic_init atomic_signal_fence atomic_thread_fence kill_dependency hash_code type
syntax keyword stlType       memory_order
syntax keyword stlType       array unordered_map unordered_multimap unordered_set unordered_set
syntax keyword stlType       unique_ptr shared_ptr weak_ptr runtime
syntax keyword stlType       default_random_engine linear_congruential_engine mersenne_twister_engine subtract_with_carry_engine
syntax keyword stlType       shuffle_order_engine independent_bits_engine discard_block_engine random_device
syntax keyword stlType       uniform_int_distribution uniform_real_distribution bernoulli_distribution binomial_distribution geometric_distribution
syntax keyword stdType       normal_distribution lognormal_distribution poisson_distribution exponential_distribution discrete_distribution
syntax keyword stlMethod     get bind function join async
syntax keyword stlMethod     empty size resize reserve capacity at begin end make_pair         contained containedin=scMethCall
syntax keyword stlMethod     push_back pop_back push_front pop_front front back first second   contained containedin=scMethCall
syntax keyword stlMethod     length find replace insert substr clear erase count assign        contained containedin=scMethCall
syntax keyword stlMethod     find_first_of find_last_of find_first_not_of find_last_not_of     contained containedin=scMethCall
syntax keyword stlMethod     insert erase clear lower_bound upper_bound                        contained containedin=scMethCall
syntax keyword stlMethod     str eof sqrt fabs ceil floor pow exp log log10 sinh cosh tanh
syntax keyword stlMethod     modf frexp fmod ldexp sin cos tan abs atan asin acos atan2

syntax keyword cppStatement  constexpr static_assert
syntax keyword cppStatement  default delete override final noexcept
syntax keyword cppType       int64 uint64 nullptr_t decltype
syntax keyword cppType       intptr_t uintptr_t intmax_t uintmax_t
syntax keyword cppType       int8_t int16_t int32_t int64_t
syntax keyword cppType       int_fast8_t int_fast16_t int_fast32_t int_fast64_t
syntax keyword cppType       int_least8_t int_least16_t int_least32_t int_least64_t
syntax keyword cppType       uint8_t uint16_t uint32_t uint64_t
syntax keyword cppType       uint_fast8_t uint_fast16_t uint_fast32_t uint_fast64_t
syntax keyword cppType       uint_least8_t uint_least16_t uint_least32_t uint_least64_t
syntax keyword cppType       alignas
syntax keyword stlMethod     alignof memcpy
syntax keyword cppConstant   nullptr NULL NUL CRLF
" Non-standard via #define
"Xntax keyword cppDefines    eq ne forever repeat

syntax keyword cppWarn       exit abort assert errno perror strerror
syntax keyword stdlib        rand printf sprintf snprintf fprintf getenv getenv setenv
syntax keyword stdlib        isspace isprint isalpha isalnum isdigit isblank isupper
syntax keyword stdlib        islower ispunct iscntrl
syntax keyword stdlib        mmap msync mkfifo exec system vfork fork getpid getppid

syntax keyword cppDiscourage printf malloc free strcpy strlen strncpy strcat strncat strcmp strncmp
syntax keyword cppio         cin cerr cout
syntax keyword cppio         setw setf setfill boolalpha flush endl ends contained containedin=iomanip
syntax keyword cppio         uppercase showbase noshowbase hex setprecision fixed scientific floatfield dec oct flush contained containedin=iomanip
syntax keyword cppio         noskipws skipws ws getline contained containedin=iomanip
syntax match   cppMethod     /\<\(unget\|putback\|get\)\>/
syntax keyword cppMethod     ncsc_elab_exception

syntax keyword cppDeprecate  auto_ptr

syntax match   wxWidgets     /\<wx\w\+/
syntax keyword wxMacro       IMPLEMENT_APP DECLARE_EVENT_TABLE BEGIN_EVENT_TABLE END_EVENT_TABLE EVT_MENU EVT_BUTTON

syntax match   stdlib        /\<std::/
syntax match   stdlib        /\<std::/ contained containedin=iomanip
syntax keyword stdlib        isspace isblank
syntax keyword stdlib        isdigit isalpha isalnum
syntax keyword stdlib        iscntrl isgraph ispunct
syntax keyword stdlib        islower isupper tolower toupper isprint
syntax keyword stdlib        strtol strtoul strtod atol atod
syntax keyword stdlib        signal kill pause sleep
syntax keyword stdlib        clock open close write read
syntax keyword stdlib        realpath stat mkdir mkdtemp fopen fclose umask
syntax keyword stdlib        popen pclose feof fgets append
syntax keyword stdlib        pthread_mutex_t pthread_mutex_init pthread_mutex_lock pthread_mutex_unlock

syntax match   iomanip       /<< *\w\+\>/ contains=cppio,scStatement,std,eaStreams,stdlib

if b:has_boost
  syntax match   boostMethod   /boost::\w\+/
  syntax keyword boostEnum     boost regex_constants match_default
  syntax keyword boostType     regex match_results match_flag_type regex_error
  syntax keyword boostMethod   regex_match regex_search smatch
  syntax keyword boostMethod   format
endif

if b:has_systemc
  syntax keyword scMethod      sc_is_running sc_start_of_simulation_invoked sc_end_of_simulation_invoked
  syntax keyword scMethod      sc_argc sc_argv sc_copyright sc_version sc_release sc_delta_count
  syntax keyword scMethod      reset_signal_is async_reset_signal_is sync_reset_on sync_reset_off
  syntax keyword scStructure   W_BEGIN W_DO W_ESCAPE W_END bind
  syntax keyword scStructure   SC_MODULE SC_CTOR SC_HAS_PROCESS
  syntax keyword scStructure   SC_SLAVE SC_MASTER SC_PROTOCOL
  syntax keyword scStructure   SC_FORK SC_JOIN SC_METHOD SC_THREAD SC_CTHREAD
  syntax keyword scStructure   before_end_of_elaboration end_of_elaboration start_of_simulation end_of_simulation

  syntax keyword scConstant    SC_ZERO_TIME sc_max_time Log_0 Log_1 Log_X Log_Z
  syntax keyword scConstant    SC_ONE_OR_MORE_BOUND SC_ZERO_OR_MORE_BOUND SC_ALL_BOUND SC_MANY_WRITERS
  syntax keyword scConstant    SC_MAX_NBITS
  syntax keyword scConstant    SC_INCLUDE_DYNAMIC_PROCESSES
  syntax keyword scConstant    SC_LOGIC_0 SC_LOGIC_1 SC_LOGIC_X SC_LOGIC_Z
  syntax keyword scConstant    SC_SEC SC_MS SC_US SC_NS SC_PS SC_FS
  syntax keyword scConstant    SC_NOBASE SC_DEC SC_BIN SC_OCT SC_HEX SC_CSD
  syntax keyword scConstant    SC_DEC_US SC_BIN_US SC_OCT_US SC_HEX_US
  syntax keyword scConstant    SC_DEC_SM SC_BIN_SM SC_OCT_SM SC_HEX_SM
  syntax keyword scConstant    SC_RND SC_RND_ZERO SC_RND_MIN_INF SC_RND_INF
  syntax keyword scConstant    SC_RND_CONV SC_TRN SC_TRN_ZERO SC_SAT
  syntax keyword scConstant    SC_RND SC_SAT_ZERO SC_SAT_SYM SC_WRAP SC_WRAP_SM
  syntax keyword scConstant    SC_NONE SC_LOW SC_MEDIUM SC_HIGH SC_FULL SC_DEBUG

  syntax keyword scConstant    SC_UNSPECIFIED SC_DO_NOTHING SC_THROW LOG
  syntax keyword scConstant    SC_DISPLAY SC_CACHE_REPORT SC_INTERRUPT
  syntax keyword scConstant    SC_STOP SC_ABORT SC_LOG
  syntax keyword scConstant    SC_DEFAULT_INFO_ACTIONS SC_DEFAULT_WARNING_ACTIONS SC_DEFAULT_ERROR_ACTIONS SC_DEFAULT_FATAL_ACTIONS
  syntax keyword scConstant    SC_DEFAULT_STACK_SIZE SC_MAX_NUM_DELTA_CYCLES SC_NO_DESCENDANTS
  syntax keyword scConstant    SC_INFO SC_WARNING SC_ERROR SC_FATAL
  syntax keyword scConstant    SC_STOP_IMMEDIATE SC_STOP_FINISH_DELTA
  syntax keyword scReports     SC_REPORT_INFO SC_REPORT_INFO_VERB SC_REPORT_WARNING
  syntax keyword scReports     SC_REPORT_ERROR SC_REPORT_FATAL sc_assert
  syntax keyword scReports     sc_report
  syntax keyword scReports     sc_exception sc_unwind_exception
endif
if b:has_my
  syntax keyword myReports     REPORT INFO WARNING ERROR FATAL TODO DEBUG
  syntax keyword myReports     MESSAGE MEND
  syntax match   myReports     /\<REPORT((\(INFO\|WARNING\|ERROR\|FATAL\)>/
  syntax match   myReports     /\<INFO((\(ALWAYS\|LOW\|MEDIUM\|HIGH\|DEBUG\)>/
  syntax keyword myReports     REPORT_VERB REPORT_INFO REPORT_INFO_VERB REPORT_DEBUG REPORT_LOGONLY
endif

if b:has_tlm
  syntax keyword tlmEnum       tlm_sync_enum tlm_command tlm_response_status
  syntax keyword tlmConstant   TLM_OK_RESPONSE TLM_INCOMPLETE_RESPONSE TLM_GENERIC_ERROR_RESPONSE TLM_ADDRESS_ERROR_RESPONSE TLM_COMMAND_ERROR_RESPONSE TLM_BURST_ERROR_RESPONSE TLM_BYTE_ENABLE_ERROR_RESPONSE
  syntax keyword tlmConstant   TLM_ACCEPTED TLM_UPDATED TLM_COMPLETED TLM_BYTE_ENABLED TLM_BYTE_DISABLED
  syntax keyword tlmConstant   TLM_READ_COMMAND TLM_WRITE_COMMAND TLM_IGNORE_COMMAND
  syntax keyword tlmConstant   TLM_MIN_PAYLOAD TLM_FULL_PAYLOAD TLM_FULL_PAYLOAD_ACCEPTED
  syntax keyword tlmConstant   BEGIN_REQ END_REQ BEGIN_RESP END_RESP
  syntax keyword tlmType       tlm tlm_utils
  syntax keyword tlmType       tlm_phase tlm_generic_payload tlm_gp_option tlm_initiator_socket tlm_target_socket tlm_dmi
  syntax keyword tlmType       simple_initiator_socket simple_target_socket multi_passthrough_initiator_socket multi_passthrough_target_socket
  syntax keyword tlmType       tlm_event_finder_t tlm_global_quantum tlm_global_quantum_keeper  tlm_quantumkeeper tlm_analysis_port
  syntax keyword tlmInterface  tlm_fw_nonblocking_transport_if tlm_blocking_transport_if tlm_fw_direct_mem_if tlm_transport_dbg_if
  syntax keyword tlmInterface  tlm_write_if tlm_delayed_write_if tlm_analysis_if tlm_delayed_analysis_if
  syntax keyword tlmInterface  tlm_bw_transport_if tlm_fw_transport_if
  syntax keyword tlmMethod     b_transport nb_transport_fw nb_transport_bw invalidate_direct_mem_ptr
  syntax keyword tlmMethod     invalidate_direct_mem_ptr get_direct_mem_ptr transport_dbg
  syntax keyword tlmMethod     register_b_transport register_nb_transport_fw register_nb_transport_bw
  syntax keyword tlmMethod     register_invalidate_direct_mem_ptr register_get_direct_mem_ptr
  syntax keyword tlmMethod     register_transport_dbg
  syntax keyword tlmMethod     acquire release get_ref_count set_mm has_mm reset
  syntax keyword tlmMethod     deep_copy_from update_original_from update_extensions_from free_all_extensions
  syntax keyword tlmMethod     is_read set_read is_write set_write
  syntax keyword tlmMethod     get_bus_width
  syntax keyword tlmMethod     get_command set_command get_address set_address
  syntax keyword tlmMethod     get_data_ptr set_data_ptr get_data_length set_data_length
  syntax keyword tlmMethod     is_response_ok is_response_error get_response_status
  syntax keyword tlmMethod     set_response_status get_response_string
  syntax keyword tlmMethod     get_streaming_width set_streaming_width
  syntax keyword tlmMethod     get_byte_enable_ptr set_byte_enable_ptr
  syntax keyword tlmMethod     get_byte_enable_length set_byte_enable_length
  syntax keyword tlmMethod     set_dmi_allowed is_dmi_allowed
  syntax keyword tlmMethod     set_extension set_auto_extension get_extension
  syntax keyword tlmMethod     clear_extension release_extension resize_extensions
  syntax keyword tlmMethod     reset set_global_quantum get_global_quantum compute_local_quantum
  syntax keyword tlmMethod     get_local_time set inc get_current_time need_sync sync set_and_sync
  syntax keyword tlmMethod     get_gp_option set_gp_option
  syntax keyword tlmType       peq_with_get peq_with_cb_and_phase
endif

if b:has_systemc
  syntax match   scReports     /sc_report_handler::\w\+/
  syntax keyword scRptCfg      release intialize report contained=scRptCfg
  syntax keyword scRptCfg      stop_after set_actions contained
  syntax keyword scRptCfg      get_cached_report clear_cached_report contained
  syntax keyword scRptCfg      set_log_file_name get_log_file_name
  syntax keyword scRptCfg      set_verbosity_level get_verbosity_level
  syntax match   scDirective   /\<CYN_\w\+/
  syntax keyword scType        sc_object ncsc_foreign_module sc_foreign_module sc_core sc_dt SC_MODULE_EXPORT
  syntax keyword scType        sc_module sc_channel sc_prim_channel sc_attribute
  syntax keyword scType        sc_behavior sc_interface sc_numrep sc_string
  syntax keyword scType        sc_port sc_port_base sc_export_base sc_export sc_signal sc_buffer sc_vector
  syntax keyword scType        sc_signal_resolved sc_signal_rv sc_logic_resolve sc_lv_resolve sc_event_finder
  syntax keyword scType        sc_event_finder_t sc_signal_inout_if
  syntax keyword scType        sc_inout_rv sc_out_rv sc_in_rv
  syntax keyword scType        sc_inoutslave sc_outslave sc_inslave sc_slave
  syntax keyword scType        sc_inoutmaster sc_outmaster
  syntax keyword scType        sc_inmaster sc_master
  syntax keyword scType        sc_signal_in_if sc_signal_out_if sc_event
  syntax keyword scType        sc_event_and_list sc_event_or_list
  syntax keyword scType        sc_time sc_time_unit sc_mutex_if sc_semaphore_if
  syntax keyword scType        sc_event_queue sc_in sc_out sc_inout sc_in_clk
  syntax keyword scType        sc_out_clk sc_inout_clk sc_in_resolved
  syntax keyword scType        sc_out_resolved sc_inout_resolved sc_clock
  syntax keyword scType        sc_mutex sc_semaphore sc_fifo sc_fifo_in_if
  syntax keyword scType        sc_fifo_out_if sc_fifo_in sc_fifo_out
  syntax keyword scvType       scv_random scv_smart_ptr scv_shared_ptr scv_bag scv_sparse_array
  syntax keyword scvType       scv_constraint_base SCV_CONSTRAINT SCV_BASE_CONSTRAINT SCV_SOFT_CONSTRAINT
  syntax keyword scvType       SCV_CONSTRAINT_CTOR SCV_EXTENSIONS SCV_EXTENSIONS_CTOR SCV_FIELD
  syntax keyword scvType       scv_tr_db scv_tr_stream scv_tr_handle
  syntax keyword scvMethod     callback_reason set_recording get_recording begin_transaction end_transaction
  syntax keyword scvMethod     scv_get_extensions has_valid_extensions
  syntax keyword scvMethod     set_name get_type get_name show
  syntax keyword scvMethod     set_mode set_random get_random
  syntax keyword scvMethod     next disable_randomization enable_randomization is_randomization_enabled
  syntax keyword scvMethod     use_contraint reset_distribution
  syntax keyword scvMethod     distinct_size add remove
  syntax keyword scStatement   sc_start_of_simulation_invoked
  syntax keyword scStatement   update request_update  async_request_update
  syntax keyword scStatement   sc_get_current_process_handle timed_out halt
  syntax keyword scRptCfg      get_msg_type get_severity get_process_name get_msg get_time get_file_name get_verbosity
  syntax keyword scMethod      hdl_name to_string name get_interface basename
  syntax keyword scMethod      set_stack_size spawn_method period    contained
  syntax keyword scMethod      set_sensitivity dont_initialize       contained
  syntax keyword scMethod      end_of_elaboration notify duty_cycle  contained
  syntax keyword scMethod      notify_delayed c_str cancel           contained
  syntax keyword scMethod      num_available data_written            contained
  syntax keyword scMethod      data_written_event num_free data_read contained
  syntax keyword scMethod      data_read_event next read write       contained
  syntax keyword scMethod      nb_read nb_write lock unlock          contained
  syntax keyword scMethod      trylock wait wait_until trywait       contained
  syntax keyword scMethod      post event delayed kind get_value     contained
  syntax keyword scMethod      get_new_value get_old_value posedge   contained
  syntax keyword scMethod      negedge posedge_event negedge_event   contained
  syntax keyword scMethod      pos neg default_event cancel_all      contained
  syntax keyword scMethod      value_change_event initialize         contained
  syntax keyword scMethod      end_of_elaboration value_changed      contained
  syntax keyword scMethod      value_changed_event range concat      contained
  syntax keyword scMethod      and_reduce or_reduce nand_reduce      contained
  syntax keyword scMethod      nor_reduce xor_reduce xnor_reduce     contained
  syntax keyword scMethod      to_uint to_int to_long to_uint64      contained
  syntax keyword scMethod      to_int64 to_double to_long length     contained
  syntax keyword scMethod      to_test set to_seconds value          contained
  syntax keyword scStatement   set_global_seed pick_random_seed sc_gen_unique_name
  syntax keyword scStatement   sc_set_time_resolution
  syntax keyword scStatement   sc_get_time_resolution sensitive next_trigger
  syntax keyword scStatement   dont_initialize wait watching period duty_cycle
  syntax keyword scStatement   sc_spawn sc_spawn_options sc_bind sc_ref sc_cref
  syntax keyword scStatement   sc_create_vcd_trace_file sc_trace sc_close_vcd_trace_file
  syntax keyword scStatement   sc_set_vcd_time_unit sc_set_stop_mode sc_time_stamp
  syntax keyword scSpecial     sc_main sc_start sc_stop sc_pause sc_kill sc_halt
  syntax keyword scSpecial     sc_stop_here sc_interrupt_here 
  syntax keyword scSpecial     suspend resume disable enable reset kill terminated
  syntax keyword scSpecial     get_parent_object get_process_object get_child_objects
  syntax keyword scSpecial     valid unwinding dynamic reset_event terminated_event throwit
  syntax keyword scStatement   DEBUG_wait
  syntax keyword scType        sc_severity sc_actions
  syntax keyword scType        sc_int sc_uint sc_bigint sc_biguint sc_logic sc_lv
  syntax keyword scType        sc_fixed sc_ufixed sc_fixed_fast sc_ufixed_fast
  syntax keyword scType        sc_fix   sc_ufix   sc_fix_fast   sc_ufix_fast
  syntax keyword scType        sc_module_name sc_process_handle
  syntax keyword scDeprecate   sc_bit sc_bv delayed sensitive_pos sensitive_neg
  syntax keyword scDeprecate   sc_logic_0 sc_logic_1 sc_logic_X sc_logic_Z
  syntax keyword scDeprecate   sc_get_curr_process_handle sc_simulation_time
  syntax keyword scDeprecate   sc_simcontext sc_get_curr_simcontext is_running
  syntax keyword scDeprecate   sc_set_default_time_unit sc_get_default_time_unit
  syntax keyword scType        sc_trace_file vcd_trace_file
endif

if b:has_greensocs
  syntax match   greensocs     /\<debug_level_\d\+_stream\>/
  syntax keyword greensocs     gs
  syntax keyword greensocs     GS_END_MSG containedin=iomanip
  syntax match   greensocs     /\<gs_\w\+\>/
endif

syntax match   Red           /.*[\*]\{3\} YOUR .\+[\*]\{3\}.*/ containedin=Comment
syntax match   disabled      /\/\/!.*/

"syntax match   Error        /[a-zA-Z_0-9]\+<[a-zA-Z_0-9]\+<[a-zA-Z_0-9, ]\+>>/

" Define some colors
"   Red LightRed DarkRed Green LightGreen DarkGreen SeaGreen Blue
"   LightBlue DarkBlue SlateBlue Cyan LightCyan DarkCyan Magenta
"   LightMagenta DarkMagenta Yellow LightYellow Brown DarkYellow Gray
"   LightGray DarkGray Black White Orange Purple Violet
highlight dkred   ctermfg=DarkRed   ctermbg=none      guifg=DarkRed               gui=bold
highlight dkgreen ctermfg=DarkGreen                   guifg=DarkGreen             gui=bold
highlight Green   ctermfg=DarkGreen ctermbg=none      guifg=Green                 gui=bold
highlight Blue    ctermfg=Blue      ctermbg=none      guifg=Blue                  gui=bold
highlight brown   ctermfg=DarkRed   ctermbg=none      guifg=#8b0000               gui=italic,bold term=underline,bold
highlight sky     ctermfg=DarkBlue  ctermbg=none      guifg=#00bfff               gui=bold        term=bold
highlight gold    ctermfg=Yellow     ctermbg=none      guifg=#d09000 guibg=Black   gui=bold        term=bold
highlight grey    ctermfg=Gray      ctermbg=none      guifg=#808080               gui=bold        term=bold
highlight Red     ctermfg=Red       ctermbg=none      guifg=Red                   gui=bold
highlight boost   ctermfg=Blue      ctermbg=none      guifg=Blue                  gui=bold
highlight purple  ctermfg=Magenta   ctermbg=none      guifg=Magenta               gui=bold

" Search for next template /*{ABC}*/
nmap gn /\/[*]{[^}]\+}[*]\/<CR>f/,

" Default highlighting
if version >= 508 || !exists("did_sc_syntax_inits")
  if version < 508
    let did_sc_syntax_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif
" Colors: Black White Red Green Blue Yellow Magenta Cyan Orange Gray
" Dark:   Darkred Darkgreen Darkblue Darkmagenta Darkcynan Darkyellow
  if &background == "dark"
    highlight Emphasize term=bold,underline cterm=NONE ctermfg=LightBlue ctermbg=NONE     gui=bold guifg=#2e8b57
    highlight Warn      term=bold,underline cterm=NONE ctermfg=LightRed  ctermbg=NONE     gui=bold guifg=#2e8b57
    highlight Directive	term=bold           cterm=NONE ctermfg=Magenta   ctermbg=NONE     gui=bold guifg=#ffa0a0
    highlight Template  term=bold                      ctermfg=White     ctermbg=DarkBlue gui=bold guifg=Cyan    guibg=DarkRed
  else
    highlight Emphasize term=bold,underline cterm=NONE ctermfg=LightBlue ctermbg=NONE     gui=bold guifg=#2e8b57
    highlight Warn      term=bold,underline cterm=NONE ctermfg=LightRed  ctermbg=NONE     gui=bold guifg=#2e8b57
    highlight Directive	term=bold           cterm=NONE ctermfg=DarkRed   ctermbg=NONE     gui=bold guifg=Magenta
    highlight Template  term=bold                      ctermfg=Black     ctermbg=Yellow   gui=bold guifg=Red     guibg=Cyan
  endif

: HiLink template               Template
: HiLink cppio                  grey
: HiLink stlType                cppType
: HiLink stlMethod              brown
: HiLink stdlib                 grey
: HiLink disabled               Red

: HiLink boostEnum              boost
: HiLink boostType              boost
: HiLink boostMethod            boost
: HiLink cppConstant            Constant
: HiLink cppAttribute           Constant
: HiLink cppDeprecate           dkred
: HiLink scDeprecate            dkred
: HiLink cppDiscourage          dkred
: HiLink cppWarn                Red
""XiLink cppDefines             Statement
""XiLink scFeature              sky
"XHiLink eaFeature              purple
: HiLink scStatement            sky
: HiLink scExceptions           scStatement
: HiLink scSpecial              Red
: HiLink scReports              Orange
: HiLink myReports              Red
: HiLink eaStreams              Red
: HiLink cppMethod              sky
: HiLink wxWidgets              sky
: HiLink wxMacro                grey
: HiLink scRptCfg               Red
: HiLink scOperator             scStatement
: HiLink scMethod               sky
: HiLink scMethCall             sky
: HiLink scTime                 cNumbers
: HiLink scType                 gold
: HiLink scStructure            gold
: HiLink scConstant             Constant
: HiLink scDirective            Directive
: HiLink scBoolean              Boolean
: HiLink greensocs              dkgreen
: HiLink scvType                gold
: HiLink scvMethod              sky
: HiLink tlmEnum                grey
: HiLink tlmConstant            Constant
: HiLink tlmType                gold
: HiLink tlmInterface           gold
: HiLink tlmMethod              sky
" HiLink tlmMethCall            sky
: delcommand HiLink
endif

"let b:error
"setlocal makeprg=scc\ compile
"setlocal errorformat="%f:%l: %m"
"setlocal errorfile="build/log.dir/error.log"
"setlocal nospell
"setlocal dict=$HOME/.vim/etc/systemc.dict

" $Id: cpp.vim,v 1.12 2007/07/31 14:23:12 dcblack Exp $
"-let b:current_syntax = "sc"
