//
//  String+Extensions.swift
//  WrapKit
//
//  Created by Stanislav Li on 11/12/23.
//

import Foundation

public extension String {
    static let post = "POST"
    static let patch = "PATCH"
    static let put = "PUT"
    static let get = "GET"
    static let delete = "DELETE"
}

public extension Optional where Wrapped == String {
    var isEmpty: Bool {
        guard let self else { return true }
        return self.isEmpty
    }
}

public extension String {
    var asHtmlAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
                
        return try? NSAttributedString(
            data: data,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ],
            documentAttributes: nil
        )
    }
    
    func asDate(withFormat format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
}
