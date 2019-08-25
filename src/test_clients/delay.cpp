// SPDX-License-Identifier: LGPL-2.1-or-later

#include <iostream>
#include <vector>
#include <algorithm>

int main()
{
    std::cout << "enter vector size: " << std::flush;
    std::size_t size = 0;
    std::cin >> size;

    std::vector<double> vector;

    std::generate_n(std::back_inserter(vector), size, [i = 0] () mutable { return i++; });
    return vector.size() > 0;
}
