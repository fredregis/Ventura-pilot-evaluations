import SwiftUI

struct NewEvaluationView: View {
    @Environment(EvaluationStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var pilotInfo = PilotInfo()
    @State private var evaluationType: EvaluationType = .ioe
    @State private var evaluatorName = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Evaluation Type") {
                    Picker("Type", selection: $evaluationType) {
                        ForEach(EvaluationType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Evaluator") {
                    TextField("Evaluator Name", text: $evaluatorName)
                        .autocorrectionDisabled()
                }

                Section("Pilot Information") {
                    TextField("Last Name", text: $pilotInfo.lastName)
                        .textContentType(.familyName)
                        .autocorrectionDisabled()
                    TextField("First Name", text: $pilotInfo.firstName)
                        .textContentType(.givenName)
                        .autocorrectionDisabled()
                    TextField("M.I.", text: $pilotInfo.middleInitial)
                        .autocorrectionDisabled()
                }

                Section("Position") {
                    Picker("Position", selection: $pilotInfo.position) {
                        ForEach(Position.allCases, id: \.self) { position in
                            Text(position.rawValue).tag(position)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("Aircraft"), footer: Text("Per-leg tail numbers are tracked in the Flight Log. Enter a summary here if known at the start.")) {
                    Picker("Aircraft Type", selection: $pilotInfo.aircraftType) {
                        ForEach(AircraftType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    TextField("N Number(s), e.g. N123AB, N456CD", text: $pilotInfo.nNumbers)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.characters)
                }
            }
            .navigationTitle("New Evaluation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        _ = store.createEvaluation(pilotInfo: pilotInfo, evaluationType: evaluationType, evaluatorName: evaluatorName)
                        dismiss()
                    }
                    .bold()
                    .disabled(pilotInfo.lastName.isEmpty || pilotInfo.firstName.isEmpty)
                }
            }
        }
    }
}
