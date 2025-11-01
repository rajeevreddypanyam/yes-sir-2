# Firebase Services & Cloud Functions - YES SIR Mobile

The YES SIR mobile app communicates primarily with Firebase services. This
section outlines the key interactions, Firestore collections, and Cloud
Functions that replace traditional REST endpoints.

## 1. Authentication Workflows
- **Email/Password Sign-In**: `FirebaseAuth.signInWithEmailAndPassword`.
- **Google Sign-In**: Uses platform-specific Google SDK → Firebase credential.
- **Password Reset**: `sendPasswordResetEmail` triggered directly from the app.
- **Session Revocation**: Admin-triggered Cloud Function sets `revokeTokens` flag
  on user document and calls Firebase Admin SDK to revoke refresh tokens.

## 2. Firestore Operations
All Firestore access occurs via client SDK with Security Rules enforcement.

### Users
- Create/update by Cloud Functions when invitations accepted.
- Clients read their own document; admins query by `organizationId`.

### Attendance
- Client writes to `attendance_days/{dayId}/sessions` and `pings` using batched
  writes. Cloud Functions validate entries and maintain aggregated fields.

### Tasks
- Admins create tasks with `organizationId` + `assignedToUserId` filters.
- Clients listen to tasks where `assignedToUserId == currentUser.uid` or
  `teamId` matches their assignment.

### Leave Requests
- Employees create new documents under `leave_requests` with `status=pending`.
- Cloud Function listener sends FCM notifications to approvers.
- Admins update `status` → triggers history log via Cloud Function.

### Notifications
- Firestore used for in-app inbox. Cloud Functions mirror high-priority items to
  FCM for push delivery.

## 3. Cloud Functions (HTTPS / Callable)
| Function | Type | Description |
| --- | --- | --- |
| `createOrganization` | Callable | Validates invite, creates `organizations` doc, assigns caller as Org Admin. |
| `inviteUser` | Callable | Generates invite link, creates placeholder `users` document with `pending` status, sends email via transactional provider. |
| `completeInvite` | Callable | Finalizes user setup, sets role/team, and sends welcome notification. |
| `recordAttendanceEvent` | HTTPS | Validates device token, geofence, and writes session data (used by background services). |
| `approveLeaveRequest` | Callable | Confirms requester has permission, updates `status`, writes audit log, sends notifications. |
| `generateReport` | Callable | Produces CSV/PDF in Cloud Storage and returns signed URL. |
| `runAssistantAction` | Callable | Bridges YES SIR Assistant to AI provider with contextual prompts and safeguards. |

## 4. Scheduled Functions
- `dailyAttendanceReconciliation`: Runs nightly per organization, closes open
  sessions, and recalculates totals.
- `locationHealthCheck`: Flags devices without location updates in the past X
  hours.
- `retentionSweeper`: Applies data-retention policies and purges expired
  notifications, logs, and exports.

## 5. Security Rules Considerations
- All writes must include `organizationId` and pass membership checks.
- Team Admin operations verify membership via `teamId` arrays.
- Sensitive Cloud Functions double-check roles using Firebase Admin SDK to
  mitigate client spoofing.
- Audit logs stored in `organization_audit_logs` for compliance.

## 6. Local Development
- Emulators for Auth, Firestore, Functions, and Storage are mandatory for local
  testing. The Flutter app points to emulator hosts when `USE_FIREBASE_EMULATOR`
  flag is enabled.
