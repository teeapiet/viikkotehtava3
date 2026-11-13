
#!/usr/bin/env bash
set -euo pipefail

# Week 3 - Server Status Report

OUTPUT_DIR="/var/www/html/viikko3"
OUTPUT_FILE="$OUTPUT_DIR/index.html"

# Collect server information
GENERATED_AT=$(date '+%Y-%m-%d %H:%M:%S %Z %z')
UPTIME_TEXT=$(uptime -p)

DISK_USAGE=$(df -P / | awk 'NR==2 {print $5}')
DISK_PERCENT=${DISK_USAGE%\%}

MEM_TOTAL=$(free -m | awk '/^Mem:/ {print $2}')
MEM_AVAILABLE=$(free -m | awk '/^Mem:/ {print $7}')

# Check disk usage
check_disk_status() {
    local usage="$1"

    if [ "$usage" -ge 80 ]; then
        echo "WARNING"
    else
        echo "OK"
    fi
}

# Test mode: does not change the HTML report
if [ "$#" -gt 0 ]; then
    if ! [[ "$1" =~ ^[0-9]+$ ]] ||
       [ "$1" -gt 100 ]; then
        echo "Enter a percentage from 0 to 100."
        exit 1
    fi

    check_disk_status "$1"
    exit 0
fi

DISK_STATUS=$(check_disk_status "$DISK_PERCENT")

# Generate HTML to a temporary file
TEMP_FILE=$(mktemp "$OUTPUT_DIR/.report.XXXXXX")

trap 'rm -f "$TEMP_FILE"' EXIT

cat > "$TEMP_FILE" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport"
      content="width=device-width, initial-scale=1">

<title>Week 3 - Server Status</title>

<style>
html {
    min-height: 100%;
    background: linear-gradient(
        120deg,
        #fce7f3,
        #e9d5ff,
        #dbeafe
    );
    background-attachment: fixed;
}

body {
    font-family: "Courier New", monospace;
    max-width: 800px;
    margin: 40px auto;
    padding: 20px;
    color: black;
    text-align: center;
    line-height: 1.6;
}

.box {
    background: rgba(255,255,255,0.65);
    padding: 25px;
    margin: 20px 0;
    border-radius: 15px;
}

h1, h2 {
    color: black;
}

table {
    width: 100%;
    border-collapse: collapse;
    text-align: left;
}

td {
    padding: 12px;
    border-bottom: 1px solid #ddd;
}

.status {
    font-weight: bold;
    color: #9d174d;
}

a {
    color: #7e22ce;
}

code {
    overflow-wrap: anywhere;
}

.commands {
    text-align: left;
}

.commands h2 {
    text-align: center;
}

.commands p {
    margin-top: 8px;
    margin-bottom: 12px;
}
.test-results {
    text-align: left;
}

.test-results h2 {
    text-align: center;
}

.test-results h3 {
    margin-top: 25px;
    margin-bottom: 8px;
}

.test-results p {
    margin-top: 6px;
    margin-bottom: 8px;
    overflow-wrap: anywhere;
}

.how-it-works {
    text-align: left;
}

.how-it-works h2 {
    text-align: center;
}
.what-i-learned {
    text-align: left;
}

.what-i-learned h2 {
    text-align: center;
}
</style>
</head>

<body>

<h1>SERVER STATUS REPORT</h1>

<div class="box">

    <table>
        <tr>
            <td>Report generated</td>
            <td>$GENERATED_AT</td>
        </tr>

        <tr>
            <td>Server uptime</td>
            <td>$UPTIME_TEXT</td>
        </tr>

        <tr>
            <td>Disk usage (/)</td>
            <td>$DISK_USAGE</td>
        </tr>

        <tr>
            <td>Disk space status</td>
            <td class="status">$DISK_STATUS</td>
        </tr>

        <tr>
            <td>Total RAM</td>
            <td>$MEM_TOTAL MiB</td>
        </tr>

        <tr>
            <td>Available RAM</td>
            <td>$MEM_AVAILABLE MiB</td>
        </tr>
    </table>

</div>

<div class="box commands">
    <h2>Few used commands</h2>

    <p>
        <code>date</code> -
        Shows the current date, time and time zone
    </p>

    <p>
        <code>uptime -p</code> -
        Shows how long the server has been running
    </p>

    <p>
        <code>df -P / | awk 'NR==2 {print \$5}'</code> -
        Uses piping to get the disk usage percentage
    </p>

    <p>
        <code>free -m</code> -
        Shows the total and available RAM
    </p>
    </p>
        <code>bash report.sh</code> -
       Runs the script and updates HTML report
    </p>
    </p>
        <code>systemctl list-timers --all viikko3.timer</code> -
       Shows when the report will update next
    </p>
</div>

<div class="box how-it-works">
    <h2>How this works</h2>

    <p>
        My Bash script collects information about my Linux server, like disk usage, RAM and uptime.
        It checks the disk usage using an if statement. If it's below 80%, the status is OK. If it's 80% or more, it shows WARNING. 
        The script creates an HTML report, and a systemd timer updates it every minute.
    </p>
</div>

<div class="box test-results">
    <h2>Test results</h2>

    <h3>Syntax Check</h3>
    <p>
        I checked my script with
        "bash -n report.sh" and didn't get any errors
    </p>

    <h3>Manual Execution</h3>
    <p>
        I tested the script manually,
        and the report worked as expected
    </p>

     <h3>Disk Space Status Tests</h3>
    <p>50% - OK</p>
    <p>80% - WARNING</p>
    <p>90% - WARNING</p>

    <h3>Automatic Updates</h3>
    <p>I checked the report a few times:</p>
    <p>2026-11-13 05:09:44 UTC +0000</p>
    <p>2026-11-13 05:19:09 UTC +0000</p>
    <p>2026-11-13 05:21:29 UTC +0000</p>


    <h3>Reboot Test</h3>
    <p>
        I restarted my server, and
        the report continued updating automatically
    </p>
</div>

<div class="box what-i-learned">
    <h2>What did i learn</h2>

    <p>
        At first, I saw "inactive (dead)" when checking systemd.
       I learned that the service can stop after running the script, but the timer needs to stay active to update the report automatically.  
       But it wasn't a big problem and i got it to work.
    </p>
</div>

<div class="box">
    <p>
        <a href="https://github.com/teeapiet/viikkotehtava3">
            GitHub
        </a>
    </p>
</div>

</body>
</html>
EOF

# Put the finished report in place
chmod 644 "$TEMP_FILE"
mv -f "$TEMP_FILE" "$OUTPUT_FILE"

echo "Report updated: $GENERATED_AT"

