import SwiftUI

struct FollowUsView: View {
    @State private var showingAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading,spacing: 20) {
                // Back button and title
                VStack(alignment: .leading,spacing: 16) {
                    Button(action: {
                        if let topController = UIApplication.shared.windows.first?.rootViewController {
                            (topController as! UINavigationController).popViewController(animated: true)
                                       }
                    }) {
                        Image("back_black")
                    }
                    Text(LocalizedStringEnum.followUsText.localized)
                        .font(.system(size: 20))

                }
                
                // Facebook Section
                SectionHeader(icon: "ic_facebook", title: "Facebook")
                SocialMediaSection(
                    accounts: [
                        ("English", "nthLink VPN", "https://www.facebook.com/profile.php?id=61560873763629"),
                        ("中文", "CNnthLink", "https://www.facebook.com/CNnthLink"),
                        ("NthLinkIR", "فارسی", "https://www.facebook.com/NthLinkIR/"),
                        ("Русский", "NthLinkRU", "https://www.facebook.com/NthLinkRU/"),
                        ("မြန်မာ", "NthLinkMM", "https://www.facebook.com/NthLinkMM/"),
                        ("Español", "NthLinkES", "https://www.facebook.com/NthlinkES/")
                    ]
                )
                
                // Instagram Section
                SectionHeader(icon: "ic_instagram", title: "Instagram")
                SocialMediaSection(
                    accounts: [
                        ("English", "nthlink_vpn", "https://www.instagram.com/nthlink_vpn/"),
                        ("中文", "cn_nthlink", "https://www.instagram.com/cn_nthlink/"),
                        ("ir_nthlink", "فارسی", "https://www.instagram.com/ir_nthlink/"),
                        ("Русский", "ru_nthlink", "https://www.instagram.com/ru_nthlink/"),
                        ("မြန်မာ", "mm_nthlink", "https://www.instagram.com/mm_nthlink/"),
                        ("Español", "es_nthlink", "https://www.instagram.com/es_nthlink/")
                    ]
                )
                
                // YouTube and Telegram Section
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image("ic_youtube")
                        Text("YouTube: @nthLinkApp")
                        Spacer()
                        Button(action: {
                            if let url = URL(string: "https://www.youtube.com/@nthLinkApp") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Text(LocalizedStringEnum.visitButtonText.localized)
                                .foregroundColor(.white)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 20)
                                .background(AppColors.appBlueColor_swiftUI)
                                .cornerRadius(5)
                        }
                    }
                    .padding(.horizontal)
                    Spacer(minLength: 1)
                    HStack {
                        Image("ic_telegram")
                        Text("Telegram ID: @nthLinkVPN").padding(.trailing)
                        Button(action: {
                            UIPasteboard.general.string = "@nthLinkVPN"
                            self.showingAlert = true
                            
                        }) {
                            Image("ic_copy")
                        }.alert(isPresented: $showingAlert) {
                            Alert(title: Text(LocalizedStringEnum.copiedText.localized), message: Text(LocalizedStringEnum.telegramIdCopiedAlert.localized), dismissButton: .default(Text( LocalizedStringEnum.OK.localized)))
                        }

                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .background(Color.white)
                .cornerRadius(10)
            }
            .padding()
            .background(AppColors.appCreamColor_swiftUI)
            .preferredColorScheme(.light)
        }
       
    }
}

struct SectionHeader: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(icon)
            Text(title)
                .font(.headline)
        }
    }
}

struct SocialMediaSection: View {
    let accounts: [(language: String, accountName: String, url: String)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(accounts, id: \.accountName) { account in
                HStack {
                    Text("\(account.language): \(account.accountName)")
                    Spacer()
                    Button(action: {
                        if let url = URL(string: account.url) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text(LocalizedStringEnum.visitButtonText.localized)
                            .foregroundColor(.white)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 20)
                            .background(AppColors.appBlueColor_swiftUI)
                            .cornerRadius(5)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
}

struct FollowUsView_Previews: PreviewProvider {
    static var previews: some View {
        FollowUsView()
    }
}



