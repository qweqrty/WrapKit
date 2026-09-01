#if os(iOS) || os(tvOS)
import UIKit

enum SwiftUIParityImageComparator {
    private struct EndpointCluster {
        var color: CanonicalRGBA
        var support: Int
    }

    private struct EndpointSignature {
        let colors: [CanonicalRGBA]
        let weights: [Double]
        let fitResidual: SIMD4<Double>

        var isEndpoint: Bool {
            weights.contains { $0 >= 1 - endpointWeightEpsilon }
        }
    }

    private struct EndpointFit {
        let weights: [Double]
        let residual: SIMD4<Double>
    }

    private struct DifferenceMoment {
        var absoluteMass = 0.0
        var absoluteX = 0.0
        var absoluteY = 0.0
        var signedMass = 0.0
        var signedX = 0.0
        var signedY = 0.0
    }

    private static let edgeNeighborhoodRadius = 1
    private static let endpointSignatureRadius = 3
    private static let endpointContextRadius = 5
    private static let endpointFitTolerance = 3.0
    private static let endpointWeightTolerance = 0.05
    private static let endpointWeightEpsilon = 0.02
    private static let endpointColorTolerance: UInt8 = 2
    private static let minimumStableEndpointSupport = 4
    private static let maximumLocalEndpointCount = 4
    private static let minimumEndpointDistanceSquared = 64.0

    private static let localCoverageRadius = 2
    private static let localCoverageSide = localCoverageRadius * 2 + 1
    private static let localCoverageAnchorRadius = 1
    private static let localMaskSearchRadius = 2
    private static let minimumCoverageDifference = 0.005
    private static let minimumCoverageDifferenceSupport = 3
    private static let transparentFringeCoverageTolerance = 0.02
    private static let minimumTwoAxisCoverageVariation = 0.005
    private static let tightCoverageMassTolerance = 1.75
    private static let tightCoverageL1Tolerance = 2.0
    private static let tightCoverageMomentTolerance = 1.5
    private static let curvedCoverageMassTolerance = 5.25
    private static let curvedCoverageL1Tolerance = 5.25
    private static let curvedCoverageMomentTolerance = 5.5

    private static let rendererAlphaCoverageDistance = 8.0
    private static let rendererCoverageBoundsTolerance = 0.01
    private static let rendererPositiveResidualTolerance = 4.5
    private static let rendererNegativeResidualTolerance = 64.0
    private static let maximumDifferenceMoment = 0.48

    static func differenceMessage(_ old: UIImage, _ new: UIImage) -> String? {
        guard let oldCanonical = canonicalSnapshot(old) else {
            return "Reference image could not be normalized."
        }
        guard let newCanonical = canonicalSnapshot(new) else {
            return "Newly-taken snapshot could not be normalized."
        }
        if let message = canonicalGeometryDifferenceMessage(
            old,
            oldCanonical,
            new,
            newCanonical
        ) {
            return message
        }

        let width = oldCanonical.width
        let pixelCount = width * oldCanonical.height
        var usedCurvedRendererAllowance = false
        // Transparent contours encode physical coverage in alpha. Premultiplied RGB moments from
        // multiple differently colored glyphs are not a shared geometry signal.
        var requiresColorMomentValidation = false

        for pixelIndex in 0..<pixelCount {
            guard !canonicalPixelsMatch(
                oldCanonical,
                at: pixelIndex,
                newCanonical,
                at: pixelIndex,
                tolerance: canonicalQuantizationTolerance
            ) else { continue }

            let x = pixelIndex % width
            let y = pixelIndex / width
            guard hasNearbyEdge(oldCanonical, x: x, y: y),
                  hasNearbyEdge(newCanonical, x: x, y: y) else {
                return "SwiftUI parity has a non-edge RGBA difference at pixel (\(x), \(y))."
            }
            if phaseMatches(source: oldCanonical, target: newCanonical, x: x, y: y) {
                continue
            }
            var usesTransparentFringeAllowance = false
            guard curvedRendererContourMatches(
                source: oldCanonical,
                target: newCanonical,
                x: x,
                y: y,
                usesTransparentFringeAllowance: &usesTransparentFringeAllowance
            ) else {
                return "SwiftUI parity edge coverage differs near pixel (\(x), \(y))."
            }
            usedCurvedRendererAllowance = true
            requiresColorMomentValidation = requiresColorMomentValidation
                || !usesTransparentFringeAllowance
        }

        guard !usedCurvedRendererAllowance || differenceMomentsMatch(
            oldCanonical,
            newCanonical,
            validatesColorChannels: requiresColorMomentValidation
        ) else {
            return "SwiftUI parity changes the physical-pixel position of rendered content."
        }
        return nil
    }

