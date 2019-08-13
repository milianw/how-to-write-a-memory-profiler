// SPDX-License-Identifier: LGPL-2.1-or-later

#include <cstdio>

extern "C" {
void attach_init(const char *pipe)
{
    // output a string to stderr of the attached process
    fprintf(stderr, "attached to process :)\n");
    // output a string to the pipe
    if (auto fd = fopen(pipe, "w")) {
        fprintf(fd, "yay, we attached and can communicate back!\n");
        fclose(fd);
    }
}
}
