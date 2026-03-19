import Foundation

struct ParsedTicketPayload: Equatable {
    let ticketID: String
    let walletID: String
    let eventID: String
    let tierCode: String
    let qrToken: String
}

enum QRPayloadParserError: LocalizedError, Equatable {
    case malformedPayload
    case missingToken

    var errorDescription: String? {
        switch self {
        case .malformedPayload:
            return "Malformed payload."
        case .missingToken:
            return "Missing qr token in payload."
        }
    }
}

protocol QRPayloadParsing {
    func parse(_ payload: String) throws -> ParsedTicketPayload
}

struct QRPayloadParser: QRPayloadParsing {
    func parse(_ payload: String) throws -> ParsedTicketPayload {
        guard let components = URLComponents(string: payload),
              components.scheme == "nightlifepass",
              components.host == "ticket"
        else {
            throw QRPayloadParserError.malformedPayload
        }

        let pathParts = components.path.split(separator: "/")
        guard let ticketPart = pathParts.first, !ticketPart.isEmpty else {
            throw QRPayloadParserError.malformedPayload
        }

        let items = Dictionary(uniqueKeysWithValues: (components.queryItems ?? []).map { ($0.name, $0.value ?? "") })

        guard let wallet = items["wallet"],
              let event = items["event"],
              let tier = items["tier"],
              let token = items["token"],
              !wallet.isEmpty,
              !event.isEmpty,
              !tier.isEmpty
        else {
            throw QRPayloadParserError.malformedPayload
        }

        guard !token.isEmpty else {
            throw QRPayloadParserError.missingToken
        }

        return ParsedTicketPayload(
            ticketID: String(ticketPart),
            walletID: wallet,
            eventID: event,
            tierCode: tier,
            qrToken: token
        )
    }
}
