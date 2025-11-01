# Business Rules and Logic - YES SIR Mobile

This document outlines the key rules governing authentication, data integrity,
and feature behavior for the Flutter + Firebase architecture.

## 1. Authentication & Identity
- **Firebase Authentication** is the source of truth for identity. Supported
  providers: email/password (with mandatory password change on first login), and
  Google. Additional SSO providers can be added via Firebase in the future.
- **Org Admin Provisioning**: Only the initial Org Admin can bootstrap an
  organization. Cloud Functions validate invitations to prevent unauthorized
  tenant creation.
- **Profile Documents**: Every authenticated user must have a Firestore `users`
  document containing role, organization, and team metadata. Missing profiles
  place the user in a "pending setup" state.
- **Session Security**: App Check tokens protect backend calls; admin accounts
  can enable MFA. Tokens are refreshed silently and revoked on device sign-out.

## 2. Role-Based Access Control (RBAC)
- **Org Admin**: Full read/write access to organization data. Can manage other
  admins, teams, locations, geofences, holidays, tasks, and attendance records.
- **Team Admin**: Admin capabilities scoped to assigned teams. Firestore queries
  are filtered server-side via security rules; Cloud Functions enforce role
  checks for sensitive operations (leave approvals, exports).
- **Employee**: Access restricted to own documents and read-only organization
  metadata. Employees cannot modify team-level configuration.
- **Security Rules**: Implemented using Firestore's rules engine with reusable
  functions (e.g., `isOrgAdmin()`, `isTeamAdmin(teamId)`). Rules deny writes when
  required fields (role, organizationId) are missing.

## 3. Attendance Logic
- **Check-In Requirements**: Device must provide latitude/longitude, accuracy,
  and battery level. Cloud Functions validate geofence membership and create
  `attendance_sessions` entries.
- **Check-Out**: Calculates session duration, updates daily summary, and closes
  open sessions. Offline check-outs queue until connectivity returns; duplicates
  are deduplicated server-side.
- **Location Pings**: Captured periodically (configurable by organization) while
  checked in. Stored in a subcollection `attendance_days/{dayId}/pings` to reduce
  contention. Mock-location detection flags suspicious entries for review.
- **Overrides**: Employees create override requests referencing a specific day.
  Team Admins or Org Admins review, update status, and Cloud Functions adjust
  summaries accordingly.

## 4. Task Management
- Tasks belong to organizations and may target individuals or teams.
- Status transitions: `pending → in_progress → completed` (with optional
  `cancelled`). Only assigned users or admins can change status.
- Attachments uploaded to Cloud Storage generate signed URLs stored with the
  task document.

## 5. Leave & Holiday Governance
- Leave requests include start/end dates, leave type, notes, and attachments.
- Approval rights: Team Admins can approve for their teams; Org Admins can act
  on any request. Cloud Functions send push notifications upon status changes.
- Holidays stored at organization level with optional `teamIds` array. Team
  members inherit relevant holidays for attendance calculations.

## 6. Notifications & AI Assistant
- Firebase Cloud Messaging topics segmented by organization and team deliver
  check-in reminders, approvals, and escalations.
- YES SIR Assistant requests route through Cloud Functions to external LLMs.
  Context includes anonymized organization metadata and access controls.
- Audit logs capture AI prompts/responses linked to user IDs for compliance.

## 7. Data Lifecycle & Compliance
- Soft deletes mark documents inactive before archival/purge to Cloud Storage.
- Retention policies configurable per organization. Cloud Functions enforce
  scheduled clean-up and export flows.
- All personal data changes logged with `updatedBy` metadata for traceability.
