import Foundation

extension Target {

    public final class Builder {

        public init() {
            self.target = Target()
        }

        public init(_ target: Target) {
            self.target = Target(target)
        }

        public func with(minimumSaturation: CGFloat) -> Builder {
            target.minimumSaturation = minimumSaturation
            return self
        }

        public func with(targetSaturation: CGFloat) -> Builder {
            target.targetSaturation = targetSaturation
            return self
        }

        public func with(maximumSaturation: CGFloat) -> Builder {
            target.maximumSaturation = maximumSaturation
            return self
        }

        public func with(minimumLightness: CGFloat) -> Builder {
            target.minimumLightness = minimumLightness
            return self
        }

        public func with(targetLightness: CGFloat) -> Builder {
            target.targetLightness = targetLightness
            return self
        }

        public func with(maximumLightness: CGFloat) -> Builder {
            target.maximumLightness = maximumLightness
            return self
        }

        public func with(saturationWeight: CGFloat) -> Builder {
            target.saturationWeight = saturationWeight
            return self
        }

        public func with(lightnessWeight: CGFloat) -> Builder {
            target.lightnessWeight = lightnessWeight
            return self
        }

        public func with(populationWeight: CGFloat) -> Builder {
            target.populationWeight = populationWeight
            return self
        }

        public func with(exclusive: Bool) -> Builder {
            target.isExclusive = exclusive
            return self
        }

        public func build() -> Target {
            target
        }

        private let target: Target
    }
}
