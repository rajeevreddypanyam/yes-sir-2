# Firebase Data Model - YES SIR Mobile

YES SIR uses Cloud Firestore as the primary data store. Collections are scoped by
organization to maintain strong tenant isolation and support offline caching.

## Top-Level Collections

### 1. `organizations`
Stores metadata for each customer.
- `name` (string, required)
- `subscriptionTier` (string)
- `timeZone` (string)
- `settings` (map) – attendance cadence, geofence sensitivity, AI permissions.
- `createdAt` / `updatedAt` (timestamps)

### 2. `users`
One document per Firebase Authentication user.
- `email` (string, required)
- `displayName` (string)
- `role` (string: `org_admin`, `team_admin`, `employee`)
- `organizationId` (reference/id)
- `teamId` (reference/id)
- `phone`, `position`, `avatarUrl`
- `isActive` (bool)
- `deviceInfo` (map) – deviceId, lastCheckInAt, platform.
- `createdAt` / `updatedAt` (timestamps)

### 3. `teams`
Scoped by organization via `organizationId` field.
- `name`, `description`
- `organizationId`
- `defaultLocationId`
- `trackingIntervalMinutes`, `highAccuracyMode`
- `timeZone`
- `createdAt` / `updatedAt`

### 4. `locations`
Physical locations relevant to organizations.
- `organizationId`
- `name`, `address`
- `latitude`, `longitude`
- `radiusMeters`
- `locationType`
- `timeZone`
- `createdAt` / `updatedAt`

### 5. `geofences`
- `organizationId`
- `name`
- `type` (`circle`, `polygon`)
- `radiusMeters` (for circles)
- `polygon` (array of lat/lng)
- `assignedToType` (`team`, `user`, null)
- `assignedToId`
- `isActive`
- `createdAt` / `updatedAt`

### 6. `tasks`
- `organizationId`
- `assignedToUserId`
- `teamId`
- `title`, `description`
- `priority` (`low`, `medium`, `high`, `urgent`)
- `status` (`pending`, `in_progress`, `completed`, `cancelled`)
- `dueAt`, `completedAt`
- `attachments` (array of storage URLs)
- `checklist` (array of items)
- `createdAt` / `updatedAt`

### 7. `leave_requests`
- `organizationId`
- `userId`
- `type` (`annual`, `sick`, `on_duty`, etc.)
- `startDate`, `endDate`
- `reason`, `attachments`
- `status` (`pending`, `approved`, `rejected`)
- `approvedBy`, `approvedAt`
- `createdAt` / `updatedAt`

### 8. `holidays`
- `organizationId`
- `name`, `date`, `description`
- `assignmentType` (`organization`, `teams`)
- `teamIds` (array)
- `createdAt` / `updatedAt`

### 9. `notifications`
- `organizationId`
- `userId`
- `type` (`geofence`, `attendance`, `task`, `system`)
- `title`, `message`
- `data` (map for deep links)
- `isRead`
- `createdAt`

## Attendance Substructure
Attendance data is split into collections to balance query cost and offline
support.

### `attendance_days`
Collection path: `organizations/{orgId}/attendance_days`.
- `userId`
- `date` (YYYY-MM-DD string)
- `status` (`present`, `absent`, `late`, `half_day`, `holiday`, `weekly_off`)
- `firstCheckInAt`, `lastCheckOutAt`
- `totalWorkMinutes`, `totalDistanceMeters`
- `encodedPolyline`
- `overrideStatus`
- `createdAt` / `updatedAt`

#### Subcollection: `sessions`
`attendance_days/{dayId}/sessions/{sessionId}`
- `checkInAt`, `checkOutAt`
- `workMinutes`
- `distanceMeters`
- `deviceId`
- `notes`

#### Subcollection: `pings`
`attendance_days/{dayId}/pings/{pingId}`
- `lat`, `lng`
- `accuracy`
- `capturedAt`
- `batteryLevel`
- `speed`
- `isMockLocation`

### `attendance_override_requests`
Collection path: `organizations/{orgId}/attendance_override_requests`
- `userId`
- `date`
- `currentStatus`
- `requestedStatus`
- `reason`
- `status`
- `reviewedBy`, `reviewedAt`
- `createdAt`

## Chat & AI
### `chat_threads`
- `organizationId`
- `participantIds`
- `createdAt`

#### Subcollection: `messages`
- `senderId`
- `role` (`user`, `assistant`, `system`)
- `content`
- `toolInvocation` (map)
- `createdAt`

## Storage Buckets
- `proof-of-work/{organizationId}/{taskId}/...`
- `attendance-photos/{organizationId}/{dayId}/...`
- `exports/{organizationId}/{reportId}.csv`

## Indexing Guidelines
- Composite indexes for queries filtering by `organizationId` + `status`.
- TTL indexes for notifications to auto-clean after retention period.
- Use `collectionGroup` indexes for attendance sessions if cross-day analytics
  is required.
