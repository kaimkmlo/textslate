//
//  TranslateAPI.swift
//  Textslate
//
//  Created by Kaiming Lo on 10/26/20.
//

import Foundation

enum TranslationAPI {
    case detectLanguage
    case translate
    case supportedLanguages
    
    func getURL() -> String {
            var urlString = ""
            
            switch self {
            case .detectLanguage:
                urlString = "https://translation.googleapis.com/language/translate/v2/detect"
                
            case .translate:
                urlString = "https://translation.googleapis.com/language/translate/v2"
                
            case .supportedLanguages:
                urlString = "https://translation.googleapis.com/language/translate/v2/languages"
            }
            
            return urlString
        }
        
        
        func getHTTP() -> String {
            if self == .supportedLanguages {
                return "GET"
            } else {
                return "POST"
            }
        }
    
}

class TranslateAPI: NSObject{
    
    static let apiManager = TranslateAPI()
    private let apiKey = "AIzaSyDfyrDy_uxqn9ZTKzALUR1RXMT8O14YXTo"
    var text: String?
    var languageCode: String?
    var sourceLanguageCode: String? = "en"
    
    
    override init() {
            super.init()
        }
    
    
    private func makeRequest(usingTranslationAPI api: TranslationAPI, urlParams: [String: String], completion: @escaping (_ results: [String: Any]?) -> Void) {
        
        print("request running")
        
            if var components = URLComponents(string: api.getURL()) {
                components.queryItems = [URLQueryItem]()
                
                for (key, value) in urlParams {
                    components.queryItems?.append(URLQueryItem(name: key, value: value))
                }
                
                
                if let url = components.url {
                    var request = URLRequest(url: url)
                    print(url)
                    request.httpMethod = api.getHTTP()
                    
                    
                    _ = URLSession(configuration: .default)
                    let task = URLSession.shared.dataTask(with: request) { (results, response, error) in
                        
                        if let error = error {
                            print(error,"error1")
                            completion(nil)
                        } else {
                            if let response = response as? HTTPURLResponse, let results = results {
                                if response.statusCode == 200 || response.statusCode == 201 {
                                    print("\(response.statusCode)")
                                    do {
                                        if let resultsDict = try JSONSerialization.jsonObject(with: results, options: JSONSerialization.ReadingOptions.mutableLeaves) as? [String: Any] {
                                            completion(resultsDict)
                                        }
                                    } catch {
                                        print(error.localizedDescription)
                                        print("error2")
                                    }
                                }else{print("\(response.statusCode)")
                                    print("\(response)")
                                }
                            } else {
                                completion(nil)
                                print("error3")
                            }
                        }
                    
                    }
                    
                    task.resume()
                }
            }
        
            print("request done running")
        }
    
    
    func translate(completion: @escaping (_ translations: String?) -> Void) {
            guard let textToTranslate = text, let targetLanguage = languageCode else { completion(nil); return }
            
            print("translate running")
        
            var urlParams = [String: String]()
            urlParams["key"] = apiKey
            urlParams["q"] = textToTranslate
            urlParams["target"] = targetLanguage
            urlParams["format"] = "text"
            
            if let sourceLanguage = sourceLanguageCode {
                urlParams["source"] = sourceLanguage
            }
            
            
            makeRequest(usingTranslationAPI: .translate, urlParams: urlParams) { (results) in
                guard let results = results else { completion(nil); print("error no results"); return }
                
                print("request completion running")
                
                if let data = results["data"] as? [String: Any], let translations = data["translations"] as? [[String: Any]] {
                    var allTranslations = [String]()
                    for translation in translations {
                        if let translatedText = translation["translatedText"] as? String {
                            allTranslations.append(translatedText)
                        }
                    }
                    
                    if allTranslations.count > 0 {
                        completion(allTranslations[0])
                        print("allTranslations.count>0")
                    } else {
                        completion(nil)
                        print("allTranslations.count<=0")
                    }
                    
                    
                } else {
                    completion(nil)
                    print("error4")
                }
            }
    
    
    
    
    
    }
}





