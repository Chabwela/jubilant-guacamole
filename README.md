# UniLoan System

**University Student Loan & Allowance Management System**  
Implementing the **Chinese Wall Security Model** (Conflict of Interest Model)

---

## Overview

UniLoan is a production-style Flutter MVP application for managing university student loans and monthly allowances. It enforces the **Chinese Wall (Brewer–Nash) security model** to prevent bank users from accessing records belonging to other banks.

---

## Tech Stack

| Concern | Technology |
|---|---|
| Framework | Flutter (Material 3) |
| State Management | Riverpod 2.x |
| Local Database | SQLite via `sqflite` |
| Architecture | Clean Architecture (data / domain / presentation) |
| Responsive | Desktop + Tablet + Mobile |

---

## Clean Architecture

```
lib/
├── core/
│   ├── constants/    # AppColors, AppStrings
│   ├── theme/        # AppTheme (Material 3, banking style)
│   └── utils/        # Date & currency formatters
├── data/
│   ├── database/     # DatabaseHelper — schema + seed data
│   ├── models/       # SQLite ↔ domain mappers
│   └── repositories/ # Concrete repository implementations
├── domain/
│   ├── entities/     # Pure Dart domain entities
│   ├── repositories/ # Abstract repository contracts
│   └── services/     # ChineseWallService ← enforcement logic
└── presentation/
    ├── providers/    # Riverpod providers
    ├── screens/      # Login, Admin, Bank, Student dashboards
    └── widgets/      # Sidebar, KpiCard, SectionCard, etc.
```

---

## Roles & Demo Credentials

| Role | Username | Password |
|---|---|---|
| System Admin | `admin` | `admin123` |
| Zanaco Bank Officer | `zanaco` | `zanaco123` |
| FNB Bank Officer | `fnb` | `fnb123` |
| Alice Mwanza (Student) | `alice` | `alice123` |
| Bob Phiri (Student) | `bob` | `bob123` |

---

## Chinese Wall Model

The `ChineseWallService` (`lib/domain/services/chinese_wall_service.dart`) is the central security enforcement point:

```
┌─────────────────────────────────────────────────────┐
│                 Chinese Wall Rules                   │
│                                                     │
│  • Alice → Zanaco  (only Zanaco bank can see Alice) │
│  • Bob   → FNB     (only FNB bank can see Bob)      │
│                                                     │
│  Bank user attempts to access another bank's        │
│  student → ACCESS DENIED + logged in AccessLogs     │
└─────────────────────────────────────────────────────┘
```

Every access attempt (allowed or denied) is written to the `AccessLogs` table. The Admin can view this full audit trail.

---

## Database Schema

```sql
Banks(id, name)
Users(id, name, username, password, role, bankId)
Students(id, name, bankId, loanAmount, monthlyAllowance)
Transactions(id, studentId, bankId, amount, type, date)
AccessLogs(id, userId, studentId, action, timestamp, status)
```

---

## Getting Started

```bash
# 1. Ensure Flutter is installed (https://flutter.dev/docs/get-started/install)
flutter --version   # should be 3.x stable

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run                  # mobile/connected device
flutter run -d chrome        # web
flutter run -d linux         # Linux desktop
flutter run -d windows       # Windows desktop

# 4. Run tests
flutter test
```

---

## Demo Flow

1. **Login as `zanaco`** → See only Alice's record
2. **Search for Bob** (student ID 2) → `ACCESS DENIED – Chinese Wall Policy Violation` dialog appears, violation logged
3. **Login as `fnb`** → See only Bob's record
4. **Login as `admin`** → See all students, all transactions, full access log with violations flagged in red

---

## Security Notes

- The Chinese Wall enforcement happens in `ChineseWallService.checkAccess()`, not just in the UI.
- Every access attempt — including violations — is persisted to `AccessLogs` before the result is returned to the caller.
- Passwords in this demo are stored in plain text for simplicity. In production, use bcrypt or Argon2 hashing.
