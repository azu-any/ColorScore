import Foundation
import Accelerate

/// A simple, self-contained KMeans implementation.
struct SimpleKMeans {
    let nClusters: Int
    let maxIterations: Int
    private(set) var clusterCenters: [[Double]] = []

    init(nClusters: Int, maxIterations: Int = 10) {
        self.nClusters = nClusters
        self.maxIterations = maxIterations
    }

    /// Finds the *squared* Euclidean distance between two n-dimensional points.
    private func distance(from p1: [Double], to p2: [Double]) -> Double {
        var difference = [Double](repeating: 0.0, count: p1.count)
        // We use vDSP to calculate (p1 - p2)
        vDSP_vsubD(p2, 1, p1, 1, &difference, 1, vDSP_Length(p1.count))
        
        // Then we calculate the dot product of the difference with itself:
        // (p1-p2) • (p1-p2), which is the squared distance.
        var squaredDistance: Double = 0.0
        vDSP_dotprD(difference, 1, difference, 1, &squaredDistance, vDSP_Length(p1.count))
        
        return squaredDistance
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
    // --- MODIFIED: This function now returns the final assignments ---
    mutating func fit(points: [[Double]]) -> [Int] {
        guard points.count >= nClusters, let firstPoint = points.first else { return [] }

        let d = firstPoint.count
        
        // --- MODIFIED: Initialize using K-Means++ ---
        clusterCenters = initCentersKMeansPlusPlus(points: points)

        var assignments = [Int](repeating: -1, count: points.count)
        
        for _ in 0..<maxIterations {
            
            // 2. Assign each point to the nearest cluster (in parallel).
            DispatchQueue.concurrentPerform(iterations: points.count) { i in
                assignments[i] = predict(points[i])
            }

            // 3. Group the assignments
            let clusters = Dictionary(grouping: 0..<points.count, by: { assignments[$0] })

            // 4. Recalculate the center of each cluster.
            var newCenters: [[Double]] = []
            for i in 0..<nClusters {
                let clusterIndices = clusters[i, default: []]
                
                if let newCenter = calculateCenter(for: clusterIndices.map { points[$0] }, dimensions: d) {
                    newCenters.append(newCenter)
                } else {
                    // If a cluster is empty, keep its old center (or re-initialize)
                    newCenters.append(clusterCenters[i])
                }
            }
            
            // 5. Check for convergence
            if newCenters == clusterCenters { break }
            clusterCenters = newCenters
        }
        
        // --- MODIFIED: Return the final assignments ---
        return assignments
    }
    
    /// Calculates the average point (center) of a cluster using vDSP.
    private func calculateCenter(for points: [[Double]], dimensions: Int) -> [Double]? {
        guard !points.isEmpty else { return nil }

        var sum = [Double](repeating: 0.0, count: dimensions)
        for point in points {
            vDSP_vaddD(sum, 1, point, 1, &sum, 1, vDSP_Length(dimensions))
        }

        var count = Double(points.count)
        var newCenter = [Double](repeating: 0.0, count: dimensions)
        vDSP_vsdivD(sum, 1, &count, &newCenter, 1, vDSP_Length(dimensions))
        
        return newCenter
    }
    
    // --- THIS IS NEW ---
    /// Initializes cluster centers using the K-Means++ algorithm.
    private func initCentersKMeansPlusPlus(points: [[Double]]) -> [[Double]] {
        var centers: [[Double]] = []

        // 1. Pick the first center randomly
        guard let firstCenter = points.randomElement() else { return [] }
        centers.append(firstCenter)

        // 2. Pick the remaining k-1 centers
        for _ in 1..<nClusters {
            var distances: [Double] = []
            
            // For each point, find the squared distance to its *nearest* already-chosen center
            for point in points {
                var minDistance = Double.greatestFiniteMagnitude
                for center in centers {
                    let dist = distance(from: point, to: center) // Our distance is already squared
                    if dist < minDistance {
                        minDistance = dist
                    }
                }
                distances.append(minDistance)
            }

            // 3. Pick the next center with probability proportional to D(x)^2
            let totalDistance = distances.reduce(0, +)
            if totalDistance == 0 {
                // All points are identical to existing centers.
                // Just pick another random point to ensure we get nClusters.
                if let randomPoint = points.randomElement() {
                    centers.append(randomPoint)
                }
                continue // Go to the next iteration of the for loop
            }
            
            let randomValue = Double.random(in: 0...totalDistance)
            var cumulativeDistance: Double = 0
            
            for (i, distance) in distances.enumerated() {
                cumulativeDistance += distance
                if cumulativeDistance >= randomValue {
                    centers.append(points[i])
                    break
                }
            }
        }
        return centers
    }
}

//import Foundation
//import Accelerate
//
//// A simple, self-contained KMeans implementation.
//struct SimpleKMeans {
//    let nClusters: Int
//    let maxIterations: Int
//    private(set) var clusterCenters: [[Double]] = []
//
//    init(nClusters: Int, maxIterations: Int = 100) {
//        self.nClusters = nClusters
//        self.maxIterations = maxIterations
//    }
//
//    /// Finds the distance between two points (colors).
//    private func distance(from p1: [Double], to p2: [Double]) -> Double {
//        // We use vDSP to calculate (p1 - p2)
//        var difference = [Double](repeating: 0.0, count: p1.count)
//        vDSP_vsubD(p2, 1, p1, 1, &difference, 1, vDSP_Length(p1.count))
//        
//        // Then we calculate the dot product of the difference with itself:
//        // (p1-p2) • (p1-p2), which is the squared distance.
//        var squaredDistance: Double = 0.0
//        vDSP_dotprD(difference, 1, difference, 1, &squaredDistance, vDSP_Length(p1.count))
//        
//        return squaredDistance
//    }
//
//    /// Finds the closest cluster center for a given point.
//    func predict(_ point: [Double]) -> Int {
//        // This logic is simple and already fast. No changes needed.
//        var minDistance = Double.greatestFiniteMagnitude
//        var closestCluster = -1
//        for (i, center) in clusterCenters.enumerated() {
//            let dist = distance(from: point, to: center)
//            if dist < minDistance {
//                minDistance = dist
//                closestCluster = i
//            }
//        }
//        return closestCluster
//    }
//
//    /// Clusters the points and finds the center for each cluster.
//    mutating func fit(points: [[Double]]) {
//        guard points.count >= nClusters, let firstPoint = points.first else { return }
//
//        // Get the dimensionality of our data
//        let d = firstPoint.count
//        
//        // 1. Initialize cluster centers randomly.
//        clusterCenters = initCentersKMeansPlusPlus(points: points)
//        
//        // We need a place to store the assignments for each point.
//        var assignments = [Int](repeating: -1, count: points.count)
//        
//        for _ in 0..<maxIterations {
//            
//            // 2. Assign each point to the nearest cluster (in parallel).
//            DispatchQueue.concurrentPerform(iterations: points.count) { i in
//                let point = points[i]
//                let clusterIndex = predict(point)
//                assignments[i] = clusterIndex
//            }
//
//            // 3. Group the assignments
//            // This cleanly groups all indices by their assigned cluster
//            let clusters = Dictionary(grouping: 0..<points.count, by: { assignments[$0] })
//
//            // 4. Recalculate the center of each cluster.
//            var newCenters: [[Double]] = []
//            for i in 0..<nClusters {
//                // Get the point indices for this cluster, or an empty array
//                let clusterIndices = clusters[i, default: []]
//                
//                if let newCenter = calculateCenter(for: clusterIndices.map { points[$0] }, dimensions: d) {
//                    newCenters.append(newCenter)
//                } else {
//                    // If a cluster is empty, keep its old center.
//                    newCenters.append(clusterCenters[i])
//                }
//            }
//            
//            // 5. Check for convergence
//            if newCenters == clusterCenters { break }
//            clusterCenters = newCenters
//        }
//    }
//    
//    /// Calculates the average point (center) of a cluster using vDSP.
//    private func calculateCenter(for points: [[Double]], dimensions: Int) -> [Double]? {
//        guard !points.isEmpty else { return nil }
//
//        // Create a sum vector initialized to zero
//        var sum = [Double](repeating: 0.0, count: dimensions)
//        
//        // Sum all vectors in the cluster
//        for point in points {
//            // sum = sum + point
//            vDSP_vaddD(sum, 1, point, 1, &sum, 1, vDSP_Length(dimensions))
//        }
//
//        // Divide the sum vector by the number of points
//        var count = Double(points.count)
//        var newCenter = [Double](repeating: 0.0, count: dimensions)
//        vDSP_vsdivD(sum, 1, &count, &newCenter, 1, vDSP_Length(dimensions))
//        
//        return newCenter
//    }
//    
//    /// Initializes cluster centers using the K-Means++ algorithm.
//    private func initCentersKMeansPlusPlus(points: [[Double]]) -> [[Double]] {
//        var centers: [[Double]] = []
//
//        // 1. Pick the first center randomly
//        guard let firstCenter = points.randomElement() else { return [] }
//        centers.append(firstCenter)
//
//        // 2. Pick the remaining k-1 centers
//        for _ in 1..<nClusters {
//            var distances: [Double] = []
//
//            // For each point, find the squared distance to its *nearest* already-chosen center
//            for point in points {
//                var minDistance = Double.greatestFiniteMagnitude
//                for center in centers {
//                    let dist = distance(from: point, to: center) // Assumes this is squared distance
//                    if dist < minDistance {
//                        minDistance = dist
//                    }
//                }
//                distances.append(minDistance)
//            }
//
//            // 3. Pick the next center with probability proportional to D(x)^2
//            let totalDistance = distances.reduce(0, +)
//            guard totalDistance > 0 else { continue } // Avoid division by zero
//
//            let randomValue = Double.random(in: 0...totalDistance)
//            var cumulativeDistance: Double = 0
//
//            for (i, distance) in distances.enumerated() {
//                cumulativeDistance += distance
//                if cumulativeDistance >= randomValue {
//                    centers.append(points[i])
//                    break
//                }
//            }
//        }
//        return centers
//    }
//}
