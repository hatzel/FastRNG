// this file contains implementations of the algorithms described
// and implemented (in c) on http://xorshift.di.unimi.it/

public final class SplitMix64Generator: RandomGenerator {
    private var state: UInt64

    public init(seed: UInt64) {
        state = seed
    }

    public func next() -> UInt64 {
        state = state &+ 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}

public final class Xorshift128PlusGenerator: RandomGenerator {
    private let state = UnsafeMutablePointer<UInt64>.alloc(2)

    public init(seed: (UInt64, UInt64)) {
        state[0] = seed.0
        state[1] = seed.1
    }

    public init(seed: UInt64) {
        let g = SplitMix64Generator(seed: seed)
        state[0] = g.next()
        state[1] = g.next()
    }

    deinit {
        state.destroy()
    }

    public func next() -> UInt64 {
        var s1 = state[0]
        let s0 = state[1]
        state[0] = s0
        s1 ^= s1 << 23
        state[1] = s1 ^ s0 ^ (s1 >> 18) ^ (s0 >> 5)

        return state[1] &+ s0
    }
}

public final class Xorshift1024StarGenerator: RandomGenerator {
    private let state = UnsafeMutablePointer<UInt64>.alloc(16)
    private var p: Int = 0

    public init(seed: UInt64) {
        let g = SplitMix64Generator(seed: seed)

        for i in 0..<16 {
            state[i] = g.next()
        }
    }

    deinit {
        state.destroy()
    }

    public func next() -> UInt64 {
        let s0 = state[p]
        p = (p &+ 1) & 15
        var s1 = state[p]
        s1 ^= s1 << 31
        state[p] = s1 ^ s0 ^ (s1 >> 11) ^ (s0 >> 30)
        return state[p] &* 1181783497276652981
    }
}