    private static func hasNearbyEdge(
        _ snapshot: CanonicalSnapshot,
        x: Int,
        y: Int
    ) -> Bool {
        let minimumX = max(0, x - edgeNeighborhoodRadius)
        let maximumX = min(snapshot.width - 1, x + edgeNeighborhoodRadius)
        let minimumY = max(0, y - edgeNeighborhoodRadius)
        let maximumY = min(snapshot.height - 1, y + edgeNeighborhoodRadius)

        for candidateY in minimumY...maximumY {
            for candidateX in minimumX...maximumX where pixelIsEdge(
                snapshot,
                x: candidateX,
                y: candidateY
            ) {
                return true
            }
        }
        return false
    }

    private static func pixelIsEdge(
        _ snapshot: CanonicalSnapshot,
        x: Int,
        y: Int
    ) -> Bool {
        let pixelIndex = y * snapshot.width + x
        let minimumX = max(0, x - 1)
        let maximumX = min(snapshot.width - 1, x + 1)
        let minimumY = max(0, y - 1)
        let maximumY = min(snapshot.height - 1, y + 1)

        for candidateY in minimumY...maximumY {
            for candidateX in minimumX...maximumX {
                let candidateIndex = candidateY * snapshot.width + candidateX
                guard candidateIndex != pixelIndex else { continue }
                if !canonicalPixelsMatch(
                    snapshot,
                    at: pixelIndex,
                    snapshot,
                    at: candidateIndex,
                    tolerance: canonicalQuantizationTolerance
                ) {
                    return true
                }
            }
        }
        return false
    }

    private static func phaseMatches(
        source: CanonicalSnapshot,
        target: CanonicalSnapshot,
        x: Int,
        y: Int
    ) -> Bool {
        let endpointRadii = endpointContextRadius == endpointSignatureRadius
            ? [endpointSignatureRadius]
            : [endpointSignatureRadius, endpointContextRadius]

        for endpointRadius in endpointRadii {
            guard let sourceSignature = endpointSignature(
                source,
                x: x,
                y: y,
                endpointRadius: endpointRadius
            ), let targetSignature = endpointSignature(
                target,
                x: x,
                y: y,
                endpointRadius: endpointRadius
            ), endpointColorsMatch(sourceSignature, targetSignature),
               !(sourceSignature.isEndpoint && targetSignature.isEndpoint) else {
                continue
            }
            if endpointSignaturesMatch(sourceSignature, targetSignature) {
                return true
            }
        }
        return false
    }

    private static func curvedRendererContourMatches(
        source: CanonicalSnapshot,
        target: CanonicalSnapshot,
        x: Int,
        y: Int,
        usesTransparentFringeAllowance: inout Bool
    ) -> Bool {
        let endpointColors = commonLocalEndpointColors(
            source: source,
            target: target,
            x: x,
            y: y
        )
        if endpointColors.count >= 2 {
            for firstIndex in 0..<(endpointColors.count - 1) {
                for secondIndex in (firstIndex + 1)..<endpointColors.count {
                    let endpoints = [endpointColors[firstIndex], endpointColors[secondIndex]]
                    guard endpointDistanceSquared(endpoints[0], endpoints[1])
                            > minimumEndpointDistanceSquared,
                          let sourceCoverage = localRendererCoverage(
                            source,
                            x: x,
                            y: y,
                            endpoints: endpoints
                          ),
                          let targetCoverage = localRendererCoverage(
                            target,
                            x: x,
                            y: y,
                            endpoints: endpoints
                          ) else {
                        continue
                    }

                    if localCoverageMatches(sourceCoverage, targetCoverage) {
                        usesTransparentFringeAllowance = endpoints.contains(where: {
                            Double($0.alpha) / 255 <= transparentFringeCoverageTolerance
                        })
                        return true
                    }
                    guard endpoints.contains(where: {
                        Double($0.alpha) / 255 <= transparentFringeCoverageTolerance
                    }), balancedTransparentFringeMatches(
                        source: source,
                        target: target,
                        x: x,
                        y: y,
                        endpoints: endpoints
                    ) else {
                        continue
                    }
                    usesTransparentFringeAllowance = true
                    return true
                }
            }
        }
        let matchesSyntheticTransparentFringe = syntheticTransparentFringeMatches(
            source: source,
            target: target,
            x: x,
            y: y,
            commonEndpoints: endpointColors
        )
        usesTransparentFringeAllowance = matchesSyntheticTransparentFringe
        return matchesSyntheticTransparentFringe
    }

