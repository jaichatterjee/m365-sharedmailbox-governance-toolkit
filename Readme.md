# M365 Shared Mailbox Governance Toolkit

## Overview

The M365 Shared Mailbox Governance Toolkit is a PowerShell-based governance and reporting solution designed for Microsoft 365 environments.

The toolkit analyzes shared mailbox access, enriches mailbox members with Entra ID information, evaluates organizational hierarchy depth, and generates governance-oriented approval reports.

This project was designed to demonstrate:

- Microsoft Graph integration
- Exchange Online automation
- identity enrichment
- organizational hierarchy processing
- governance decision logic
- reporting architecture

The repository focuses on practical enterprise use cases involving mailbox ownership visibility and access review workflows.

---

## Key Features

### Shared Mailbox Inventory Processing

- Import shared mailbox inventory from CSV
- GUI-based file selection
- Automatic duplicate removal
- Shared mailbox validation

---

### Shared Mailbox Access Analysis

- Retrieve mailbox permissions
- Enumerate mailbox members
- Map mailbox-to-user relationships

---

### Entra ID User Enrichment

For each mailbox member:

- User ID
- Display name
- Job title
- Department

Retrieved dynamically using Microsoft Graph.

---

### Organizational Hierarchy Processing

For each mailbox member:

- Manager traversal
- Hierarchy depth calculation
- Organizational relationship analysis

---

### Governance Approval Logic

Uses hierarchy processing to determine:

- likely mailbox approvers
- ownership context
- governance relationships

---

### Reporting

Automatically generates:

| Report | Purpose |
|---|---:|
| MailboxMemberMap.csv | Mailbox-to-user mapping |
| MailboxUserDetails.csv | User identity enrichment |
| MailboxHierarchyReports.csv | Hierarchy analysis |
| Mailbox_Approvers.csv | Final governance report |

---

### Logging & Configuration

Includes:

- centralized logging
- config-driven output paths
- reusable functions
- modular architecture

---

## Repository Structure

```text
m365-sharedmailbox-governance-toolkit/
│
├── README.md
├── .gitignore
│
├── src/
│   ├── Main.ps1
│   │
│   ├── Config/
│   │   └── config.ps1
│   │
│   ├── Functions/
│   │   ├── Connect-M365.ps1
│   │   ├── Import-SharedMailboxCSV.ps1
│   │   ├── Get-SharedMailboxMembers.ps1
│   │   ├── Get-HierarchyDepth.ps1
│   │   └── Get-ApproverFromHierarchy.ps1
│   │
│   └── Logging/
│       └── Write-Log.ps1
│
├── examples/
│   └── sample-mailboxes.csv
│
└── docs/
    ├── governance-flow.md
    ├── approval-logic.md
    └── screenshots.md
```

---

## Execution Flow

```text
CSV Import
    ↓
Shared Mailbox Validation
    ↓
Mailbox Permission Retrieval
    ↓
Mailbox Member Mapping
    ↓
Microsoft Graph User Enrichment
    ↓
Hierarchy Evaluation
    ↓
Approver Resolution
    ↓
Governance Report Generation
```

---

## Usage

Run:

```powershell
.\src\Main.ps1
```

Application workflow:

1. Authenticate to Microsoft Graph and Exchange Online
2. Select mailbox CSV file
3. Process mailbox inventory
4. Retrieve mailbox members
5. Enrich users with Entra ID data
6. Apply hierarchy analysis
7. Generate reports

---

## Example Input

```csv
PrimarySmtpAddress
sharedfinance@example.com
sharedhr@example.com
sharedit@example.com
```

---

## Output Example

```text
reports/

├── MailboxMemberMap.csv
├── MailboxUserDetails.csv
├── MailboxHierarchyReports.csv
└── Mailbox_Approvers.csv
```

---

## Security Notes

- No credentials stored
- No tenant identifiers stored
- No production data included
- Sample data sanitized
- Authentication handled interactively

---

## Technologies Used

- PowerShell
- Microsoft Graph SDK
- Exchange Online PowerShell
- Windows Forms
- CSV processing

---

## Intended Audience

- Microsoft 365 Administrators
- Messaging Engineers
- Identity Administrators
- Governance Teams
- Automation Engineers

---

## Disclaimer

This project is shared for demonstration and learning purposes.

Production implementations should follow organizational security and change-management requirements.
