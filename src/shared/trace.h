// SPDX-License-Identifier: LGPL-2.1-or-later

#ifndef TRACE_H
#define TRACE_H

#include <cstring>
#include <cstdio>

#include <array>

#define UNW_LOCAL_ONLY
#include <libunwind.h>

/**
 * @brief A libunwind based backtrace.
 */
struct Trace
{
    enum : int
    {
        MAX_SIZE = 64
    };

    auto begin() const
    {
        return std::next(m_data.begin(), m_skip);
    }

    auto end() const
    {
        return std::next(begin() + m_size - 1);
    }

    auto operator[](int i) const
    {
        return m_data[m_skip + i];
    }

    int size() const
    {
        return m_size;
    }

    bool fill(int skip)
    {
        int size = unw_backtrace(m_data.data(), MAX_SIZE);
        // filter bogus frames at the end, which sometimes get returned by libunwind
        // cf.: https://bugs.kde.org/show_bug.cgi?id=379082
        while (size > 0 && !m_data[size - 1]) {
            --size;
        }
        m_size = size > skip ? size - skip : 0;
        m_skip = skip;
        return m_size > 0;
    }

    static void dump(FILE *out, int skip = 2)
    {
        Trace trace;
        if (!trace.fill(skip))
            return;

        for (auto ip : trace)
            fprintf(out, "\tip: %p\n", ip);
    }

private:
    int m_size = 0;
    int m_skip = 0;
    std::array<void*, MAX_SIZE> m_data;
};

#endif // TRACE_H
