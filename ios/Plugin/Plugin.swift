import Foundation
import Capacitor

import MSAL
/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitor.ionicframework.com/docs/plugins/ios
 */
@objc(azureAppDelegate)
public class azureAppDelegate: CAPPlugin {
    
    // Update the below to your client ID you received in the portal. The below is for running the demo only
       let kClientID = "16546c77-4e85-450e-8cc8-0049c57be748"
       
       // Additional variables for Auth and Graph API
       let kGraphURI = "https://graph.microsoft.com/v1.0/me/"
       let kScopes: [String] = ["https://graph.microsoft.com/user.read"]
       let kAuthority = "https://login.microsoftonline.com/2ffc2ede-4d44-4994-8082-487341fa43fb"
       
       var accessToken = String()
       var applicationContext : MSALPublicClientApplication?
       var webViewParamaters : MSALWebviewParameters?

       var loggingText: UITextView!
       var signOutButton: UIButton!
       var callGraphButton: UIButton!

      
    @objc func initMSAL(_ call: CAPPluginCall) {
      do {
          try self.initMSAL()
      } catch let error {
          print("Unable to create Application Context \(error)")
      }
        
    }
    
    @objc func getToken(_ call: CAPPluginCall) {
        do {
                 try self.initMSAL()
            try self.callGraphAPI()
             } catch let error {
                 print("Unable to create Application Context \(error)")
             }
    }
    
}

extension azureAppDelegate {
    
 
    func initMSAL() throws {
        
        guard let authorityURL = URL(string: kAuthority) else {
          
            print("Unable to create authority URL");
            return
        }
        
        let authority = try MSALAADAuthority(url: authorityURL)
        
        let msalConfiguration = MSALPublicClientApplicationConfig(clientId: kClientID, redirectUri: nil, authority: authority)
        self.applicationContext = try MSALPublicClientApplication(configuration: msalConfiguration)
        
        
    }
    @objc func callGraphAPI() {
          
          guard let currentAccount = self.currentAccount() else {
              // We check to see if we have a current logged in account.
              // If we don't, then we need to sign someone in.
              acquireTokenInteractively()
              return
          }
          
          acquireTokenSilently(currentAccount)
      }
    
    
    func acquireTokenInteractively() {
           
           guard let applicationContext = self.applicationContext else { return }
           guard let webViewParameters = self.webViewParamaters else { return }

           let parameters = MSALInteractiveTokenParameters(scopes: kScopes, webviewParameters: webViewParameters)
           parameters.promptType = .selectAccount;
           
           applicationContext.acquireToken(with: parameters) { (result, error) in
               
               if let error = error {
                   
                   print( "Could not acquire token: \(error)")
                   return
               }
               
               guard let result = result else {
                   
                   print( "Could not acquire token: No result returned")
                   return
               }
               
               self.accessToken = result.accessToken
               print( "Access token is \(self.accessToken)")
              
               self.getContentWithToken()
           }
       }
       
       func acquireTokenSilently(_ account : MSALAccount!) {
           
           guard let applicationContext = self.applicationContext else { return }
           
           /**
            
            Acquire a token for an existing account silently
            
            - forScopes:           Permissions you want included in the access token received
            in the result in the completionBlock. Not all scopes are
            guaranteed to be included in the access token returned.
            - account:             An account object that we retrieved from the application object before that the
            authentication flow will be locked down to.
            - completionBlock:     The completion block that will be called when the authentication
            flow completes, or encounters an error.
            */
           
           let parameters = MSALSilentTokenParameters(scopes: kScopes, account: account)
           
           applicationContext.acquireTokenSilent(with: parameters) { (result, error) in
               
               if let error = error {
                   
                   let nsError = error as NSError
                   
                   // interactionRequired means we need to ask the user to sign-in. This usually happens
                   // when the user's Refresh Token is expired or if the user has changed their password
                   // among other possible reasons.
                   
                   if (nsError.domain == MSALErrorDomain) {
                       
                       if (nsError.code == MSALError.interactionRequired.rawValue) {
                           
                           DispatchQueue.main.async {
                               self.acquireTokenInteractively()
                           }
                           return
                       }
                   }
                   
                   print( "Could not acquire token silently: \(error)")
                   return
               }
               
               guard let result = result else {
                   
                   print( "Could not acquire token: No result returned")
                   return
               }
               
               self.accessToken = result.accessToken
               print( "Refreshed Access token is \(self.accessToken)")
               
               self.getContentWithToken()
           }
       }
       
       /**
        This will invoke the call to the Microsoft Graph API. It uses the
        built in URLSession to create a connection.
        */
       
       func getContentWithToken() {
           
           // Specify the Graph API endpoint
           let url = URL(string: kGraphURI)
           var request = URLRequest(url: url!)
           
           // Set the Authorization header for the request. We use Bearer tokens, so we specify Bearer + the token we got from the result
           request.setValue("Bearer \(self.accessToken)", forHTTPHeaderField: "Authorization")
           
           URLSession.shared.dataTask(with: request) { data, response, error in
               
               if let error = error {
                   print( "Couldn't get graph result: \(error)")
                   return
               }
               
               guard let result = try? JSONSerialization.jsonObject(with: data!, options: []) else {
                   
                   print( "Couldn't deserialize result JSON")
                   return
               }
               
               print( "Result from Graph: \(result))")
               
               }.resume()
       }
    
    
}


extension azureAppDelegate {
    func currentAccount() -> MSALAccount? {
        
        guard let applicationContext = self.applicationContext else { return nil }
        
        // We retrieve our current account by getting the first account from cache
        // In multi-account applications, account should be retrieved by home account identifier or username instead
        
        do {
            
            let cachedAccounts = try applicationContext.allAccounts()
            
            if !cachedAccounts.isEmpty {
                return cachedAccounts.first
            }
            
        } catch let error as NSError {
            
            print("Didn't find any accounts in cache: \(error)")
        }
        
        return nil
    }
    
  
}

