import Testing
@testable import ProjectoLad

struct QRPayloadParserTests {
    private let parser = QRPayloadParser()

    @Test func parsesValidNightlifePassPayload() throws {
        let payload = "nightlifepass://ticket/ticket123?wallet=userA&event=eventB&tier=vip&token=abc123"

        let parsed = try parser.parse(payload)

        #expect(parsed.ticketID == "ticket123")
        #expect(parsed.walletID == "userA")
        #expect(parsed.eventID == "eventB")
        #expect(parsed.tierCode == "vip")
        #expect(parsed.qrToken == "abc123")
    }

    @Test func failsWhenTokenMissing() {
        let payload = "nightlifepass://ticket/ticket123?wallet=userA&event=eventB&tier=vip&token="

        #expect(throws: QRPayloadParserError.missingToken) {
            try parser.parse(payload)
        }
    }

    @Test func failsWhenSchemeIsInvalid() {
        let payload = "https://ticket/ticket123?wallet=userA&event=eventB&tier=vip&token=abc123"

        #expect(throws: QRPayloadParserError.malformedPayload) {
            try parser.parse(payload)
        }
    }
}
