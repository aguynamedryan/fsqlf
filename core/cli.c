#include <ctype.h> // isdigit
#include <stdlib.h> // exit
#include "cli.h"
#include "conf_file/conf_file_read.h"
#include "conf_file/conf_file_create.h"
#include "conf_file/conf_file_constants.h"
#include "kw/kwall_init.h"  // set_case, set_text_original
#include "kw/kw.h"  // init_all_settings
#include "formatter/lex.yy.h"
#include "debuging.h"
#include "../utils/string/read_int.h"   // read_int




#define FAIL_WITH_ERROR( CODE , MESSAGE , ... )         \
do {                                                    \
    fprintf(stderr, "\n" MESSAGE "\n", __VA_ARGS__ );   \
    exit( CODE );                                       \
} while (0)


#define PRINT_OPTION_INFO( OPTION_TEXT , OPTION_DESCRIPTION ) \
    fprintf(stderr, "    " OPTION_TEXT "\n        " OPTION_DESCRIPTION "\n")


#define ARGV_MATCH(INDEX, TEXT) (strcmp(argv[INDEX], TEXT) == 0)


static void usage_info(int argc, char **argv)
{
    fprintf(stderr, "usage:\n" );
    PRINT_OPTION_INFO( "fsqlf [<input_file>] [<output_file>] [options]",
        "Read from <input_file> and write formatted output to <output_file> (use std I/O if missing)\n"
        "        If there are overlaping options set, then the last one (overlapping setting) wins.\n"
        "        e.g. If config file is set 2 times, then from 1st file use only configs that don't exist in the 2nd file.");
    PRINT_OPTION_INFO( "fsqlf --create-config-file", "(Re)create '" FSQLF_CONFFILE_NAME "' config file.");
    fprintf(stderr, "options:\n");
    PRINT_OPTION_INFO( "-i <input_file>" , "Use <input_file> as input");
    PRINT_OPTION_INFO( "-o <output_file>" , "Use  <output_file> as output");
    PRINT_OPTION_INFO( "--config-file <config_file>"                , "Read configuration from <config_file>");
    PRINT_OPTION_INFO( "--select-comma-newline (after|before|none)" , "New lines for each item in SELECT clause");
    PRINT_OPTION_INFO( "--select-newline-after <digit>"             , "Put <digit> new lines right after SELECT keyword");
    PRINT_OPTION_INFO( "--newline-or-before <digit>"                , "Put <digit> new lines before OR keyword");
    PRINT_OPTION_INFO( "--newline-or-after <digit>"                 , "Put <digit> new lines before OR keyword");
    PRINT_OPTION_INFO( "--newline-and-before <digit>"               , "Put <digit> new lines before AND keyword");
    PRINT_OPTION_INFO( "--newline-and-after <digit>"                , "Put <digit> new lines before AND keyword");
    PRINT_OPTION_INFO( "--newline-major-sections <digit>"           , "Put <digit> new lines before major sections (FROM, JOIN, WHERE)");
    PRINT_OPTION_INFO( "--keyword-case (upper|lower|initcap|none)"  , "Convert all keywords to UPPER, lower, or Initcap case, or not to convert case at all");
    PRINT_OPTION_INFO( "--keyword-text (original|default)"          , "Use original or programs default text for the keyword, when there are several alternatives");
    PRINT_OPTION_INFO( "--debug (none|state|match|parenthesis)"     , "Print info for debuging.  To have different kinds of debug output, use more than once");
    PRINT_OPTION_INFO( "--help, -h"                                 , "Show this help.");
}


// Get argument and convert it to integer
static int get_int_arg(int i, int argc, char **argv)
{
    int r;
    if (!read_int(argv[i], 1000, &r)) {
        FAIL_WITH_ERROR(1, "Missing or invalid value for option : %s", argv[i-1]);
    }
    return r;
}


void set_input(FILE *in) {
    yyin = in;
}


void set_output(FILE *out) {
    yyout = out;
}


void set_input_path(char *path) {
    FILE  *file = fopen(path, "r");
    if (!(file)) {
        FAIL_WITH_ERROR(1, "Error opening input file: %s", path);
    }
    set_input(file);
}


void set_output_path(char *path) {
    FILE  *file = fopen(path, "w");
    if (!(file)) {
        FAIL_WITH_ERROR(1, "Error opening output file: %s", path);
    }
    set_output(file);
}


void read_config_file(char *path) {
    if (read_conf_file(path, kw) == READ_FAILED) {
        FAIL_WITH_ERROR(1, "Error reading configuration file: %s", path);
    }
}


void select_comma_newline(char *arg) {
    if (strcmp(arg, "after") == 0) {
        kw("kw_comma")->before.new_line = 0;
        kw("kw_comma")->after.new_line  = 1;
    } else if (strcmp(arg, "before") == 0) {
        kw("kw_comma")->before.new_line = 1;
        kw("kw_comma")->after.new_line  = 0;
    } else if (strcmp(arg, "none") == 0) {
        kw("kw_comma")->before.new_line = 0;
        kw("kw_comma")->after.new_line  = 0;
    }
}


void keyword_case(char *arg) {
    if (strcmp(arg, "none") == 0) {
        set_case(CASE_none);
    } else if (strcmp(arg, "upper") == 0) {
        set_case(CASE_UPPER);
    } else if (strcmp(arg, "lower") == 0) {
        set_case(CASE_lower);
    } else if (strcmp(arg, "initcap") == 0) {
        set_case(CASE_Initcap);
    }
}


