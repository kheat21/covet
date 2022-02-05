import SwiftUI
import FirebaseUI
import Firebase

public var screenWidth: CGFloat {
    return UIScreen.main.bounds.width
}

public var screenHeight: CGFloat {
    return UIScreen.main.bounds.height
}

struct LoginView : View {
        
    @State private var viewState = CGSize(width: 0, height: screenHeight)
    @State private var MainviewState = CGSize.zero
    
    @State private var showingLogin: Bool = false
    
    var body : some View {
        VStack {
            
            Spacer().frame(height: 64)
            Image("Covet_Logo_Colored")
                .frame(width: nil, height: 92)
            Group {
                Text("Take the ")
                    .font(.system(.headline))
                    .foregroundColor(Color.gray)
                +
                Text("if")
                    .font(.system(.headline))
                    .foregroundColor(Color.covetGreen())
                +
                Text(" out of g")
                    .font(.system(.headline))
                    .foregroundColor(Color.gray)
                +
                Text("if")
                    .font(.system(.headline))
                    .foregroundColor(Color.covetGreen())
                +
                Text("t")
                    .font(.system(.headline))
                    .foregroundColor(Color.gray)
            }
            
            Spacer()
            VStack {
                HStack {
                    Button("Terms of Service", action: {
                        UIApplication.shared.open(
                            URL(string: AppConfig.TERMS_AND_CONDITIONS_LINK)!,
                            options: [:], completionHandler: nil
                        )
                    })
                        .foregroundColor(Color.gray)
                    Button("Privacy Policy", action: {
                        UIApplication.shared.open(
                            URL(string: AppConfig.PRIVACY_POLICY_LINK)!,
                            options: [:], completionHandler: nil
                        )
                    })
                        .foregroundColor(Color.gray)
                }
                Button(
                    action: {
                        self.showingLogin = true
                    },
                    label: {
                        Text("Login")
                            .padding(Edge.Set.vertical, 16)
                            .padding(Edge.Set.horizontal, 52)
                    }
                )
                .background(Color.covetGreen())
                .foregroundColor(Color.white)
                .padding([.bottom], 16.0)
            }
            //.frame(width: .i, height: 52, alignment: .center)
        }
        .sheet(isPresented: $showingLogin, onDismiss: nil, content: {
            CustomLoginViewController { (error) in
                if error == nil {
                    self.status()
                }
            }.offset(y: self.MainviewState.height)
        })
        /*
        ZStack {
            if self.showingLogin {
                CustomLoginViewController { (error) in
                    if error == nil {
                        self.status()
                    }
                }.offset(y: self.MainviewState.height)
            } else {
                Button("Login", action: {
                    self.showingLogin = true
                })
            }
        }
        */
    }
    
    func status() {
        self.viewState = CGSize(width: 0, height: 0)
        self.MainviewState = CGSize(width: 0, height: screenHeight)
    }
}

struct LoginView_Previews : PreviewProvider {
    static var previews : some View {
        LoginView()
    }
}

struct CustomLoginViewController : UIViewControllerRepresentable {
    
    @EnvironmentObject var auth: AuthService
    
    var dismiss : (_ error : Error? ) -> Void
    
    func makeCoordinator() -> CustomLoginViewController.Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController
    {
        let authUI = FUIAuth.defaultAuthUI()
        
        let providers : [FUIAuthProvider] = [
            FUIEmailAuth(),
            FUIGoogleAuth(),
            FUIOAuth.appleAuthProvider()
        ]
        
        authUI?.providers = providers
        authUI?.delegate = context.coordinator
        
        let authViewController = authUI?.authViewController()
        
        return authViewController!
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<CustomLoginViewController>)
    {
        
    }
    
    //coordinator
    class Coordinator : NSObject, FUIAuthDelegate {
        var parent : CustomLoginViewController
        
        init(_ customLoginViewController : CustomLoginViewController) {
            self.parent = customLoginViewController
        }
        
        // MARK: FUIAuthDelegate
        func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?)
        {
            if let error = error {
                print(error)
                parent.dismiss(error)
            }
            else {
                // parent.auth.setLoggedIn()
                parent.dismiss(nil)
            }
        }
        
        
        func authUI(_ authUI: FUIAuth, didFinish operation: FUIAccountSettingsOperationType, error: Error?)
        {
            print(error)
        }
    }
}
