//
//  MultipartFormDataRequest.swift
//  SmartAccess
//
//  Created by Vamshirkishna on 11/04/25.
//
import Foundation

struct MultipartFormDataRequest {
    let boundary: String
    private var httpBody = Data()
    
    init() {
        boundary = "Boundary-\(UUID().uuidString)"
    }
    
    mutating func addTextField(named name: String, value: String) {
        httpBody.append(string: "--\(boundary)\r\n")
        httpBody.append(string: "Content-Disposition: form-data; name=\"\(name)\"\r\n")
        httpBody.append(string: "\r\n")
        httpBody.append(string: "\(value)\r\n")
    }
    
    mutating func addFileField(named name: String, fileURL: URL) throws {
        let fileData = try Data(contentsOf: fileURL)
        httpBody.append(string: "--\(boundary)\r\n")
        httpBody.append(string: "Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileURL.lastPathComponent)\"\r\n")
        httpBody.append(string: "Content-Type: \(contentType(for: fileURL))\r\n")
        httpBody.append(string: "\r\n")
        httpBody.append(fileData)
        httpBody.append(string: "\r\n")
    }
    
    private func contentType(for fileURL: URL) -> String {
        let fileExtension = fileURL.pathExtension.lowercased()
        
        switch fileExtension {
        case "jpg", "jpeg": return "image/jpeg"
        case "png": return "image/png"
        case "pdf": return "application/pdf"
        default: return "application/octet-stream"
        }
    }
    
    func finalize() -> Data {
        var finalData = httpBody
        finalData.append(string: "--\(boundary)--\r\n")
        return finalData
    }
}

// Helper extension for Data to append strings
extension Data {
    mutating func append(string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