void keyword_text(char *arg) {
    if (strcmp(arg, "original") == 0) {
        set_text_original(1);
    } else if (strcmp(arg, "default") == 0) {
        set_text_original(0);
    }
}


void select_newline_after(int lines) {
    kw("kw_select")->after.new_line = lines;
}


void newline_or_before(int lines) {
    kw("kw_or")->before.new_line = lines;
}


void newline_or_after(int lines) {
    kw("kw_or")->after.new_line = lines;
}


void newline_and_before(int lines) {
    kw("kw_and")->before.new_line = lines;
}


void newline_and_after(int lines) {
    kw("kw_and")->after.new_line = lines;
}


void newline_major_sections(int lines) {
    kw("kw_from")->before.new_line = lines;
    kw("kw_where")->before.new_line = lines;
    kw("kw_inner_join")->before.new_line = lines;
    kw("kw_left_join")->before.new_line  = lines;
    kw("kw_right_join")->before.new_line = lines;
    kw("kw_full_join")->before.new_line  = lines;
    kw("kw_cross_join")->before.new_line = lines;
}


void debugit(char *arg) {
    if (strcmp(arg, "none") == 0) debug_level |= DEBUGNONE;
    else if (strcmp(arg, "state") == 0) debug_level |= DEBUGSTATES;
    else if (strcmp(arg, "match") == 0) debug_level |= DEBUGMATCHES;
    else if (strcmp(arg, "parenthesis") == 0) debug_level |= DEBUGPARCOUNTS;
    else FAIL_WITH_ERROR(1, "Missing or invalid value for option : %s", "debug");
}


void init() {
    // Initialise with STD I/O (later can be changed by command line options).
    set_input(stdin);
    set_output(stdout);

    init_all_settings(&kw);             // Init default configs.
    read_default_conf_file(&kw);        // Read configs from file.
}


void run(FILE *in, FILE *out) {
    set_input(in);
    set_output(out);

    while (yylex() != 0) ;
}


void read_cli_options(int argc, char **argv,
                        struct kw_conf * (*kw)(const char *), FILE ** fin, FILE ** fout)
{
    int i;
    if (argc == 1) return; // use stdin and stdout

    if (argc == 2 && strcmp(argv[1], "--create-config-file") == 0) {
        if (create_conf_file(FSQLF_CONFFILE_NAME) != 0) {
            exit(1);
        } else {
            fprintf(stderr, "File '%s' (re)created.\n", FSQLF_CONFFILE_NAME);
            exit(0);
        }
    }

    i = 1;

    if (i < argc && argv[i][0] != '-') {
        set_input_path(argv[i]);
        i++;
    }

    if (i < argc && argv[i][0] != '-') {
        set_output_path(argv[i]);
        i++;
    }

    for (; i < argc; i++) {
        if (ARGV_MATCH(i, "-i")) {
            if (++i >= argc) FAIL_WITH_ERROR(1, "Missing value for option : %s", argv[i-1]);
            set_input_path(argv[i]);
        } else if (ARGV_MATCH(i, "-o")) {
            if (++i >= argc) FAIL_WITH_ERROR(1, "Missing value for option : %s", argv[i-1]);
            set_output_path(argv[i]);
        } else if (ARGV_MATCH(i, "--config-file")) {
            if (++i >= argc) FAIL_WITH_ERROR(1, "Missing value for option : %s", argv[i-1]);
            read_config_file(argv[i]);
        } else if (ARGV_MATCH(i, "--select-comma-newline")) {
            if (++i >= argc) FAIL_WITH_ERROR(1, "Missing value for option : %s", argv[i-1]);
            select_comma_newline(argv[i]);
        } else if (ARGV_MATCH(i, "--keyword-case")) {
            if (++i >= argc) FAIL_WITH_ERROR(1, "Missing value for option : %s", argv[i-1]);
            keyword_case(argv[i]);
        } else if (ARGV_MATCH(i, "--keyword-text")) {
            if (++i >= argc) FAIL_WITH_ERROR(1, "Missing value for option : %s", argv[i-1]);
            keyword_text(argv[i]);
        } else if (ARGV_MATCH(i, "--select-newline-after")) {
            select_newline_after(get_int_arg(++i, argc, argv));
        } else if (ARGV_MATCH(i, "--newline-or-before")) {
            newline_or_before(get_int_arg(++i, argc, argv));
        } else if (ARGV_MATCH(i, "--newline-or-after")) {
            newline_or_after(get_int_arg(++i, argc, argv));
        } else if (ARGV_MATCH(i, "--newline-and-before")) {
            newline_and_before(get_int_arg(++i, argc, argv));
        } else if (ARGV_MATCH(i, "--newline-and-after")) {
            newline_and_after(get_int_arg(++i, argc, argv));
        } else if (ARGV_MATCH(i, "--newline-major-sections")) {
            newline_major_sections(get_int_arg(++i, argc, argv));
        } else if (ARGV_MATCH(i, "--debug")) {
            if (++i >= argc ) FAIL_WITH_ERROR(1, "Missing or invalid value for option : %s", argv[i-1]);
            debugit(argv[i]);
        } else if (strcmp(argv[i], "--help") == 0 || strcmp(argv[i], "-h") == 0) {
            usage_info(argc, argv);
            exit(0);
        } else FAIL_WITH_ERROR(1, "Option `%s' is not recognised or used incorrectly.\nTry `%s --help' for more information\n", argv[i], argv[0]);
    }
}
