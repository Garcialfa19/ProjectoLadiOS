import SwiftUI

struct ScannerLoginView: View {
    @StateObject var viewModel: ScannerLoginViewModel
    let onSignedIn: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Scanner Login") {
                    TextField("Email", text: $viewModel.email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    SecureField("Password", text: $viewModel.password)
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Button {
                        Task {
                            if await viewModel.signIn() {
                                onSignedIn()
                            }
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Sign In")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .navigationTitle("ProjectoLad Scanner")
        }
    }
}
