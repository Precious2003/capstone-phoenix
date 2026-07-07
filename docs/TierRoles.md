# SOC Tier Roles and Responsibilities

## Tier-1: Alert Analyst (Triage & Escalation)

**Responsibility:** Monitor alerts, perform initial triage, and escalate validated threats.

**Key Duties:**
- Review incoming alerts from SIEM (Kibana)
- Classify alerts as True Positive (TP) or False Positive (FP)
- Document decision rationale in ticketing system
- Escalate TP alerts with full context and evidence
- Close FP alerts with justification
- Maintain SLA: < 30 min initial response time

**Tools Used:**
- Kibana (alert dashboards)
- Ticketing system (Jira, ServiceNow, etc.)
- Slack/Teams (notifications)
- Browser (for pivot searching)

**Example Decision:**
```
Alert: Multiple DNS requests from WIN10-01 to 204.130.14.5
Action: Check DNS category and frequency
Result: Normal web browsing (Google CDN)
Decision: False Positive → Close ticket with reason
```

---

## Tier-2: Security Analyst (Investigation & Validation)

**Responsibility:** Investigate escalated alerts, correlate events, and validate threats.

**Key Duties:**
- Perform deep-dive investigation on escalated alerts
- Correlate logs from multiple sources (Sysmon, Zeek, Wazuh)
- Review process trees and network flows
- Determine indicators of compromise (IOCs)
- Produce investigation report with findings
- Make escalation/containment recommendations
- SLA: < 2 hours turnaround

**Tools Used:**
- Kibana (advanced queries)
- Wireshark (packet capture analysis)
- Sysmon event logs
- Zeek (network telemetry)
- Threat intelligence platforms (VirusTotal, AlienVault)

**Example Investigation:**
```
Alert: PowerShell execution from unusual parent process
Investigation:
  1. Check Sysmon EventID 1: parent process = explorer.exe
  2. Zeek logs: outbound connection to 192.0.2.5:445 (SMB)
  3. Check process tree: explorer.exe → powershell.exe → cmd.exe
  4. Wireshark: SMB traffic indicates potential lateral movement
Decision: Escalate to Tier-3 for malware analysis
```

---

## Tier-3: Threat Hunter (Advanced Analysis & Detection Engineering)

**Responsibility:** Threat hunting, malware analysis, detection rule creation.

**Key Duties:**
- Perform proactive threat hunting for attacker patterns
- Conduct malware analysis and reverse engineering
- Create/refine YARA rules and correlation signatures
- Develop new detections based on TTPs
- Coordinate with incident response team
- Update threat intelligence feeds
- SLA: < 24 hours for complex analysis

**Tools Used:**
- Censys, Shodan (OSINT)
- YARA, Snort (detection rules)
- IDA Pro, Ghidra (malware analysis)
- Python scripting (automation)
- Tau (behavioral analysis)
- Wireshark + tcpdump (deep packet analysis)

**Example Threat Hunt:**
```
Hunt Objective: Find Command & Control (C2) callbacks
Method:
  1. Search Zeek SSL logs for expired/self-signed certs
  2. Query Sysmon for parent-child process chains
  3. Correlate with WHOIS/passive DNS data
  4. Develop YARA rule for detected malware family
Output: 5 new detection rules, 12 confirmed compromised hosts
```

---

## Communication Hierarchy & Escalation

```
Tier-1 (Alert Triage)
        ↓ [escalates]
Tier-2 (Investigation)
        ↓ [escalates]
Tier-3 (Threat Hunting)
        ↓ [decides containment]
Incident Response Team
        ↓
Executive/Legal (if regulatory)
```

**Communication Channels:**
- **Immediate:** Slack/Teams channel (#soc-escalations)
- **Formal:** Ticketing system (Jira, ServiceNow)
- **Documentation:** Email with investigation report
- **Emergency:** Phone bridge + war room

---

## Tier Handoff Checklist

**Tier-1 → Tier-2:**
- [ ] Alert ID and timestamp documented
- [ ] Complete Kibana dashboard/saved search link
- [ ] Relevant logs (Sysmon, Zeek, firewall) extracted
- [ ] Initial IOCs identified (IP, hash, domain)
- [ ] Investigation notes in ticket

**Tier-2 → Tier-3:**
- [ ] Investigation summary (findings, confidence)
- [ ] Timeline of events
- [ ] Malware samples (if found)
- [ ] Recommended detection rules to write
- [ ] Threat actor/campaign attribution (if known)

**Tier-3 → Incident Response:**
- [ ] Validated threat assessment
- [ ] New detection rules (YARA, Snort)
- [ ] Containment/mitigation recommendations
- [ ] Forensic artifacts for analysis
- [ ] Communication template for affected teams

---

## Performance Metrics

| Metric | Tier-1 | Tier-2 | Tier-3 |
|--------|--------|--------|--------|
| MTTR (Mean Time To Respond) | < 30 min | < 2 hr | < 24 hr |
| MTTD (Mean Time To Detect) | Varies | N/A | Proactive |
| Escalation Accuracy | > 80% | > 90% | N/A |
| Alert Volume | 100–500/day | 10–50/day | 5–10/day |
| False Positive Ratio | < 30% | < 10% | < 5% |

---

## Best Practices

1. **Tier-1:** Always document reason for closure (TP/FP classification)
2. **Tier-2:** Never skip correlation step; always check process/network context
3. **Tier-3:** Automate routine analysis; focus on novel/complex cases
4. **All Tiers:** Communicate blockers immediately; escalate if unsure
