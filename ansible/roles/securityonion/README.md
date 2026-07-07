Role: securityonion

Purpose: Automate Security Onion installation and tuning.

Tasks this role should include:
- Install prerequisites
- Mount disks and configure storage for /nsm
- Install Security Onion packages or run `so-install` non-interactively when supported
- Configure Wazuh integration or forwarding to Elastic

NOTE: Security Onion installation is interactive; this role provides scaffolding and post-install config steps.