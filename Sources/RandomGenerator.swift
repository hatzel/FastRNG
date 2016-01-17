public protocol RandomGenerator {
    init(seed: UInt64)
    func next() -> UInt64
}

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

extension RandomGenerator {
    public init() {
        #if os(Linux)
            var t = timespec()
            clock_gettime(CLOCK_REALTIME, &t)
            self.init(seed: UInt64(t.tv_sec) + UInt64(t.tv_nsec))
        #else
            let r1 = UInt64(arc4random())
            let r2 = UInt64(arc4random())
            self.init(seed: r1 &+ r2)
        #endif
    }

    public func sample<C where C: CollectionType, C.Index.Distance == Int>(collection: C) -> C.Generator.Element {
        let num = UInt64(collection.count)
        let excess = (UInt64.max % num) + 1
        let max = UInt64.max - excess

        var sample: UInt64 = 0

        repeat {
            sample = next()
        } while sample > max

        let pos = Int(sample % num)
        let index = collection.startIndex.advancedBy(pos)

        return collection[index]
    }

    public func randomDouble() -> Double {
        let max = UInt64.max
        return Double(next()) / Double(max)
    }
}
