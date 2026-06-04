import SwiftUI
import UIKit
import PDFKit

struct PDFGenerator {
    static func generate(for evaluation: Evaluation) -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let margin: CGFloat = 36

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        return renderer.pdfData { context in
            context.beginPage()
            drawPage1(context: context.cgContext, rect: pageRect, margin: margin, evaluation: evaluation)

            context.beginPage()
            drawPage2(context: context.cgContext, rect: pageRect, margin: margin, evaluation: evaluation)

            context.beginPage()
            drawPage3(context: context.cgContext, rect: pageRect, margin: margin, evaluation: evaluation)
        }
    }

    // MARK: - Page 1: Evaluation Grid

    private static func drawPage1(context: CGContext, rect: CGRect, margin: CGFloat, evaluation: Evaluation) {
        let contentWidth = rect.width - margin * 2
        let headerFont = UIFont.boldSystemFont(ofSize: 16)
        let sectionTitleFont = UIFont.boldSystemFont(ofSize: 8)
        let bodyFont = UIFont.systemFont(ofSize: 7.5)
        let smallBoldFont = UIFont.boldSystemFont(ofSize: 7)
        let smallFont = UIFont.systemFont(ofSize: 6.5)

        var y = drawPageHeader(rect: rect, margin: margin)

        // Title
        let title = "Pilot Evaluation Worksheet"
        let titleAttr: [NSAttributedString.Key: Any] = [.font: headerFont]
        let titleSize = title.size(withAttributes: titleAttr)
        title.draw(at: CGPoint(x: (rect.width - titleSize.width) / 2, y: y), withAttributes: titleAttr)

        let pageLabel = "Page 1 of 3"
        let pageLabelAttr: [NSAttributedString.Key: Any] = [.font: bodyFont]
        let pageLabelSize = pageLabel.size(withAttributes: pageLabelAttr)
        pageLabel.draw(at: CGPoint(x: rect.width - margin - pageLabelSize.width, y: y + 4), withAttributes: pageLabelAttr)

        y += titleSize.height + 10

        // Pilot Info
        let infoHeight: CGFloat = 62
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(0.5)
        context.stroke(CGRect(x: margin, y: y, width: contentWidth, height: infoHeight))

        let labelAttr: [NSAttributedString.Key: Any] = [.font: smallBoldFont]
        let valueAttr: [NSAttributedString.Key: Any] = [.font: bodyFont]

        drawLabelValue("Last Name:", evaluation.pilotInfo.lastName, at: CGPoint(x: margin + 4, y: y + 4), labelAttr: labelAttr, valueAttr: valueAttr, labelWidth: 55)
        drawLabelValue("First Name:", evaluation.pilotInfo.firstName, at: CGPoint(x: margin + 190, y: y + 4), labelAttr: labelAttr, valueAttr: valueAttr, labelWidth: 58)
        drawLabelValue("M.I.:", evaluation.pilotInfo.middleInitial, at: CGPoint(x: margin + 370, y: y + 4), labelAttr: labelAttr, valueAttr: valueAttr, labelWidth: 25)
        drawLabelValue("Position:", evaluation.pilotInfo.position.rawValue, at: CGPoint(x: margin + 440, y: y + 4), labelAttr: labelAttr, valueAttr: valueAttr, labelWidth: 45)
        drawLabelValue("Eval Type:", evaluation.evaluationType.rawValue, at: CGPoint(x: margin + 4, y: y + 18), labelAttr: labelAttr, valueAttr: valueAttr, labelWidth: 50)
        drawLabelValue("Aircraft Type:", evaluation.pilotInfo.aircraftType.rawValue, at: CGPoint(x: margin + 190, y: y + 18), labelAttr: labelAttr, valueAttr: valueAttr, labelWidth: 65)
        drawLabelValue("N Number/s:", evaluation.pilotInfo.nNumbers, at: CGPoint(x: margin + 370, y: y + 18), labelAttr: labelAttr, valueAttr: valueAttr, labelWidth: 60)
        drawLabelValue("Evaluator:", evaluation.evaluatorName, at: CGPoint(x: margin + 4, y: y + 32), labelAttr: labelAttr, valueAttr: valueAttr, labelWidth: 50)

        let legend = "Grading:  1 - Not Proficient   2 - Gaining Proficiency   3 - Proficient   NA - Not Applicable   NE - Not Evaluated"
        legend.draw(at: CGPoint(x: margin + 4, y: y + 48), withAttributes: [.font: smallFont])

        y += infoHeight + 8

        // 3-column section grid
        let colWidth = contentWidth / 3
        let rowHeight: CGFloat = 13
        let headerHeight: CGFloat = 14
        let sectionSpacing: CGFloat = 6

        let columnSections: [[EvaluationSection]] = [
            Array(evaluation.sections.prefix(4)),
            Array(evaluation.sections.dropFirst(4).prefix(4)),
            Array(evaluation.sections.dropFirst(8)),
        ]

        for (colIndex, group) in columnSections.enumerated() {
            var sectionY = y
            let colX = margin + CGFloat(colIndex) * colWidth

            for section in group {
                // Section header background
                let headerRect = CGRect(x: colX, y: sectionY, width: colWidth, height: headerHeight)
                context.setFillColor(UIColor(white: 0.25, alpha: 1).cgColor)
                context.fill(headerRect)

                let numStr = "\(section.id)"
                numStr.draw(at: CGPoint(x: colX + 3, y: sectionY + 2), withAttributes: [.font: sectionTitleFont, .foregroundColor: UIColor.white])
                section.title.draw(at: CGPoint(x: colX + 20, y: sectionY + 2), withAttributes: [.font: sectionTitleFont, .foregroundColor: UIColor.white])
                "Grade".draw(at: CGPoint(x: colX + colWidth - 32, y: sectionY + 2), withAttributes: [.font: sectionTitleFont, .foregroundColor: UIColor.white])

                sectionY += headerHeight

                for item in section.items {
                    let itemRect = CGRect(x: colX, y: sectionY, width: colWidth, height: rowHeight)
                    context.setStrokeColor(UIColor.lightGray.cgColor)
                    context.setLineWidth(0.25)
                    context.stroke(itemRect)

                    item.id.draw(at: CGPoint(x: colX + 3, y: sectionY + 2), withAttributes: [.font: smallFont, .foregroundColor: UIColor.gray])
                    item.name.draw(at: CGPoint(x: colX + 20, y: sectionY + 2), withAttributes: [.font: bodyFont])

                    if let grade = item.currentGrade {
                        let gradeColor: UIColor = switch grade {
                        case .notProficient: .systemRed
                        case .gainingProficiency: .systemOrange
                        case .proficient: UIColor(red: 0.2, green: 0.65, blue: 0.2, alpha: 1)
                        case .notApplicable, .notEvaluated: .darkGray
                        }
                        grade.shortName.draw(at: CGPoint(x: colX + colWidth - 24, y: sectionY + 2), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 8), .foregroundColor: gradeColor])
                    }

                    sectionY += rowHeight
                }

                sectionY += sectionSpacing
            }
        }
    }

    // MARK: - Page 2: Comments

    private static func drawPage2(context: CGContext, rect: CGRect, margin: CGFloat, evaluation: Evaluation) {
        let contentWidth = rect.width - margin * 2
        let headerFont = UIFont.boldSystemFont(ofSize: 16)
        let sectionTitleFont = UIFont.boldSystemFont(ofSize: 9)
        let bodyFont = UIFont.systemFont(ofSize: 8)
        let smallBoldFont = UIFont.boldSystemFont(ofSize: 7)

        var y = drawPageHeader(rect: rect, margin: margin)

        // Title
        let title = "Pilot Evaluation Worksheet"
        let titleAttr: [NSAttributedString.Key: Any] = [.font: headerFont]
        let titleSize = title.size(withAttributes: titleAttr)
        title.draw(at: CGPoint(x: (rect.width - titleSize.width) / 2, y: y), withAttributes: titleAttr)

        let pageLabel = "Page 2 of 3"
        let pageLabelSize = pageLabel.size(withAttributes: [.font: bodyFont])
        pageLabel.draw(at: CGPoint(x: rect.width - margin - pageLabelSize.width, y: y + 4), withAttributes: [.font: bodyFont])

        y += titleSize.height + 12

        // General comments
        if !evaluation.generalComments.isEmpty {
            let genLabelAttr: [NSAttributedString.Key: Any] = [.font: sectionTitleFont]
            "General Comments:".draw(at: CGPoint(x: margin, y: y), withAttributes: genLabelAttr)
            y += 14
            let genRect = CGRect(x: margin, y: y, width: contentWidth, height: 50)
            context.setStrokeColor(UIColor.lightGray.cgColor)
            context.setLineWidth(0.25)
            context.stroke(genRect)
            evaluation.generalComments.draw(
                in: CGRect(x: margin + 4, y: y + 4, width: contentWidth - 8, height: 42),
                withAttributes: [.font: bodyFont]
            )
            y += 58
        }

        // Comments table header
        let codeColWidth: CGFloat = 70
        let gradeColWidth: CGFloat = 40
        let commentColWidth = contentWidth - codeColWidth - gradeColWidth

        context.setFillColor(UIColor(white: 0.25, alpha: 1).cgColor)
        context.fill(CGRect(x: margin, y: y, width: codeColWidth, height: 16))
        context.fill(CGRect(x: margin + codeColWidth, y: y, width: gradeColWidth, height: 16))
        context.fill(CGRect(x: margin + codeColWidth + gradeColWidth, y: y, width: commentColWidth, height: 16))

        "Element Code/s:".draw(at: CGPoint(x: margin + 4, y: y + 3), withAttributes: [.font: sectionTitleFont, .foregroundColor: UIColor.white])
        "Grade:".draw(at: CGPoint(x: margin + codeColWidth + 4, y: y + 3), withAttributes: [.font: sectionTitleFont, .foregroundColor: UIColor.white])
        "Comments:".draw(at: CGPoint(x: margin + codeColWidth + gradeColWidth + 4, y: y + 3), withAttributes: [.font: sectionTitleFont, .foregroundColor: UIColor.white])

        y += 16

        // Comment rows
        let comments = evaluation.sections.flatMap { $0.items.filter { !$0.comment.isEmpty } }
        let rowHeight: CGFloat = 20
        let maxRows = 28

        context.setStrokeColor(UIColor.lightGray.cgColor)
        context.setLineWidth(0.25)

        for i in 0..<maxRows {
            context.stroke(CGRect(x: margin, y: y, width: codeColWidth, height: rowHeight))
            context.stroke(CGRect(x: margin + codeColWidth, y: y, width: gradeColWidth, height: rowHeight))
            context.stroke(CGRect(x: margin + codeColWidth + gradeColWidth, y: y, width: commentColWidth, height: rowHeight))

            if i < comments.count {
                let item = comments[i]
                item.id.uppercased().draw(at: CGPoint(x: margin + 4, y: y + 5), withAttributes: [.font: bodyFont])

                if let grade = item.currentGrade {
                    let gradeColor: UIColor = switch grade {
                    case .notProficient: .systemRed
                    case .gainingProficiency: .systemOrange
                    case .proficient: UIColor(red: 0.2, green: 0.65, blue: 0.2, alpha: 1)
                    case .notApplicable, .notEvaluated: .darkGray
                    }
                    grade.shortName.draw(at: CGPoint(x: margin + codeColWidth + 12, y: y + 5), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 8), .foregroundColor: gradeColor])
                }

                item.comment.draw(
                    in: CGRect(x: margin + codeColWidth + gradeColWidth + 4, y: y + 5, width: commentColWidth - 8, height: rowHeight - 6),
                    withAttributes: [.font: bodyFont]
                )
            }

            y += rowHeight
        }

        y += 20

        // Signature area
        let halfWidth = contentWidth / 2
        let sigLabelAttr: [NSAttributedString.Key: Any] = [.font: smallBoldFont]
        let sigDateFormatter = DateFormatter()
        sigDateFormatter.dateStyle = .medium

        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(0.5)

        let sigHeight: CGFloat = 28
        let labelWidth: CGFloat = 90
        let dateWidth: CGFloat = 80
        let sigAreaWidth = halfWidth - labelWidth - dateWidth - 8

        // Row 1: Pilot
        "Pilot Signature:".draw(at: CGPoint(x: margin, y: y + 10), withAttributes: sigLabelAttr)

        let pilotSigX = margin + labelWidth
        if let sigData = evaluation.pilotSignature, let sigImage = UIImage(data: sigData) {
            let sigW = min(sigAreaWidth, sigHeight * (sigImage.size.width / sigImage.size.height))
            sigImage.draw(in: CGRect(x: pilotSigX, y: y, width: sigW, height: sigHeight))
        }
        context.move(to: CGPoint(x: pilotSigX, y: y + sigHeight + 2))
        context.addLine(to: CGPoint(x: pilotSigX + sigAreaWidth, y: y + sigHeight + 2))
        context.strokePath()

        let pilotDateX = pilotSigX + sigAreaWidth + 8
        "Date:".draw(at: CGPoint(x: pilotDateX, y: y + 2), withAttributes: sigLabelAttr)
        if let date = evaluation.pilotSignatureDate {
            sigDateFormatter.string(from: date).draw(at: CGPoint(x: pilotDateX, y: y + 14), withAttributes: [.font: bodyFont])
        }
        context.move(to: CGPoint(x: pilotDateX, y: y + sigHeight + 2))
        context.addLine(to: CGPoint(x: pilotDateX + dateWidth, y: y + sigHeight + 2))
        context.strokePath()

        // Row 1: Evaluator
        let evalX = margin + halfWidth
        "Evaluator Signature:".draw(at: CGPoint(x: evalX, y: y + 10), withAttributes: sigLabelAttr)

        let evalSigX = evalX + labelWidth + 10
        let evalSigAreaWidth = halfWidth - labelWidth - dateWidth - 18
        if let sigData = evaluation.evaluatorSignature, let sigImage = UIImage(data: sigData) {
            let sigW = min(evalSigAreaWidth, sigHeight * (sigImage.size.width / sigImage.size.height))
            sigImage.draw(in: CGRect(x: evalSigX, y: y, width: sigW, height: sigHeight))
        }
        context.move(to: CGPoint(x: evalSigX, y: y + sigHeight + 2))
        context.addLine(to: CGPoint(x: evalSigX + evalSigAreaWidth, y: y + sigHeight + 2))
        context.strokePath()

        let evalDateX = evalSigX + evalSigAreaWidth + 8
        "Date:".draw(at: CGPoint(x: evalDateX, y: y + 2), withAttributes: sigLabelAttr)
        if let date = evaluation.evaluatorSignatureDate {
            sigDateFormatter.string(from: date).draw(at: CGPoint(x: evalDateX, y: y + 14), withAttributes: [.font: bodyFont])
        }
        context.move(to: CGPoint(x: evalDateX, y: y + sigHeight + 2))
        context.addLine(to: CGPoint(x: evalDateX + dateWidth, y: y + sigHeight + 2))
        context.strokePath()
    }

    // MARK: - Page 3: Flight Log

    private static func drawPage3(context: CGContext, rect: CGRect, margin: CGFloat, evaluation: Evaluation) {
        let contentWidth = rect.width - margin * 2
        let headerFont = UIFont.boldSystemFont(ofSize: 16)
        let sectionTitleFont = UIFont.boldSystemFont(ofSize: 9)
        let bodyFont = UIFont.systemFont(ofSize: 8)

        var y = drawPageHeader(rect: rect, margin: margin)

        let title = "Flight Log"
        let titleAttr: [NSAttributedString.Key: Any] = [.font: headerFont]
        let titleSize = title.size(withAttributes: titleAttr)
        title.draw(at: CGPoint(x: (rect.width - titleSize.width) / 2, y: y), withAttributes: titleAttr)

        let pageLabel = "Page 3 of 3"
        let pageLabelSize = pageLabel.size(withAttributes: [.font: bodyFont])
        pageLabel.draw(at: CGPoint(x: rect.width - margin - pageLabelSize.width, y: y + 4), withAttributes: [.font: bodyFont])

        y += titleSize.height + 6

        let totalBlockTime = evaluation.flightLogs.reduce(0.0) { $0 + (Double($1.blockTime) ?? 0) }

        let pilotLine = "Pilot: \(evaluation.pilotInfo.fullName)     Aircraft: \(evaluation.pilotInfo.aircraftType.rawValue)"
        pilotLine.draw(at: CGPoint(x: margin, y: y), withAttributes: [.font: bodyFont])

        let totalLine = "Total Block Time: \(String(format: "%.1f", totalBlockTime))"
        let totalAttr: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 10)]
        let totalSize = totalLine.size(withAttributes: totalAttr)
        totalLine.draw(at: CGPoint(x: margin + contentWidth - totalSize.width, y: y - 1), withAttributes: totalAttr)

        y += 16

        let dateColWidth: CGFloat = 100
        let depColWidth: CGFloat = 120
        let arrColWidth: CGFloat = 120
        let blockColWidth = contentWidth - dateColWidth - depColWidth - arrColWidth
        let rowHeight: CGFloat = 22

        context.setFillColor(UIColor(white: 0.25, alpha: 1).cgColor)
        context.fill(CGRect(x: margin, y: y, width: dateColWidth, height: 18))
        context.fill(CGRect(x: margin + dateColWidth, y: y, width: depColWidth, height: 18))
        context.fill(CGRect(x: margin + dateColWidth + depColWidth, y: y, width: arrColWidth, height: 18))
        context.fill(CGRect(x: margin + dateColWidth + depColWidth + arrColWidth, y: y, width: blockColWidth, height: 18))

        let colHeaderAttr: [NSAttributedString.Key: Any] = [.font: sectionTitleFont, .foregroundColor: UIColor.white]
        "Date".draw(at: CGPoint(x: margin + 4, y: y + 3), withAttributes: colHeaderAttr)
        "Departure".draw(at: CGPoint(x: margin + dateColWidth + 4, y: y + 3), withAttributes: colHeaderAttr)
        "Arrival".draw(at: CGPoint(x: margin + dateColWidth + depColWidth + 4, y: y + 3), withAttributes: colHeaderAttr)
        "Block Time".draw(at: CGPoint(x: margin + dateColWidth + depColWidth + arrColWidth + 4, y: y + 3), withAttributes: colHeaderAttr)

        y += 18

        context.setStrokeColor(UIColor.lightGray.cgColor)
        context.setLineWidth(0.25)

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium

        let maxRows = 28

        for i in 0..<maxRows {
            context.stroke(CGRect(x: margin, y: y, width: dateColWidth, height: rowHeight))
            context.stroke(CGRect(x: margin + dateColWidth, y: y, width: depColWidth, height: rowHeight))
            context.stroke(CGRect(x: margin + dateColWidth + depColWidth, y: y, width: arrColWidth, height: rowHeight))
            context.stroke(CGRect(x: margin + dateColWidth + depColWidth + arrColWidth, y: y, width: blockColWidth, height: rowHeight))

            if i < evaluation.flightLogs.count {
                let entry = evaluation.flightLogs[i]
                dateFormatter.string(from: entry.date).draw(at: CGPoint(x: margin + 4, y: y + 5), withAttributes: [.font: bodyFont])
                entry.departure.draw(at: CGPoint(x: margin + dateColWidth + 4, y: y + 5), withAttributes: [.font: bodyFont])
                entry.arrival.draw(at: CGPoint(x: margin + dateColWidth + depColWidth + 4, y: y + 5), withAttributes: [.font: bodyFont])
                entry.blockTime.draw(at: CGPoint(x: margin + dateColWidth + depColWidth + arrColWidth + 4, y: y + 5), withAttributes: [.font: bodyFont])
            }

            y += rowHeight
        }
    }

    // MARK: - Helpers

    private static func drawPageHeader(rect: CGRect, margin: CGFloat) -> CGFloat {
        var y: CGFloat = margin

        if let logo = UIImage(named: "VenturaLogo") {
            let logoHeight: CGFloat = 36
            let logoWidth = logoHeight * (logo.size.width / logo.size.height)
            let logoRect = CGRect(x: margin, y: y, width: logoWidth, height: logoHeight)
            logo.draw(in: logoRect)
        }

        let companyName = "Ventura Air Services"
        let companyAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .medium),
            .foregroundColor: UIColor(red: 0.11, green: 0.16, blue: 0.33, alpha: 1.0),
        ]
        let companySize = companyName.size(withAttributes: companyAttr)
        companyName.draw(at: CGPoint(x: margin, y: y + 38), withAttributes: companyAttr)

        y += 38 + companySize.height + 8
        return y
    }

    private static func drawLabelValue(_ label: String, _ value: String, at point: CGPoint, labelAttr: [NSAttributedString.Key: Any], valueAttr: [NSAttributedString.Key: Any], labelWidth: CGFloat) {
        label.draw(at: point, withAttributes: labelAttr)
        value.draw(at: CGPoint(x: point.x + labelWidth, y: point.y), withAttributes: valueAttr)
    }
}

