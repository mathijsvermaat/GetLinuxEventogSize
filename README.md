# GetLogSizeforLinux.sh

## Overview

This bash script analyzes Linux system logs to calculate ingestion metrics and capacity planning data. It's particularly useful for estimating log sizes, event volumes, and data rates for integration with platforms like Microsoft Sentinel.

## Purpose

The script helps you understand log consumption patterns by:
- **Calculating total log volume** (in GB) for the previous month
- **Measuring event frequency** (events per second/EPS) to forecast ingestion rates
- **Estimating daily averages** (GB/day) for capacity planning
- **Supporting both journalctl and traditional log files** for maximum compatibility

This information is essential for:
- Capacity planning in Log Analytics and Sentinel environments
- Understanding data ingestion costs
- Configuring log collection settings appropriately
- Troubleshooting log collection issues

## Requirements

- **Bash shell** (typically available on all Linux distributions)
- **Common utilities**: `grep`, `wc`, `date`, `bc`
- **Read permissions** on system log files (typically requires `sudo` or running as root)
- Optional: `journalctl` (systemd-based systems for enhanced log extraction)

## Installation

1. Clone or download the script:
   ```bash
   git clone https://github.com/yourusername/GetLogSizeforLinux.git
   cd GetLogSizeforLinux
   ```

2. Make the script executable:
   ```bash
   chmod +x GetLogSizeforLinux.sh
   ```

## Usage

### Basic Execution

Run the script with sudo (most log files require elevated privileges):

```bash
sudo ./GetLogSizeforLinux.sh
```

### Output

The script generates a summary report:

```
Analyzed month: 2026-01
Total events: 1,234,567
Total bytes: 5,368,709,120
Average EPS: 451.97 events/sec
Average GB/day: 5.24 GB
Total ingest (month): 162.45 GB
```

**What each metric means:**
- **Total events**: Number of individual log lines in the analyzed period
- **Total bytes**: Raw size of all log data
- **Average EPS**: Events per second; useful for real-time ingestion rate planning
- **Average GB/day**: Daily data volume; helps estimate monthly costs
- **Total ingest (month)**: Full month's worth of data for the previous month

## Customization

### Change Analyzed Log Files

Edit the `LOG_FILES` array at the top of the script:

```bash
LOG_FILES=("/var/log/syslog" "/var/log/auth.log" "/var/log/audit/audit.log")
```

Common log files:
- `/var/log/syslog` - General system logs (Debian/Ubuntu)
- `/var/log/messages` - General system logs (RHEL/CentOS)
- `/var/log/auth.log` - Authentication logs
- `/var/log/audit/audit.log` - Audit logs
- `/var/log/kern.log` - Kernel logs

### Change Analyzed Time Period

By default, the script analyzes the **previous full month**. To modify this behavior, edit the time range section:

```bash
LAST_MONTH=$(date -d "$(date +%Y-%m-15) -1 month" +%Y-%m)
```

### Temporary Directory

Change the temp directory location if needed:

```bash
TMP_DIR="/tmp/log_analysis"
```

### Cleanup

By default, temporary files are preserved for inspection. To automatically clean up after analysis, uncomment the last line:

```bash
rm -f "$MATCHED_LOG"
```

## How It Works

1. **Configuration**: Defines which log files to analyze and creates a temporary directory
2. **Time Range**: Calculates the previous full month's date range
3. **Log Extraction**: 
   - Uses `journalctl` if available (preferred for systemd-based systems)
   - Falls back to `grep` on traditional log files
4. **Metrics Calculation**:
   - Counts total log lines (events)
   - Measures total bytes
   - Calculates EPS by dividing total events by seconds in the month
   - Computes GB/day average
5. **Output**: Displays formatted results

## Troubleshooting

### Permission Denied
Log files require elevated privileges. Always run with `sudo`:
```bash
sudo ./GetLogSizeforLinux.sh
```

### Command Not Found: bc
Install the `bc` calculator package:
```bash
sudo apt-get install bc           # Debian/Ubuntu
sudo yum install bc               # RHEL/CentOS
```

### No Output / Empty Results
Check if:
- Log files exist at the specified paths
- You have read permissions
- Logs from the previous month exist (logs may have been rotated)

### Low Event Count
This may indicate:
- Logs were rotated and aren't available for the full month
- The specified log files don't contain events for the analyzed period
- Log retention is configured too aggressively

## Use Cases

### Microsoft Sentinel Integration
Use the output to:
- Estimate data ingestion costs
- Plan log collection schedules
- Validate log collection is working as expected

### Capacity Planning
- Factor the GB/day metric into infrastructure planning
- Use EPS data to understand peak load requirements

### Auditing
- Verify that expected log volumes are being generated
- Detect anomalies in logging patterns

## Example Workflow

```bash
# 1. SSH into your Linux server
ssh user@linuxserver.com

# 2. Download and prepare the script
wget https://github.com/yourusername/GetLogSizeforLinux/raw/main/GetLogSizeforLinux.sh
chmod +x GetLogSizeforLinux.sh

# 3. Run with sudo
sudo ./GetLogSizeforLinux.sh

# 4. Use the output for capacity planning
# Result: ~5.24 GB/day means ~157 GB/month
```


## Related Resources

- [Microsoft Sentinel Documentation](https://docs.microsoft.com/en-us/azure/sentinel/)
- [Linux Log File Locations](https://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/var.html)
- [journalctl Documentation](https://man7.org/linux/man-pages/man1/journalctl.1.html)
