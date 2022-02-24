//
//  StoreConfigRequest.swift
//  wbec
//
//  Created by Andreas Miketta on 24.02.22.
//

import Foundation


//POST /edit HTTP/1.1
//Host: wbec
//Content-Length: 339
//User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Safari/537.36
//Content-Type: multipart/form-data; boundary=----WebKitFormBoundaryd20nGv9szhkCfOyl
//Accept: */*
//Origin: http://wbec
//Referer: http://wbec/edit
//Accept-Encoding: gzip, deflate
//Accept-Language: de-DE,de;q=0.9,en-US;q=0.8,en;q=0.7
//Connection: keep-alive
//
//------WebKitFormBoundaryd20nGv9szhkCfOyl
//Content-Disposition: form-data; name="data"; filename="cfg.json"
//Content-Type: text/json
//
//{"cfgApSsid":"wbec","cfgApPass":"wbec1234","cfgCntWb":1,"cfgMqttIp":"","cfgPvCycleTime":15,"cfgPvActive":1,"cfgMqttLp":[], "cfgSolarEdgeIp": "192.168.178.68"}
//------WebKitFormBoundaryd20nGv9szhkCfOyl--

class NetworkManager: NSObject {
    
    static let shared = NetworkManager()
    
    private override init() {}
    
    func loadConfigFile(filename: String) async throws -> WbecConfiguration {
        let uploadApiUrl: URL? = URL(string: "http://wbec/edit?edit=\(filename)")
        let urlRequest = URLRequest(url: uploadApiUrl!)
        
        let (data, _) = try await URLSession.shared.data(for:urlRequest)
        
        return try JSONDecoder().decode(WbecConfiguration.self, from: data)
    }
    
    func uploadConfigFile (filename: String, name: String = "data", contentType: String = "text/json",
        configFileData: Data) async throws -> (Data, URLResponse) {
            let uploadApiUrl: URL? = URL(string: "http://wbec/edit")
        
            // Generate a unique boundary string using a UUID.
            let uniqueBoundary = UUID().uuidString

            var bodyData = Data()
            
            // Add the multipart/form-data raw http body data.
            bodyData.append("--\(uniqueBoundary)\r\n".data(using: .utf8)!)
            bodyData.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
            bodyData.append("Content-Type: \(contentType)\r\n\r\n".data(using: .utf8)!)
            
            // Add the zip file data to the raw http body data.
            bodyData.append(configFileData)
    
            // End the multipart/form-data raw http body data.
            bodyData.append("\r\n--\(uniqueBoundary)--\r\n".data(using: .utf8)!)
            
            var urlRequest = URLRequest(url: uploadApiUrl!)
            urlRequest.setValue("multipart/form-data; boundary=\(uniqueBoundary)", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("http://wbec", forHTTPHeaderField: "Origin")
            urlRequest.setValue("http://wbec/edit", forHTTPHeaderField: "Referer")
            // Set Content-Type Header to multipart/form-data with the unique boundary.
           
            
            urlRequest.httpMethod = "POST"
            
        let (data, urlResponse) = try await URLSession.shared.upload(
                for: urlRequest,
                from: bodyData,
                delegate: nil
            )

            return (data, urlResponse)
    }
}

extension NetworkManager: URLSessionTaskDelegate {
    
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64) {
        
        print("fractionCompleted  : \(Int(Float(totalBytesSent) / Float(totalBytesExpectedToSend) * 100))")
            
    }
    
}
