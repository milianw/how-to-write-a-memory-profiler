// SPDX-License-Identifier: LGPL-2.1-or-later

#include <vector>
#include <algorithm>

int main()
{
    std::vector<int> v;
    std::generate_n(std::back_inserter(v), 1000, [i = 0] () mutable { return i++; });
    return v.size() > 0;
}
