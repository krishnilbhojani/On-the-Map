//
//  UdacityAPI.swift
//  On the Map
//
//  Created by Krishnil Bhojani on 16/05/20.
//  Copyright © 2020 Krishnil Bhojani. All rights reserved.
//

import Foundation

class OnTheMapAPI {
    
    struct Auth{
        static var sessionId = ""
        static var userId = ""
        static var firstName = ""
        static var lastName = ""
    }
    
    enum Endpoints{
        static let base = "https://onthemap-api.udacity.com/v1"
        
        case session
        case studentLocation
        case signUp
        case getPublicData(String)
        
        var stringValue: String{
            switch self{
            case .studentLocation:
                return Endpoints.base + "/StudentLocation?limit=100&order=-updatedAt"
            case .session:
                return Endpoints.base + "/session"
            case .signUp:
                return "https://auth.udacity.com/sign-up?next=https://classroom.udacity.com/authenticated"
            case .getPublicData(let userId):
                return "https://onthemap-api.udacity.com/v1/users/\(userId)"
            }
        }
        
        var url: URL{
            return URL(string: stringValue)!
        }
    }
    
    class func getStudentsLocation(completion: @escaping ([StudentLocationResponse]?, Error?) -> ()){
        let task = URLSession.shared.dataTask(with: Endpoints.studentLocation.url) { (data, response, error) in
            if let data = data{
                do{
                    let jsonData = try JSONDecoder().decode(Results.self, from: data)
                    DispatchQueue.main.async {
                        completion(jsonData.results, nil)
                    }
                }catch{
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }else{
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    class func taskForPOSTRequest<ResponseType: Decodable>(url: URL, body: Data, response: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> ()){
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data{
                let newData = data.dropFirst(5)
                guard let dataString = String(data: newData, encoding: .utf8) else { return }
                let jsonData = Data(dataString.utf8)

                do {
                    let result = try JSONDecoder().decode(ResponseType.self, from: jsonData)
                    DispatchQueue.main.async {
                        completion(result, nil)
                    }
                }catch{
                    do {
                        let errorResponse = try JSONDecoder().decode(AuthError.self, from: jsonData)
                        DispatchQueue.main.async {
                            completion(nil, errorResponse)
                        }
                    }catch{
                        DispatchQueue.main.async {
                            completion(nil, error)
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    class func postSession(username: String, password: String, completion: @escaping (Bool, Error?) ->()){
        guard let body = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: .utf8) else { return }
        taskForPOSTRequest(url: Endpoints.session.url, body: body, response: SessionResult.self) { (response, error) in
            if let response = response{
                Auth.sessionId = response.session.id
                Auth.userId = response.account.key
                setStudentInformation(userId: Auth.userId)
                completion(true, nil)
            }else{
                completion(false, error)
            }
        }
    }
    
    class func setStudentInformation(userId: String){
        let request = URLRequest(url: Endpoints.getPublicData(userId).url)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                return
            }
            if let newData = data?.dropFirst(5) {
                guard let dataString = String(data: newData, encoding: .utf8) else { return }
                let jsonData = Data(dataString.utf8)
                
                do{
                    let jData = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
                    guard let jsonDict = jData as? NSDictionary else { return }
                    Auth.firstName = jsonDict["first_name"] as! String
                    Auth.lastName = jsonDict["last_name"] as! String
                }catch{
                    print(error)
                }
//                do{
//                    let result = try JSONDecoder().decode(UserData.self, from: jsonData)
//                    Auth.firstName = result.user.firstName
//                    Auth.lastName = result.user.lastName
//                }catch{
//                    print(error)
//                }
            }
        }
        task.resume()
    }
    
    class func deleteSession(completion: @escaping (Bool, Error?) -> ()){
        var request = URLRequest(url: Endpoints.session.url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }else{
                DispatchQueue.main.async {
                    Auth.sessionId = ""
                    Auth.userId = ""
                    Auth.firstName = ""
                    Auth.lastName = ""
                    completion(true, nil)
                }
            }
        }
        task.resume()
    }
    
    class func postStudentLocation(studentLocation: StudentLocationRequest, completion: @escaping (Bool) -> ()){
        var request = URLRequest(url: Endpoints.studentLocation.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(studentLocation.uniqueKey)\", \"firstName\": \"\(studentLocation.firstName)\", \"lastName\": \"\(studentLocation.lastName)\",\"mapString\": \"\(studentLocation.mapString)\", \"mediaURL\": \"\(studentLocation.mediaURL)\",\"latitude\": \(studentLocation.latitude), \"longitude\": \(studentLocation.longitude)}".data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            guard let data = data else{
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            DispatchQueue.main.async {
                completion(true)
            }
            print(String(data: data, encoding: .utf8)!)
        }
        task.resume()
    }
    
}
