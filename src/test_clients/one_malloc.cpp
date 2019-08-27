// SPDX-License-Identifier: LGPL-2.1-or-later

//--> slide
#include <cstdlib>

int main()
{
//--> slide
    auto *buffer = malloc(100);
//<-- slide
    free(buffer);
    return buffer ? 0 : 1;
}
//<-- slide