// MARK: - PDF Preview

struct PDFPreviewView: View {
    let evaluation: Evaluation
    @Environment(\.dismiss) private var dismiss
    @State private var pdfData: Data?

    var body: some View {
        NavigationStack {
            Group {
                if let pdfData {
                    PDFKitView(data: pdfData)
                } else {
                    ProgressView("Generating PDF...")
                }
            }
            .navigationTitle("PDF Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        sharePDF()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .disabled(pdfData == nil)
                }
            }
            .onAppear {
                pdfData = PDFGenerator.generate(for: evaluation)
            }
        }
    }

    private func sharePDF() {
        guard let pdfData else { return }
        let sanitizedName = evaluation.pilotInfo.lastName.replacingOccurrences(of: " ", with: "_")
        let fileName = "Pilot_Evaluation_\(sanitizedName).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try? pdfData.write(to: url)

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.keyWindow?.rootViewController else { return }
        var presenter = rootVC
        while let presented = presenter.presentedViewController {
            presenter = presented
        }
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = presenter.view
        activityVC.popoverPresentationController?.sourceRect = CGRect(x: presenter.view.bounds.midX, y: 40, width: 0, height: 0)
        presenter.present(activityVC, animated: true)
    }
}

struct PDFKitView: UIViewRepresentable {
    let data: Data

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.document = PDFDocument(data: data)
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}