    private static func syntheticTransparentFringeMatches(
        source: CanonicalSnapshot,
        target: CanonicalSnapshot,
        x: Int,
        y: Int,
        commonEndpoints: [CanonicalRGBA]
    ) -> Bool {
        guard commonEndpoints.count == 1,
              let commonEndpoint = commonEndpoints.first else {
            return false
        }

        let endpoints: [CanonicalRGBA]
        let endpointAlpha = Double(commonEndpoint.alpha) / 255
        if endpointAlpha >= 1 - endpointWeightEpsilon {
            guard localContextContainsNearTransparentPixel(source, x: x, y: y),
                  localContextContainsNearTransparentPixel(target, x: x, y: y) else {
                return false
            }
            endpoints = [transparentColor, commonEndpoint]
        } else if endpointAlpha <= transparentFringeCoverageTolerance {
            guard let opaqueEndpoint = commonLocalNearOpaqueColor(
                source: source,
                target: target,
                x: x,
                y: y
            ) else {
                return false
            }
            endpoints = [commonEndpoint, opaqueEndpoint]
        } else {
            return false
        }

        guard endpointDistanceSquared(endpoints[0], endpoints[1])
                > minimumEndpointDistanceSquared else {
            return false
        }
        return balancedTransparentFringeMatches(
            source: source,
            target: target,
            x: x,
            y: y,
            endpoints: endpoints
        )
    }

    private static func commonLocalNearOpaqueColor(
        source: CanonicalSnapshot,
        target: CanonicalSnapshot,
        x: Int,
        y: Int
    ) -> CanonicalRGBA? {
        let sourceClusters = localNearOpaqueClusters(source, x: x, y: y)
        let targetClusters = localNearOpaqueClusters(target, x: x, y: y)
        var commonClusters: [EndpointCluster] = []

        for sourceCluster in sourceClusters {
            for targetCluster in targetClusters where colorsMatch(
                sourceCluster.color,
                targetCluster.color,
                tolerance: endpointColorTolerance
            ) {
                let color = averageColor(sourceCluster.color, targetCluster.color)
                let support = sourceCluster.support + targetCluster.support
                if let index = commonClusters.firstIndex(where: {
                    colorsMatch(color, $0.color, tolerance: endpointColorTolerance)
                }) {
                    commonClusters[index].support = max(
                        commonClusters[index].support,
                        support
                    )
                    if color.alpha > commonClusters[index].color.alpha {
                        commonClusters[index].color = color
                    }
                } else {
                    commonClusters.append(EndpointCluster(color: color, support: support))
                }
            }
        }
        return commonClusters.max {
            // A support-heavy antialiased shade must not replace an observed opaque core:
            // the core is the physical endpoint that bounds fringe coverage.
            if $0.color.alpha != $1.color.alpha {
                return $0.color.alpha < $1.color.alpha
            }
            if $0.support != $1.support { return $0.support < $1.support }
            return colorIsOrderedBefore($1.color, $0.color)
        }?.color
    }

    private static func localNearOpaqueClusters(
        _ snapshot: CanonicalSnapshot,
        x: Int,
        y: Int
    ) -> [EndpointCluster] {
        let minimumX = max(0, x - endpointContextRadius)
        let maximumX = min(snapshot.width - 1, x + endpointContextRadius)
        let minimumY = max(0, y - endpointContextRadius)
        let maximumY = min(snapshot.height - 1, y + endpointContextRadius)
        guard minimumX <= maximumX, minimumY <= maximumY else { return [] }

        var clusters: [EndpointCluster] = []
        for candidateY in minimumY...maximumY {
            for candidateX in minimumX...maximumX {
                let candidateColor = color(snapshot, x: candidateX, y: candidateY)
                guard Double(candidateColor.alpha) / 255 >= 1 - endpointWeightTolerance else {
                    continue
                }
                if let index = clusters.firstIndex(where: {
                    colorsMatch(
                        candidateColor,
                        $0.color,
                        tolerance: endpointColorTolerance
                    )
                }) {
                    clusters[index].support += 1
                    if candidateColor.alpha > clusters[index].color.alpha {
                        clusters[index].color = candidateColor
                    }
                } else {
                    clusters.append(EndpointCluster(color: candidateColor, support: 1))
                }
            }
        }
        return clusters
    }

    private static func localContextContainsNearTransparentPixel(
        _ snapshot: CanonicalSnapshot,
        x: Int,
        y: Int
    ) -> Bool {
        let minimumX = max(0, x - endpointContextRadius)
        let maximumX = min(snapshot.width - 1, x + endpointContextRadius)
        let minimumY = max(0, y - endpointContextRadius)
        let maximumY = min(snapshot.height - 1, y + endpointContextRadius)
        guard minimumX <= maximumX, minimumY <= maximumY else { return false }

        for candidateY in minimumY...maximumY {
            for candidateX in minimumX...maximumX where Double(
                color(snapshot, x: candidateX, y: candidateY).alpha
            ) / 255 <= endpointWeightTolerance {
                return true
            }
        }
        return false
    }

