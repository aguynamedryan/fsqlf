#include "cli.h"    // read_cli_options
#include "formatter/lex.yy.h" // yyin, yyout


int main(int argc, char **argv)
{
    init();
    read_cli_options(argc, argv, &kw, &yyin, &yyout);  // Read configs from command line.

    run();

    return 0;
}
