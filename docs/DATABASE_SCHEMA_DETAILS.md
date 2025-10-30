# Database Schema Details - YES SIR

This document provides a detailed overview of the database tables used in the YES SIR application. The schema is designed to support multi-tenancy, granular user roles, and features like attendance tracking, geofencing, tasks, and leave management.

## Table of Contents
1.  [organizations](#1-organizations)
2.  [teams](#2-teams)
3.  [users](#3-users)
4.  [geofences](#4-geofences)
5.  [attendance_days](#5-attendance_days)
6.  [attendance_pings](#6-attendance_pings)
7.  [attendance_sessions](#7-attendance_sessions)
8.  [attendance_override_requests](#8-attendance_override_requests)
9.  [tasks](#9-tasks)
10. [locations](#10-locations)
11. [notifications](#11-notifications)
12. [leave_requests](#12-leave_requests)
13. [holidays](#13-holidays)
14. [team_holidays](#14-team_holidays)
15. [chat_messages](#15-chat_messages)

---

### 1. `organizations`

Stores information about each organization using the YES SIR platform.
*   `id`: INTEGER PRIMARY KEY AUTOINCREMENT
*   `name`: TEXT NOT NULL - Name of the organization.
*   `domain`: TEXT - Optional custom domain for the organization.
*   `settings_json`: TEXT - JSON field for organization-level settings (e.g., location tracking parameters).
*   `created_at`: DATETIME DEFAULT CURRENT_TIMESTAMP
*   `updated_at`: DATETIME DEFAULT CURRENT_TIMESTAMP

### 2. `teams`

Manages teams within an organization.
*   `id`: INTEGER PRIMARY KEY AUTOINCREMENT
*   `organization_id`: INTEGER NOT NULL - Foreign key to `organizations`.
*   `name`: TEXT NOT NULL - Team name.
*   `description`: TEXT
*   `timezone`: TEXT - Timezone for the team, used for attendance calculations.
*   `default_location_id`: INTEGER - Foreign key to `locations`, indicating the primary work location for the team.
*   `tracking_interval_minutes`: INTEGER DEFAULT 10 - How often to ping location for team members.
*   `high_accuracy_mode`: BOOLEAN DEFAULT TRUE - Whether to use high accuracy GPS for team members.
*   `created_at`: DATETIME DEFAULT CURRENT_TIMESTAMP
*   `updated_at`: DATETIME DEFAULT CURRENT_TIMESTAMP

### 3. `users`

Stores user accounts, roles, and profile information.
*   `id`: INTEGER PRIMARY KEY AUTOINCREMENT
*   `organization_id`: INTEGER NOT NULL - Foreign key to `organizations`.
*   `team_id`: INTEGER - Foreign key to `teams`, indicating which team the user belongs to.
*   `email`: TEXT NOT NULL - User's email, unique within the organization.
*   `name`: TEXT NOT NULL - User's full name.
*   `phone`: TEXT
*   `position`: TEXT - User's job title or position.
*   `role`: TEXT NOT NULL - 'org_admin', 'team_admin', 'employee'.
*   `date_of_joining`: DATE
*   `avatar_url`: TEXT - URL to user's profile picture.
*   `is_active`: BOOLEAN DEFAULT TRUE - Whether the user account is active.
*   `settings_json`: TEXT - JSON field for user-specific preferences (e.g., notification settings).
*   `geofence_id`: INTEGER - Foreign key to `geofences`, for default geofence assignment.
*   `password_hash`: TEXT - Hashed password for email/password authentication.
*   `must_change_password`: BOOLEAN DEFAULT FALSE - Flag to force password change on next login.
*   `password_reset_token`: TEXT - Token for password reset requests.
*   `password_reset_expires_at`: DATETIME - Expiration for password reset token.
*   `last_password_change_at`: DATETIME
*   `auth_type`: TEXT DEFAULT 'email_password' - 'email_password' or 'oauth'.
*   `created_at`: DATETIME DEFAULT CURRENT_TIMESTAMP
*   `updated_at`: DATETIME DEFAULT CURRENT_TIMESTAMP

### 4. `geofences`

Defines geographical boundaries for location monitoring.
*   `id`: INTEGER PRIMARY KEY AUTOINCREMENT
*   `organization_id`: INTEGER NOT NULL - Foreign key to `organizations`.
*   `name`: TEXT NOT NULL - Geofence name.
*   `geofence_type`: TEXT DEFAULT 'circle' - 'circle' or 'polygon'.
*   `latitude`: REAL NOT NULL - Center latitude for circle or polygon.
*   `longitude`: REAL NOT NULL - Center longitude for circle or polygon.
*   `radius_meters`: INTEGER NOT NULL - Radius for circle geofences.
*   `polygon_data`: TEXT - JSON string for polygon coordinates (e.g., `[{lat: X, lng: Y}, ...]`).
*   `assigned_to_type`: TEXT - 'team' or 'user', if the geofence is specific.
*   `assigned_to_id`: INTEGER - `team_id` or `user_id` if assigned_to_type is set.
*   `is_active`: BOOLEAN DEFAULT TRUE
*   `created_at`: DATETIME DEFAULT CURRENT_TIMESTAMP
*   `updated_at`: DATETIME DEFAULT CURRENT_TIMESTAMP

### 5. `attendance_days`

Summarizes attendance for a user on a specific date.
*   `id`: INTEGER PRIMARY KEY AUTOINCREMENT
*   `user_id`: INTEGER NOT NULL - Foreign key to `users`.
*   `date`: DATE NOT NULL - The specific date for this attendance record.
*   `first_check_in_time`: DATETIME - Timestamp of the first check-in of the day.
*   `last_check_out_time`: DATETIME - Timestamp of the last check-out of the day.
*   `status`: TEXT DEFAULT 'absent' - 'present', 'absent', 'late', 'half_day', 'public_holiday', 'weekly_off'.
*   `total_distance_m`: INTEGER DEFAULT 0 - Total distance traveled during active attendance, in meters.
*   `encoded_polyline`: TEXT - Google Maps encoded polyline of the day's movement.
*   `total_working_hours`: REAL DEFAULT 0 - Total hours worked for the day.
*   `total_sessions`: INTEGER DEFAULT 0 - Total number of check-in/check-out sessions.
*   `created_at`: DATETIME DEFAULT CURRENT_TIMESTAMP
*   `updated_at`: DATETIME DEFAULT CURRENT_TIMESTAMP

### 6. `attendance_pings`

Records individual location pings during active attendance.
*   `id`: INTEGER PRIMARY KEY AUTOINCREMENT
*   `attendance_day_id`: INTEGER NOT NULL - Foreign key to `attendance_days`.
*   `attendance_session_id`: INTEGER - Foreign key to `attendance_sessions`.
*   `user_id`: INTEGER NOT NULL - Foreign key to `users`.
*   `latitude`: REAL NOT NULL
*   `longitude`: REAL NOT NULL
*   `accuracy`: REAL - Accuracy of the GPS reading, in meters.
*   `ping_time`: DATETIME NOT NULL - Timestamp of the ping.
*   `battery_level`: INTEGER - Device battery level at the time of ping.
*   `is_mock_location`: BOOLEAN DEFAULT FALSE - Whether the location is mocked.
*   `created_at`: DATETIME DEFAULT CURRENT_TIMESTAMP
*   `updated_at`: DATETIME DEFAULT CURRENT_TIMESTAMP

### 7. `attendance_sessions`

Records individual check-in/check-out periods within an `attendance_day`.
*   `id`: INTEGER PRIMARY KEY AUTOINCREMENT
*   `attendance_day_id`: INTEGER NOT NULL - Foreign key to `attendance_days`.
*   `user_id`: INTEGER NOT NULL - Foreign key to `users`.
*   `check_in_time`: DATETIME NOT NULL
*   `check_out_time`: DATETIME
*   `session_working_hours`: REAL DEFAULT 0 - Hours worked in this specific session.
*   `session_distance_m`: INTEGER DEFAULT 0 - Distance traveled in this session, in meters.
*   `session_encoded_polyline`: TEXT - Encoded polyline for this session's movement.
*   `created_at`: DATETIME DEFAULT CURRENT_TIMESTAMP
*   `updated_at`: DATETIME DEFAULT CURRENT_TIMESTAMP

### 8. `attendance_override_requests`

Stores requests from employees to modify their attendance record.
*   `id`: INTEGER PRIMARY KEY AUTOINCREMENT
*   `organization_id`: INTEGER NOT NULL - Foreign key to `organizations`.
*   `user_id`: INTEGER NOT NULL - Foreign key to `users` (the requester).
*   `date`: DATE NOT NULL - Date for which the override is requested.
*   `current_status`: TEXT NOT NULL - Original attendance status.
*   `requested_status`: TEXT NOT NULL - Desired attendance status ('present', 'late', 'half_day').
*   `reason`: TEXT - Employee's reason for the request.
*   `status`: TEXT DEFAULT 'pending' - 'pending', 'approved', 'rejected'.
*   `approved_by_user_id`: INTEGER - Foreign key to `users` (the admin who approved/rejected).
*   `approved_at`: DATETIME
*   `created_at`: DATETIME DEFAULT CURRENT_TIMESTAMP
*   `updated_at`: DATETIME DEFAULT CURRENT_TIMESTAMP

### 9. `tasks`

Manages tasks assigned to users.
*   `id`: INTEGER PRIMARY KEY AUTOINCREMENT
*   `organization_id`: INTEGER NOT NULL - Foreign key to `organizations`.
*   `assigned_to_user_id`: INTEGER NOT NULL - Foreign key to `users`.
*   `assigned_by_user_id`: INTEGER - Foreign key to `users`.
*   `team_id`: INTEGER - Foreign key to `teams`.
*   `title`: TEXT NOT NULL
*   `description`: TEXT
*   `priority`: TEXT DEFAULT 'medium' - 'low', 'medium', 'high', 'urgent'.
*   `status`: TEXT DEFAULT 'pending' - 'pending', 'in_progress', 'completed', 'cancelled'.
*   `due_date`: DATETIME
*   `completed_at`: DATETIME
*   `parent_task_id`: INTEGER - For hierarchical tasks (subtasks).
*   `attachments_json`: TEXT - JSON array of file URLs.
*   `created_at`: DATETIME DEFAULT CURRENT_TIMESTAMP
*   `updated_at`: DATETIME DEFAULT CURRENT_TIMESTAMP

### 10. `locations`

Defines physical locations relevant to the organization.
*   `id`: INTEGER PRIMARY KEY AUTOINCREMENT
*   `organization_id`: INTEGER NOT NULL - Foreign key to `organizations`.
*   `name`: TEXT NOT NULL - Location name.
*   `address`: TEXT
*   `latitude`: REAL NOT NULL
*   `longitude`: REAL NOT NULL
*   `radius_meters`: INTEGER DEFAULT 100 - Default geofence radius for this location.
*   `location_type`: TEXT - 'office', 'client_site', 'warehouse', 'other'.
*   `timezone`: TEXT - Timezone of the location (e.g., 'America/New_York').
*   `is_active`: BOOLEAN DEFAULT TRUE
*   `created_at`: DATETIME DEFAULT CURRENT_TIMESTAMP
*   `updated_at`: DATETIME DEFAULT CURRENT_TIMESTAMP

### 11. `notifications`

Stores system notifications for users.
*   `id`: INTEGER PRIMARY KEY AUTOINCREMENT
*   `organization_id`: INTEGER NOT NULL - Foreign key to `organizations`.
*   `user_id`: INTEGER NOT NULL - Foreign key to `users`.
*   `type`: TEXT NOT NULL - 'geofence_entry', 'geofence_exit', 'attendance', 'task_assignment'.
*   `title`: TEXT NOT NULL
*   `message`: TEXT NOT NULL
*   `data_json`: TEXT - JSON field for additional notification data.
*   `is_read`: BOOLEAN DEFAULT FALSE
*   `created_at`: DATETIME DEFAULT CURRENT_TIMESTAMP
*   `updated_at`: DATETIME DEFAULT CURRENT_TIMESTAMP

### 12. `leave_requests`

Records employee leave requests.
*   `id`: INTEGER PRIMARY KEY AUTOINCREMENT
*   `organization_id`: INTEGER NOT NULL - Foreign key to `organizations`.
*   `user_id`: INTEGER NOT NULL - Foreign key to `users`.
*   `start_date`: DATE NOT NULL
*   `end_date`: DATE NOT NULL
*   `reason`: TEXT
*   `status`: TEXT DEFAULT 'pending' - 'pending', 'approved', 'rejected'.
*   `approved_by_user_id`: INTEGER - Foreign key to `users` (the admin who approved/rejected).
*   `created_at`: DATETIME DEFAULT CURRENT_TIMESTAMP
*   `updated_at`: DATETIME DEFAULT CURRENT_TIMESTAMP

### 13. `holidays`

Defines official holidays for the organization or specific teams.
*   `id`: INTEGER PRIMARY KEY AUTOINCREMENT
*   `organization_id`: INTEGER NOT NULL - Foreign key to `organizations`.
*   `name`: TEXT NOT NULL - Holiday name.
*   `date`: DATE NOT NULL - Date of the holiday.
*   `description`: TEXT
*   `assignment_type`: TEXT NOT NULL DEFAULT 'organization' - 'organization' or 'teams'.
*   `created_at`: DATETIME DEFAULT CURRENT_TIMESTAMP
*   `updated_at`: DATETIME DEFAULT CURRENT_TIMESTAMP

### 14. `team_holidays`

Junction table for `holidays` assigned to specific `teams`.
*   `id`: INTEGER PRIMARY KEY AUTOINCREMENT
*   `holiday_id`: INTEGER NOT NULL - Foreign key to `holidays`.
*   `team_id`: INTEGER NOT NULL - Foreign key to `teams`.
*   `created_at`: DATETIME DEFAULT CURRENT_TIMESTAMP

### 15. `chat_messages`

Stores AI chat assistant conversation history.
*   `id`: INTEGER PRIMARY KEY AUTOINCREMENT
*   `user_id`: INTEGER NOT NULL - Foreign key to `users`.
*   `role`: TEXT NOT NULL - 'user' or 'assistant'.
*   `content`: TEXT NOT NULL - The message content.
*   `tool_call_id`: TEXT - If the message involved a tool call.
*   `timestamp`: DATETIME DEFAULT CURRENT_TIMESTAMP