    private static func commonLocalEndpointColors(
        source: CanonicalSnapshot,
        target: CanonicalSnapshot,
        x: Int,
        y: Int
    ) -> [CanonicalRGBA] {
        let sourceClusters = stableEndpointClusters(
            source,
            x: x,
            y: y,
            radius: endpointContextRadius,
            includesVirtualTransparentContext: true
        )
        let targetClusters = stableEndpointClusters(
            target,
            x: x,
            y: y,
            radius: endpointContextRadius,
            includesVirtualTransparentContext: true
        )

        var commonClusters: [EndpointCluster] = []
        for sourceCluster in sourceClusters {
            for targetCluster in targetClusters where colorsMatch(
                sourceCluster.color,
                targetCluster.color,
                tolerance: endpointColorTolerance
            ) {
                let color = averageColor(sourceCluster.color, targetCluster.color)
                let support = sourceCluster.support + targetCluster.support
                if let index = commonClusters.firstIndex(where: {
                    colorsMatch(color, $0.color, tolerance: endpointColorTolerance)
                }) {
                    commonClusters[index].support = max(
                        commonClusters[index].support,
                        support
                    )
                } else {
                    commonClusters.append(EndpointCluster(color: color, support: support))
                }
            }
        }
        return commonClusters.sorted {
            if $0.support != $1.support { return $0.support > $1.support }
            return colorIsOrderedBefore($0.color, $1.color)
        }
        .prefix(maximumLocalEndpointCount)
        .map(\.color)
    }

    private static func stableEndpointClusters(
        _ snapshot: CanonicalSnapshot,
        x: Int,
        y: Int,
        radius: Int,
        includesVirtualTransparentContext: Bool
    ) -> [EndpointCluster] {
        guard snapshot.width >= 2, snapshot.height >= 2 else { return [] }
        let minimumTileX = max(0, x - radius)
        let maximumTileX = min(snapshot.width - 2, x + radius - 1)
        let minimumTileY = max(0, y - radius)
        let maximumTileY = min(snapshot.height - 2, y + radius - 1)
        guard minimumTileX <= maximumTileX, minimumTileY <= maximumTileY else {
            return []
        }

        var colorSupport: [CanonicalRGBA: Int] = [:]
        for tileY in minimumTileY...maximumTileY {
            for tileX in minimumTileX...maximumTileX {
                let colors = [
                    color(snapshot, x: tileX, y: tileY),
                    color(snapshot, x: tileX + 1, y: tileY),
                    color(snapshot, x: tileX, y: tileY + 1),
                    color(snapshot, x: tileX + 1, y: tileY + 1)
                ]
                guard colorsAreStable(colors) else { continue }
                for color in colors {
                    colorSupport[color, default: 0] += 1
                }
            }
        }

        let touchesBoundary = x - radius < 0 || y - radius < 0
            || x + radius >= snapshot.width || y + radius >= snapshot.height
        if includesVirtualTransparentContext, touchesBoundary {
            colorSupport[transparentColor, default: 0] += minimumStableEndpointSupport
        }

        let sortedColors = colorSupport.sorted {
            if $0.value != $1.value { return $0.value > $1.value }
            return colorIsOrderedBefore($0.key, $1.key)
        }
        var clusters: [EndpointCluster] = []
        for (color, support) in sortedColors {
            if let index = clusters.firstIndex(where: {
                colorsMatch($0.color, color, tolerance: endpointColorTolerance)
            }) {
                clusters[index].support += support
            } else {
                clusters.append(EndpointCluster(color: color, support: support))
            }
        }
        return clusters.filter { $0.support >= minimumStableEndpointSupport }
    }

    private static func endpointSignature(
        _ snapshot: CanonicalSnapshot,
        x: Int,
        y: Int,
        endpointRadius: Int
    ) -> EndpointSignature? {
        let clusters = stableEndpointClusters(
            snapshot,
            x: x,
            y: y,
            radius: endpointRadius,
            includesVirtualTransparentContext: false
        )
        guard (2...3).contains(clusters.count) else { return nil }
        let colors = clusters.map(\.color).sorted(by: colorIsOrderedBefore)
        guard let fit = endpointFit(color(snapshot, x: x, y: y), endpoints: colors) else {
            return nil
        }
        return EndpointSignature(
            colors: colors,
            weights: fit.weights,
            fitResidual: fit.residual
        )
    }

