#ifndef CLI_H
#define CLI_H


#include <stdio.h> // fprintf, FILE
#include "kw/kw.h"


void init();
void run();

void read_cli_options(int argc, char **argv,
    struct kw_conf * (*kw)(const char *), FILE ** fin, FILE ** fout);


#endif
