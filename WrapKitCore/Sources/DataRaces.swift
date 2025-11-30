import Foundation
import Combine

public class CounterViewModel: ObservableObject {
    @Published public var count = 0
    
    public init() {}
    
    public func increment(completion: @escaping (Int) -> Void) {
        // MAIN THREAD
        let newCount = self.count + 1  // Race: Read on background
        self.count = newCount  // Race: Write from multiple threads
        completion(self.count)
    }
}