    private static func endpointFit(
        _ color: CanonicalRGBA,
        endpoints: [CanonicalRGBA]
    ) -> EndpointFit? {
        let point = (0..<canonicalBytesPerPixel).map { Double(color[$0]) }
        let vectors = endpoints.map { endpoint in
            (0..<canonicalBytesPerPixel).map { Double(endpoint[$0]) }
        }

        let weights: [Double]
        if vectors.count == 2 {
            let direction = zip(vectors[1], vectors[0]).map(-)
            let denominator = direction.reduce(0) { $0 + $1 * $1 }
            guard denominator > 0 else { return nil }
            let relativePoint = zip(point, vectors[0]).map(-)
            let position = zip(relativePoint, direction).reduce(0) {
                $0 + $1.0 * $1.1
            } / denominator
            weights = [1 - position, position]
        } else {
            guard vectors.count == 3 else { return nil }
            let firstDirection = zip(vectors[1], vectors[0]).map(-)
            let secondDirection = zip(vectors[2], vectors[0]).map(-)
            let relativePoint = zip(point, vectors[0]).map(-)
            let firstSquared = firstDirection.reduce(0) { $0 + $1 * $1 }
            let secondSquared = secondDirection.reduce(0) { $0 + $1 * $1 }
            let cross = zip(firstDirection, secondDirection).reduce(0) {
                $0 + $1.0 * $1.1
            }
            let firstProjection = zip(relativePoint, firstDirection).reduce(0) {
                $0 + $1.0 * $1.1
            }
            let secondProjection = zip(relativePoint, secondDirection).reduce(0) {
                $0 + $1.0 * $1.1
            }
            let determinant = firstSquared * secondSquared - cross * cross
            guard abs(determinant) > 1 else { return nil }
            let secondWeight = (
                secondProjection * firstSquared - firstProjection * cross
            ) / determinant
            let firstWeight = (
                firstProjection * secondSquared - secondProjection * cross
            ) / determinant
            weights = [1 - firstWeight - secondWeight, firstWeight, secondWeight]
        }

        guard weights.allSatisfy({
            $0 >= -endpointWeightEpsilon && $0 <= 1 + endpointWeightEpsilon
        }) else { return nil }

        var residual = SIMD4<Double>(repeating: 0)
        for channel in 0..<canonicalBytesPerPixel {
            let fittedValue = zip(weights, vectors).reduce(0) {
                $0 + $1.0 * $1.1[channel]
            }
            residual[channel] = point[channel] - fittedValue
            guard abs(residual[channel]) <= endpointFitTolerance else { return nil }
        }
        return EndpointFit(weights: weights, residual: residual)
    }

    private static func endpointSignaturesMatch(
        _ lhs: EndpointSignature,
        _ rhs: EndpointSignature
    ) -> Bool {
        guard endpointColorsMatch(lhs, rhs), lhs.weights.count == rhs.weights.count else {
            return false
        }
        for index in lhs.weights.indices where abs(
            lhs.weights[index] - rhs.weights[index]
        ) > endpointWeightTolerance {
            return false
        }
        for channel in 0..<canonicalBytesPerPixel where abs(
            lhs.fitResidual[channel] - rhs.fitResidual[channel]
        ) > endpointFitTolerance {
            return false
        }
        return true
    }

    private static func endpointColorsMatch(
        _ lhs: EndpointSignature,
        _ rhs: EndpointSignature
    ) -> Bool {
        guard lhs.colors.count == rhs.colors.count else { return false }
        for index in lhs.colors.indices where !colorsMatch(
            lhs.colors[index],
            rhs.colors[index],
            tolerance: endpointColorTolerance
        ) {
            return false
        }
        return true
    }

    private static func localRendererCoverage(
        _ snapshot: CanonicalSnapshot,
        x: Int,
        y: Int,
        endpoints: [CanonicalRGBA],
        radius: Int = localCoverageRadius
    ) -> [Double]? {
        var coverage: [Double] = []
        let range = -radius...radius
        for offsetY in range {
            for offsetX in range {
                guard let value = rendererCoverage(
                    color(snapshot, x: x + offsetX, y: y + offsetY),
                    endpoints: endpoints
                ) else { return nil }
                coverage.append(value)
            }
        }
        return coverage
    }

    private static func rendererCoverage(
        _ color: CanonicalRGBA,
        endpoints: [CanonicalRGBA]
    ) -> Double? {
        guard endpoints.count == 2 else { return nil }
        let first = endpoints[0]
        let second = endpoints[1]
        let alphaDirection = Double(second.alpha) - Double(first.alpha)

        let position: Double
        if abs(alphaDirection) >= rendererAlphaCoverageDistance {
            position = (Double(color.alpha) - Double(first.alpha)) / alphaDirection
        } else {
            let channels = (0..<3).filter {
                abs(Double(second[$0]) - Double(first[$0])) >= rendererAlphaCoverageDistance
            }
            let denominator = channels.reduce(0.0) {
                let direction = Double(second[$1]) - Double(first[$1])
                return $0 + direction * direction
            }
            guard denominator > 0 else { return nil }
            position = channels.reduce(0.0) {
                let direction = Double(second[$1]) - Double(first[$1])
                let relative = Double(color[$1]) - Double(first[$1])
                return $0 + relative * direction
            } / denominator
        }

        guard position >= -rendererCoverageBoundsTolerance,
              position <= 1 + rendererCoverageBoundsTolerance else {
            return nil
        }
        for channel in 0..<canonicalBytesPerPixel {
            let direction = Double(second[channel]) - Double(first[channel])
            let fitted = Double(first[channel]) + position * direction
            let residual = Double(color[channel]) - fitted
            guard residual <= rendererPositiveResidualTolerance,
                  residual >= -rendererNegativeResidualTolerance else {
                return nil
            }
        }
        return min(1, max(0, position))
    }

