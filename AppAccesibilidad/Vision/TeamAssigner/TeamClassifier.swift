import UIKit
import CoreImage

class TeamClassifier {
    
    private let context = CIContext()
    private var kmeans: SimpleKMeans?
    var playerTeamDict: [UUID: Int] = [:]
    
    private var clusterMap: [Int: Int]?

    init() {}
    
    /// Extracts the average color from the *center 50%* of the image, ignoring the border.
    private func extractCenterColor(from crop: CIImage) -> [Double] {
        let extent = crop.extent
        let insetX = extent.width * 0.25
        let insetY = extent.height * 0.25
        let centerRect = extent.insetBy(dx: insetX, dy: insetY)
        
        let extentVector = CIVector(x: centerRect.origin.x,
                                    y: centerRect.origin.y,
                                    z: centerRect.size.width,
                                    w: centerRect.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage",
                                    parameters: [kCIInputImageKey: crop, kCIInputExtentKey: extentVector]),
              let outputImage = filter.outputImage else {
            return [0.0, 0.0, 0.0]
        }

        var bitmap = [UInt8](repeating: 0, count: 4)
        self.context.render(outputImage,
                            toBitmap: &bitmap,
                            rowBytes: 4,
                            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                            format: .RGBA8,
                            colorSpace: nil)
        
        let red = Double(bitmap[0]) / 255.0
        let green = Double(bitmap[1]) / 255.0
        let blue = Double(bitmap[2]) / 255.0
        
        return [red, green, blue]
    }

    // MARK: - Public Methods

    func fit(on crops: [CIImage]) async throws {
        let maxCropsToUse = 2000
        let croppedCrops = crops.prefix(maxCropsToUse)
        print("Fitting TeamClassifier on \(croppedCrops.count) player crops...")
        
        let features = croppedCrops.map { extractCenterColor(from: $0) }
        
        guard features.count > 1 else {
            print("❌ Fit Error: Not enough features collected. Count: \(features.count)")
            throw ClassifierError.notEnoughData
        }
                
        let nClustersToFind = 2
        var kmeans = SimpleKMeans(nClusters: nClustersToFind)
        
        // 1. Run fit and get the assignments for all points
        let assignments = kmeans.fit(points: features)
        
        // 2. Count the number of points in each cluster
        let clusterCounts = Dictionary(grouping: assignments, by: { $0 })
            .mapValues { $0.count }
        
        print("KMeans finished. Cluster counts: \(clusterCounts)")

        // 3. Find the two largest clusters
        let sortedClusters = clusterCounts.sorted { $0.value > $1.value }
        
        guard sortedClusters.count >= 2 else {
            print("❌ Fit Error: Could not find two distinct clusters. Found: \(sortedClusters.count)")
            throw ClassifierError.notEnoughData
        }
        
        // 4. Get the cluster IDs for the top two teams
        let teamAClusterID = sortedClusters[0].key
        let teamBClusterID = sortedClusters[1].key
        
        // 5. Map raw cluster IDs to team IDs (0 and 1)
        self.clusterMap = [
            teamAClusterID: 0,
            teamBClusterID: 1
        ]
        
        // 6. Save the fitted kmeans
        self.kmeans = kmeans
        
        self.playerTeamDict.removeAll()
        print("✅ TeamClassifier fit complete. Mapped teams \(teamAClusterID) -> 0 and \(teamBClusterID) -> 1.")
    }

    func predict(for crop: CIImage, playerID: UUID) async throws -> Int {
        // 1. Check cache
        if let teamID = playerTeamDict[playerID] {
            return teamID
        }
        
        guard let kmeans = self.kmeans, let clusterMap = self.clusterMap else {
            throw ClassifierError.modelNotFitted
        }

        let features = extractCenterColor(from: crop)
        
        // 2. Get the raw cluster ID
        let rawTeamID = kmeans.predict(features)
        
        // 3. Map the raw ID to final team ID (0 or 1)
        guard let finalTeamID = clusterMap[rawTeamID] else {
            throw ClassifierError.noiseDetected
        }
        
        // 4. Cache the final ID
        playerTeamDict[playerID] = finalTeamID
        
        return finalTeamID
    }
    
    enum ClassifierError: Error {
        case modelNotFitted
        case notEnoughData
        case noiseDetected
    }
}
