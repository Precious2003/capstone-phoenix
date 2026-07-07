# Escalation — Possible Data Exfiltration Activity

**Subject:** Escalation — Possible Data Exfiltration Activity

**Alert Summary:**
Large outbound encrypted connection detected from workstation WIN10-01.

**Evidence:**
- Sysmon Event ID 3 (Network Connect)
- Zeek `conn.log` entry
- Kibana Alert ID A003

**Findings:**
Outbound transfer exceeded expected baseline activity. Destination host reputation unknown.

**Recommended Action:**
Escalate to Tier-2 for deeper investigation, packet capture, and endpoint review.

**Analyst:**
Dolapo Fabowale — Tier-1 SOC Analyst
