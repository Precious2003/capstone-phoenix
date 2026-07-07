# AI-assisted analysis prompts (examples)

Example prompt for a Zeek conn.log snippet:

```
Analyze this Zeek connection log snippet for suspicious outbound traffic patterns typical of data exfiltration:

ts uid id.orig_h id.resp_h proto service duration orig_bytes resp_bytes
2026-07-06 C3kLk1 192.168.1.10 104.26.10.78 tcp ssl 300 245000000 5000
```

Suggested AI tasks:
- Summarize why this could indicate data exfiltration
- Provide next-step checks (process correlation, packet capture guidance, IOC lookups)
- Produce an escalation message for Tier-2