    private static func balancedTransparentFringeMatches(
        source: CanonicalSnapshot,
        target: CanonicalSnapshot,
        x: Int,
        y: Int,
        endpoints: [CanonicalRGBA]
    ) -> Bool {
        let anchors = -localCoverageAnchorRadius...localCoverageAnchorRadius
        for offsetY in anchors {
            for offsetX in anchors {
                let anchorX = x + offsetX
                let anchorY = y + offsetY
                let sourceCoverage = localRendererCoverage(
                    source,
                    x: anchorX,
                    y: anchorY,
                    endpoints: endpoints
                )
                let targetCoverage = localRendererCoverage(
                    target,
                    x: anchorX,
                    y: anchorY,
                    endpoints: endpoints
                )
                guard let sourceCoverage,
                      let targetCoverage,
                      balancedTransparentFringeCoverageMatches(
                    sourceCoverage,
                    targetCoverage
                      ) else {
                    continue
                }

                let matchesOneAxis = coverageHasMatchingOneAxisVariation(
                    sourceCoverage,
                    targetCoverage
                )
                let contextRadii = (localCoverageRadius + 1)...endpointContextRadius
                for contextRadius in contextRadii {
                    let contextSide = contextRadius * 2 + 1
                    let sourceContext = localRendererCoverage(
                        source,
                        x: anchorX,
                        y: anchorY,
                        endpoints: endpoints,
                        radius: contextRadius
                    )
                    let targetContext = localRendererCoverage(
                        target,
                        x: anchorX,
                        y: anchorY,
                        endpoints: endpoints,
                        radius: contextRadius
                    )
                    guard let sourceContext,
                          let targetContext,
                          coverageTouchesTransparentEndpoint(
                        sourceContext,
                        targetContext
                          ) else {
                        continue
                    }

                    if matchesOneAxis {
                        return true
                    }
                    if coverageHasTwoAxisVariation(sourceContext, side: contextSide),
                       coverageHasTwoAxisVariation(targetContext, side: contextSide) {
                        return true
                    }
                }
            }
        }
        return false
    }

    private static func localCoverageMatches(
        _ source: [Double],
        _ target: [Double]
    ) -> Bool {
        guard source.count == target.count,
              source.count == localCoverageSide * localCoverageSide,
              coverageMaskHasLocalMatch(source, target),
              coverageMaskHasLocalMatch(target, source) else {
            return false
        }
        let sourceVariation = coverageAxisVariation(source)
        let targetVariation = coverageAxisVariation(target)
        guard sourceVariation.horizontal > minimumTwoAxisCoverageVariation,
              sourceVariation.vertical > minimumTwoAxisCoverageVariation,
              targetVariation.horizontal > minimumTwoAxisCoverageVariation,
              targetVariation.vertical > minimumTwoAxisCoverageVariation else {
            return false
        }

        let differences = zip(source, target).map(-)
        let significant = differences.filter { abs($0) > minimumCoverageDifference }
        guard !significant.isEmpty else { return true }

        let hasPositive = significant.contains { $0 > 0 }
        let hasNegative = significant.contains { $0 < 0 }
        let metrics = coverageDifferenceMetrics(differences)
        let center = localCoverageRadius * localCoverageSide + localCoverageRadius
        let centerDifference = abs(differences[center])

        if significant.count == 1,
           max(source[center], target[center]) <= transparentFringeCoverageTolerance,
           centerDifference <= transparentFringeCoverageTolerance {
            return true
        }

        if hasPositive, hasNegative {
            return centerDifference <= endpointWeightTolerance
                && abs(metrics.mass) <= tightCoverageMassTolerance
                && metrics.l1 <= tightCoverageL1Tolerance
                && abs(metrics.horizontalMoment) <= tightCoverageMomentTolerance
                && abs(metrics.verticalMoment) <= tightCoverageMomentTolerance
        }
        return significant.count >= minimumCoverageDifferenceSupport
            && abs(metrics.mass) <= curvedCoverageMassTolerance
            && metrics.l1 <= curvedCoverageL1Tolerance
            && abs(metrics.horizontalMoment) <= curvedCoverageMomentTolerance
            && abs(metrics.verticalMoment) <= curvedCoverageMomentTolerance
    }

