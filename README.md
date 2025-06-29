<!-- PROJECT LOGO -->
<p align="center">
  <a href="https://github.com/Expiscor-Group-Ltd/orions-belt">
   <img src="https://github.com/Expiscor-Group-Ltd/orions-belt/blob/main/images/OB-logo-blue.png" alt="Orion's Belt Logo" width="100">
  </a>
</p>


# Orion's Belt: A Framework for Principled, Automated System Hardening

Orion's Belt is an open-source project dedicated to automating system hardening and compliance against established cybersecurity benchmarks like CIS, NIST CSF, and ISO 27001.

### The Engineering Challenge

While many configuration scripts exist, creating a truly robust, reliable, and adaptable hardening solution presents significant technical challenges. Standard approaches often result in brittle, platform-specific scripts that are difficult to maintain and verify. Our work on Orion's Belt is focused on overcoming these systemic issues.

Our core development is centered on three key areas of investigation:

1.  **Developing a Flexible Hardening Architecture:** We are engineering a new, modular framework for Ansible that moves beyond static, hard-coded configurations. The primary technical challenge is designing an architecture that is truly platform-agnostic and remains idempotent across a vast and unpredictable range of target environments.

2.  **Systematic Translation of Controls to Code:** We are developing a systematic methodology to translate high-level security requirements into concrete, verifiable automation tasks. This involves creating a logical model to manage dependencies between controls and ensure that automated remediation is both effective and non-disruptive.

3.  **Investigating AI-Assisted Generation:** We are exploring novel techniques for leveraging AI to assist in the development of hardening playbooks, including new validation and verification strategies to overcome the inherent limitations of current AI models.

### Project Status

This project is currently in the core architectural development phase. We welcome ideas and feedback from the community as we progress. For more information on how to contribute, please see our `CONTRIBUTING.md` file.