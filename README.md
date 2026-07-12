# CloudShield-Pipeline

An automated, production-grade GitOps deployment pipeline featuring multi-stage infrastructure orchestration and containerized edge routing. This repository demonstrates standard DevOps practices for securely isolating application environments while maintaining automated CI/CD validation.

---

## 🏗️ System Architecture

```text
[ Internet ]
      │
      ▼ (Port 80 / HTTP)
┌────────────────────────────────────────────────────────┐
│ AWS VPC (Virtual Private Cloud)                        │
│                                                        │
│  ┌───────────────────────┐                             │
│  │ Public Subnet         │                             │
│  │  ┌─────────────────┐  │                             │
│  │  │ Edge Proxy      │  │                             │
│  │  │ (EC2 / Nginx)   │  │                             │
│  │  └────────┬────────┘  │                             │
│  └───────────┼───────────┘                             │
│              │                                         │
│              ▼ (Internal Routing via Security Groups)  │
│  ┌───────────────────────┐                             │
│  │ Private Subnet        │                             │
│  │  ┌─────────────────┐  │                             │
│  │  │ App Worker      │  │                             │
│  │  │ (EC2 / Docker)  │  │                             │
│  │  └─────────────────┘  │                             │
│  └───────────────────────┘                             │
└────────────────────────────────────────────────────────┘
