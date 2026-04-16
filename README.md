# IP Triage Automation Tool

## Overview
This project automates IP reputation lookups and documentation to support faster, more consistent SOC investigations.

## Status
Initial build in progress.

## Goal
Reduce manual investigation time and standardize enrichment workflows.

## Next Steps
- Integrate AbuseIPDB API
- Parse response data
- Save structured output to file

## Features
- Accepts IP input from user
- Queries AbuseIPDB API
- Displays abuse score, country, and ISP
- Includes input validation and error handling

## Usage
Run the script in PowerShell:
.\ip_triage-automation.ps1
Enter an IP address when prompted.