    private static func balancedTransparentFringeCoverageMatches(
        _ source: [Double],
        _ target: [Double]
    ) -> Bool {
        guard source.count == target.count,
              source.count == localCoverageSide * localCoverageSide,
              coverageMaskHasLocalMatch(source, target),
              coverageMaskHasLocalMatch(target, source) else {
            return false
        }

        let differences = zip(source, target).map(-)
        let significant = differences.filter { abs($0) > minimumCoverageDifference }
        guard significant.contains(where: { $0 > 0 }),
              significant.contains(where: { $0 < 0 }) else {
            return false
        }

        let metrics = coverageDifferenceMetrics(differences)
        return abs(metrics.mass) <= tightCoverageMassTolerance
            && metrics.l1 <= tightCoverageL1Tolerance
            && abs(metrics.horizontalMoment) <= tightCoverageMomentTolerance
            && abs(metrics.verticalMoment) <= tightCoverageMomentTolerance
    }

    private static func coverageTouchesTransparentEndpoint(
        _ source: [Double],
        _ target: [Double]
    ) -> Bool {
        source.contains(where: { $0 <= endpointWeightTolerance })
            && target.contains(where: { $0 <= endpointWeightTolerance })
    }

    private static func coverageDifferenceMetrics(
        _ differences: [Double]
    ) -> (mass: Double, l1: Double, horizontalMoment: Double, verticalMoment: Double) {
        var mass = 0.0
        var l1 = 0.0
        var horizontalMoment = 0.0
        var verticalMoment = 0.0
        for index in differences.indices {
            let difference = differences[index]
            let x = Double(index % localCoverageSide - localCoverageRadius)
            let y = Double(index / localCoverageSide - localCoverageRadius)
            mass += difference
            l1 += abs(difference)
            horizontalMoment += difference * x
            verticalMoment += difference * y
        }
        return (mass, l1, horizontalMoment, verticalMoment)
    }

    private static func coverageMaskHasLocalMatch(
        _ source: [Double],
        _ target: [Double]
    ) -> Bool {
        for index in source.indices {
            let sourceClass = source[index] >= 0.5
            guard sourceClass != (target[index] >= 0.5) else { continue }

            let x = index % localCoverageSide
            let y = index / localCoverageSide
            var hasMatch = false
            for offsetY in -localMaskSearchRadius...localMaskSearchRadius {
                for offsetX in -localMaskSearchRadius...localMaskSearchRadius {
                    let targetX = x + offsetX
                    let targetY = y + offsetY
                    guard targetX >= 0, targetX < localCoverageSide,
                          targetY >= 0, targetY < localCoverageSide else { continue }
                    let targetIndex = targetY * localCoverageSide + targetX
                    if sourceClass == (target[targetIndex] >= 0.5) {
                        hasMatch = true
                        break
                    }
                }
                if hasMatch { break }
            }
            if !hasMatch { return false }
        }
        return true
    }

    private static func coverageAxisVariation(
        _ coverage: [Double],
        side: Int = localCoverageSide
    ) -> (horizontal: Double, vertical: Double) {
        var horizontal = 0.0
        var vertical = 0.0
        for y in 0..<side {
            for x in 0..<side {
                let index = y * side + x
                if x + 1 < side {
                    horizontal = max(horizontal, abs(coverage[index + 1] - coverage[index]))
                }
                if y + 1 < side {
                    vertical = max(
                        vertical,
                        abs(coverage[index + side] - coverage[index])
                    )
                }
            }
        }
        return (horizontal, vertical)
    }

    private static func coverageHasTwoAxisVariation(
        _ coverage: [Double],
        side: Int
    ) -> Bool {
        guard coverage.count == side * side else { return false }
        let variation = coverageAxisVariation(coverage, side: side)
        return variation.horizontal > minimumTwoAxisCoverageVariation
            && variation.vertical > minimumTwoAxisCoverageVariation
    }

    private static func coverageHasMatchingOneAxisVariation(
        _ source: [Double],
        _ target: [Double]
    ) -> Bool {
        let sourceVariation = coverageAxisVariation(source)
        let targetVariation = coverageAxisVariation(target)
        let horizontalOnly = sourceVariation.horizontal > minimumTwoAxisCoverageVariation
            && targetVariation.horizontal > minimumTwoAxisCoverageVariation
            && sourceVariation.vertical <= minimumTwoAxisCoverageVariation
            && targetVariation.vertical <= minimumTwoAxisCoverageVariation
        let verticalOnly = sourceVariation.vertical > minimumTwoAxisCoverageVariation
            && targetVariation.vertical > minimumTwoAxisCoverageVariation
            && sourceVariation.horizontal <= minimumTwoAxisCoverageVariation
            && targetVariation.horizontal <= minimumTwoAxisCoverageVariation
        return horizontalOnly || verticalOnly
    }

