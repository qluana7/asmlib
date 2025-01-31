#include <utility>

#define i32 int
#define u32 unsigned int

using namespace std;

constexpr inline u32 __abs(i32 d)
{ return d ^ (d >> 31) - (d >> 31); }

/*
    Hacker's Delight : Chapter 10. Integer Division By Constants
        FIGURE 10–1. Computing the magic number for signed division
        FIGURE 10–2. Computing the magic number for unsigned division
*/
pair<pair<i32, u32>, bool> get_magic_i32(i32 d) {
    constexpr u32 mg = 0x80000000;
    i32 p = 31;
    u32 delta,
        ad = __abs(d),
        t = mg + ((u32)d >> 31),
        anc = t - 1 - t % ad,
        q1 = mg / anc,
        r1 = mg - q1 * anc,
        q2 = mg / ad,
        r2 = mg - q2 * ad;
    
    do {
        p++;
        
        q1 <<= 1; r1 <<= 1;
        if (r1 >= anc) { q1++; r1 -= anc; }

        q2 <<= 1; r2 <<= 1;
        if (r2 >= ad) { q2++; r2 -= ad; }

        delta = ad - r2;
    } while (q1 < delta || (q1 == delta && r1 == 0));

    return { { (i32)(q2 + 1) * (d < 0 ? -1 : 1), p - 32 }, false };
}

pair<pair<i32, u32>, bool> get_magic_u32(u32 d) {
    constexpr u32 mg1 = 0x80000000, mg2 = 0x7FFFFFFF;
    i32 p = 31;
    u32 delta,
        nc = -1 - (-d) % d,
        q1 = mg1 / nc,
        r1 = mg1 - q1 * nc,
        q2 = mg2 / d,
        r2 = mg2 - q2 * d;
    
    bool complex = false;
    
    do {
        p++;

        if (r1 >= nc - r1) {
            q1 = q1 * 2 + 1;
            r1 = r1 * 2 - nc;
        } else { q1 <<= 1; r1 <<= 1; }
        if (r2 + 1 >= d - r2) {
            complex = q2 >= mg2;
            q2 = q2 * 2 + 1;
            r2 = r2 * 2 + 1 - d;
        } else { complex = q2 >= mg1; q2 <<= 1; r2 = r2 * 2 + 1; }

        delta = d - 1 - r2;
    } while (p < 64 && (q1 < delta || (q1 == delta && r1 == 0)));

    return { { q2 + 1, p - 32 }, complex };
}