#!/bin/bash

echo "=== VM 목록 === (qm list)"
qm list | awk 'NR==1 || NR>1 {print "VM " $1 ": " $2 ", 상태=" $3 ", 메모리=" $4 "MB"}'

echo ""
echo "=== LXC 목록 === (pct list)"
pct list | awk 'NR==1 || NR>1 {print "CT " $1 ": " $5 ", 상태=" $2 ", 메모리=" $6 "MB, IP=" $3}'

echo ""
echo "주요 명령: [qm|pct] list / start / stop / reboot / destroy"
