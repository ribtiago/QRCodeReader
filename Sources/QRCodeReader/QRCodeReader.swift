import SwiftUI
import SwiftUIExtras

struct QRCodeReader: View {
    
    @ObservedObject private var viewModel = QRCodeReaderViewModel()
    var receivedResult: (String) -> Void
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            self.viewModel.cameraPreview
                .ignoresSafeArea()
            
            if self.viewModel.isTorchEnable {
                Toggle(isOn: self.$viewModel.isTorchOn) {
                    Image(systemName: self.viewModel.isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                        .frame(width: 20, height: 20)
                }
                .toggleStyle(.overlay)
                .padding(30)
            }
        }
        .onReceive(self.viewModel.result) {
            self.receivedResult($0)
        }
        .onAppear {
            self.viewModel.startCapturing()
        }
        .onDisappear {
            self.viewModel.stopCapturing()
        }
    }
}

#if DEBUG
struct QRCodeReader_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeReader { _ in
            
        }
    }
}
#endif
