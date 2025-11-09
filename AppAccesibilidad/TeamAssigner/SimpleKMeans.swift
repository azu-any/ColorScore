import Foundation

// A simple, self-contained KMeans implementation.
struct SimpleKMeans {
    let nClusters: Int
    let maxIterations: Int
    private(set) var clusterCenters: [[Double]] = []

    init(nClusters: Int, maxIterations: Int = 10) {
        self.nClusters = nClusters
        self.maxIterations = maxIterations
    }

    /// Finds the distance between two points (colors).
    private func distance(from p1: [Double], to p2: [Double]) -> Double {
        let r_dist = p1[0] - p2[0]
        let g_dist = p1[1] - p2[1]
        let b_dist = p1[2] - p2[2]
        return r_dist*r_dist + g_dist*g_dist + b_dist*b_dist
    }

    /// Finds the closest cluster center for a given point.
    func predict(_ point: [Double]) -> Int {
        var minDistance = Double.greatestFiniteMagnitude
        var closestCluster = -1
        for (i, center) in clusterCenters.enumerated() {
            let dist = distance(from: point, to: center)
            if dist < minDistance {
                minDistance = dist
                closestCluster = i
            }
        }
        return closestCluster
    }

    /// Clusters the points and finds the center for each cluster.
    mutating func fit(points: [[Double]]) {
        guard points.count >= nClusters else { return }

        // 1. Initialize cluster centers randomly from the data points.
        clusterCenters = Array(points.shuffled().prefix(nClusters))

        for _ in 0..<maxIterations {
            var clusters: [[Int]] = Array(repeating: [], count: nClusters)

            // 2. Assign each point to the nearest cluster.
            for (i, point) in points.enumerated() {
                let clusterIndex = predict(point)
                clusters[clusterIndex].append(i)
            }

            // 3. Recalculate the center of each cluster.
            var newCenters: [[Double]] = []
            for i in 0..<nClusters {
                let clusterPoints = clusters[i].map { points[$0] }
                if let newCenter = calculateCenter(for: clusterPoints) {
                    newCenters.append(newCenter)
                } else {
                    // If a cluster is empty, keep its old center.
                    newCenters.append(clusterCenters[i])
                }
            }
            
            // If centers haven't changed, we've converged.
            if newCenters == clusterCenters { break }
            clusterCenters = newCenters
        }
    }
    
    /// Calculates the average point (center) of a cluster.
    private func calculateCenter(for points: [[Double]]) -> [Double]? {
        guard !points.isEmpty else { return nil }
        var sum: [Double] = [0.0, 0.0, 0.0]
        for point in points {
            sum[0] += point[0]
            sum[1] += point[1]
            sum[2] += point[2]
        }
        let count = Double(points.count)
        return [sum[0] / count, sum[1] / count, sum[2] / count]
    }
}