    private static func differenceMomentsMatch(
        _ source: CanonicalSnapshot,
        _ target: CanonicalSnapshot,
        validatesColorChannels: Bool
    ) -> Bool {
        var moments = [DifferenceMoment](
            repeating: DifferenceMoment(),
            count: canonicalBytesPerPixel
        )
        let pixelCount = source.width * source.height
        for pixelIndex in 0..<pixelCount {
            let x = Double(pixelIndex % source.width)
            let y = Double(pixelIndex / source.width)
            let byteIndex = pixelIndex * canonicalBytesPerPixel
            let firstChannel = validatesColorChannels ? 0 : canonicalBytesPerPixel - 1
            for channel in firstChannel..<canonicalBytesPerPixel {
                let difference = Double(source.rgba[byteIndex + channel])
                    - Double(target.rgba[byteIndex + channel])
                guard abs(difference) > Double(canonicalQuantizationTolerance) else {
                    continue
                }
                let absoluteDifference = abs(difference)
                moments[channel].absoluteMass += absoluteDifference
                moments[channel].absoluteX += absoluteDifference * x
                moments[channel].absoluteY += absoluteDifference * y
                moments[channel].signedMass += difference
                moments[channel].signedX += difference * x
                moments[channel].signedY += difference * y
            }
        }

        for moment in moments where moment.absoluteMass > 0 {
            let absoluteCenterX = moment.absoluteX / moment.absoluteMass
            let absoluteCenterY = moment.absoluteY / moment.absoluteMass
            let centeredX = moment.signedX - moment.signedMass * absoluteCenterX
            let centeredY = moment.signedY - moment.signedMass * absoluteCenterY
            guard abs(centeredX) / moment.absoluteMass <= maximumDifferenceMoment,
                  abs(centeredY) / moment.absoluteMass <= maximumDifferenceMoment else {
                return false
            }
        }
        return true
    }

    private static func colorsAreStable(_ colors: [CanonicalRGBA]) -> Bool {
        for channel in 0..<canonicalBytesPerPixel {
            guard let minimum = colors.map({ $0[channel] }).min(),
                  let maximum = colors.map({ $0[channel] }).max(),
                  channelDifference(minimum, maximum) <= canonicalQuantizationTolerance else {
                return false
            }
        }
        return true
    }

    private static func colorsMatch(
        _ lhs: CanonicalRGBA,
        _ rhs: CanonicalRGBA,
        tolerance: UInt8
    ) -> Bool {
        for channel in 0..<canonicalBytesPerPixel where channelDifference(
            lhs[channel],
            rhs[channel]
        ) > tolerance {
            return false
        }
        return true
    }

    private static func endpointDistanceSquared(
        _ lhs: CanonicalRGBA,
        _ rhs: CanonicalRGBA
    ) -> Double {
        (0..<canonicalBytesPerPixel).reduce(0) {
            let difference = Double(lhs[$1]) - Double(rhs[$1])
            return $0 + difference * difference
        }
    }

    private static func averageColor(
        _ lhs: CanonicalRGBA,
        _ rhs: CanonicalRGBA
    ) -> CanonicalRGBA {
        CanonicalRGBA(
            red: UInt8((Int(lhs.red) + Int(rhs.red)) / 2),
            green: UInt8((Int(lhs.green) + Int(rhs.green)) / 2),
            blue: UInt8((Int(lhs.blue) + Int(rhs.blue)) / 2),
            alpha: UInt8((Int(lhs.alpha) + Int(rhs.alpha)) / 2)
        )
    }

    private static func color(
        _ snapshot: CanonicalSnapshot,
        x: Int,
        y: Int
    ) -> CanonicalRGBA {
        guard x >= 0, x < snapshot.width, y >= 0, y < snapshot.height else {
            return transparentColor
        }
        let byteIndex = (y * snapshot.width + x) * canonicalBytesPerPixel
        return CanonicalRGBA(
            red: snapshot.rgba[byteIndex],
            green: snapshot.rgba[byteIndex + 1],
            blue: snapshot.rgba[byteIndex + 2],
            alpha: snapshot.rgba[byteIndex + 3]
        )
    }

    private static func colorIsOrderedBefore(
        _ lhs: CanonicalRGBA,
        _ rhs: CanonicalRGBA
    ) -> Bool {
        for channel in 0..<canonicalBytesPerPixel where lhs[channel] != rhs[channel] {
            return lhs[channel] < rhs[channel]
        }
        return false
    }

    private static let transparentColor = CanonicalRGBA(
        red: 0,
        green: 0,
        blue: 0,
        alpha: 0
    )
}
#endif
