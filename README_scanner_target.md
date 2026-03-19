# ProjectoLadScanner Target

## Architecture

The scanner app is implemented as a second app target (`ProjectoLadScanner`) in the same Xcode project.

- `ScannerApp/`: scanner-only app entrypoint + scanner Info.plist.
- `Scanner/`: scanner feature code (models, services, view models, views, utilities).
- `Shared/Tickets/`: shared Firestore redemption store used by both buyer and scanner targets to keep ticket redemption logic aligned.

### Core components

- `QRPayloadParser`: validates/parses QR deep-link payloads.
- `ScannerTicketRepository`: wraps shared ticket redemption store and maps Firestore errors.
- `ScannerAuthService`: email/password auth + `role=scanner` custom claim check.
- `ScannerSessionViewModel`: scan -> parse -> fetch by `qrToken` -> transactional redemption -> result state.
- `ScannerCameraView`: prefers VisionKit `DataScannerViewController`, falls back to AVFoundation QR capture.

## Scanner flow

1. Launch app.
2. If not signed in, present scanner login screen.
3. After scanner auth succeeds, open camera scanner.
4. When QR is scanned:
   - pause scanning,
   - parse payload (`nightlifepass://ticket/...&token=...`),
   - fetch ticket by `qrToken`,
   - redeem transactionally (active -> used with `usedAt` and `scannedBy`),
   - show `VALID`, `ALREADY USED`, or `INVALID` for 1.5s,
   - auto resume scanning.

## Build / run instructions

1. Open `ProjectoLad.xcodeproj`.
2. Select the `ProjectoLadScanner` scheme/target.
3. Configure signing/team and bundle id (`com.proyectolad.scanner` by default).
4. Ensure `GoogleService-Info.plist` is included in scanner target membership.
5. Run on a physical iPhone for camera testing.

## Firebase setup

- Firebase Auth: enable Email/Password provider.
- Create scanner accounts in Auth.
- Add custom claim `role=scanner` for scanner users (Admin SDK).
- Firestore rules: allow scanner redemption updates only for scanner claim and only for redemption fields.

## Security notes

- Scanner login is restricted by Firebase custom claim (`role=scanner`).
- Ticket fetch is token-based (`qrToken`), and redemption uses Firestore transaction checks so only `active` tickets transition to `used`.
- Client-side validation does not replace Firestore rules: enforce claim + field-level constraints server-side.
