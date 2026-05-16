import SwiftUI

struct SignatureView: View {
    let title: String
    let onSave: (Data) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var lines: [[CGPoint]] = []
    @State private var canvasSize: CGSize = .zero

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Text("Sign below")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)

                Canvas { context, size in
                    for line in lines {
                        guard line.count > 1 else { continue }
                        var path = Path()
                        path.addLines(line)
                        context.stroke(path, with: .color(.primary), lineWidth: 2.5)
                    }
                }
                .onGeometryChange(for: CGSize.self) { proxy in
                    proxy.size
                } action: { newSize in
                    canvasSize = newSize
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let point = value.location
                            if value.translation == .zero {
                                lines.append([point])
                            } else if !lines.isEmpty {
                                lines[lines.count - 1].append(point)
                            }
                        }
                )
                .background(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.separator), lineWidth: 1)
                )
                .padding()

                Button("Clear") {
                    lines.removeAll()
                }
                .foregroundStyle(.red)
                .padding(.bottom)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        if let data = renderSignature() {
                            onSave(data)
                        }
                        dismiss()
                    }
                    .bold()
                    .disabled(lines.isEmpty)
                }
            }
        }
    }

    private func renderSignature() -> Data? {
        let outputSize = CGSize(width: 400, height: 150)
        guard canvasSize.width > 0, canvasSize.height > 0 else { return nil }
        let scaleX = outputSize.width / canvasSize.width
        let scaleY = outputSize.height / canvasSize.height

        let renderer = UIGraphicsImageRenderer(size: outputSize)
        let image = renderer.image { ctx in
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(2.5)
            ctx.cgContext.setLineCap(.round)
            ctx.cgContext.setLineJoin(.round)

            for line in lines {
                guard line.count > 1 else { continue }
                ctx.cgContext.beginPath()
                ctx.cgContext.move(to: CGPoint(x: line[0].x * scaleX, y: line[0].y * scaleY))
                for point in line.dropFirst() {
                    ctx.cgContext.addLine(to: CGPoint(x: point.x * scaleX, y: point.y * scaleY))
                }
                ctx.cgContext.strokePath()
            }
        }
        return image.pngData()
    }
}

struct SignatureDisplayView: View {
    let label: String
    let signatureData: Data?
    let signatureDate: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            if let data = signatureData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            if let date = signatureDate {
                Text(date, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
