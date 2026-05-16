import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var logoOpacity = 0.0
    @State private var titleOpacity = 0.0

    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                Color.white
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    Image("VenturaLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 360)
                        .opacity(logoOpacity)

                    Text("Pilot Evaluations")
                        .font(.title2.weight(.medium))
                        .foregroundStyle(Color(red: 0.11, green: 0.16, blue: 0.33))
                        .opacity(titleOpacity)
                }
                .padding(40)
            }
            .onAppear {
                withAnimation(.easeIn(duration: 0.8)) {
                    logoOpacity = 1.0
                }
                withAnimation(.easeIn(duration: 0.8).delay(0.4)) {
                    titleOpacity = 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isActive = true
                    }
                }
            }
        }
    }
}
