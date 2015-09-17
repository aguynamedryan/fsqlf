#ifndef CLI_H
#define CLI_H


#include <stdio.h> // fprintf, FILE
#include "kw/kw.h"


void set_input(FILE *in);
void set_output(FILE *out);
void set_input_path(char *path);
void set_output_path(char *path);
void read_config_file(char *path);
void select_comma_newline(char *arg);
void keyword_case(char *arg);
void keyword_text(char *arg);
void select_newline_after(int lines);
void newline_or_before(int lines);
void newline_or_after(int lines);
void newline_and_before(int lines);
void newline_and_after(int lines);
void newline_major_sections(int lines);
void debugit(char *arg);
void init();
void run(FILE *in, FILE *out);

void read_cli_options(int argc, char **argv,
    struct kw_conf * (*kw)(const char *), FILE ** fin, FILE ** fout);


#endif
