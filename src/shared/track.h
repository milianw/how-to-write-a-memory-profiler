// SPDX-License-Identifier: LGPL-2.1-or-later

#pragma once

#include <cstdlib>

namespace track {
void init();
void malloc(void *ptr, size_t size);
void free(void *ptr);
void invalidate_module_cache();
}
