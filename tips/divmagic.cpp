#include <utility>

#define i32 int
#define u32 unsigned int
#define u64 unsigned long long
#define i128 __int128_t

using namespace std;

pair<i32, u32> __get_magic_u32(u32 d) {
    for (int i = 32; ; i++) {
        u64 k = 1ULL << i, m = d - k % d;
        if (m * 4294967295 < k) {
            u64 r = (k + m) / d;

            return { (i32)r, r <= 4294967295 ? i - 32 : -1 };
        }
    }
}

pair<i32, u32> __get_magic_u32_complex(u32 d) {
    pair<u32, u32> p = { 0, 0 };

    for (int i = 0; i < 32; i++) {
        __int128_t tmp = 1;
        tmp = (tmp << (33 + i)) / d - (1LL << 32) + 1;

        if (tmp < (1LL << 32)) p = { (i32)tmp, i };
        else break;
    }

    return p;
}

pair<pair<i32, u32>, bool> get_magic_u32(u32 d) {
    auto [a1, b1] = __get_magic_u32(d);
    if (b1 != -1) return { { a1, b1 }, false };
    else return { __get_magic_u32_complex(d), true };
}