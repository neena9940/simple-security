#!/bin/bash
# test-system.sh - Test your complete deployed system

echo "🧪 TESTING DEPLOYED SECURITY SYSTEM"
echo "==================================="

# Get URLs
LOG_URL="https://log-collector-542558433102.us-central1.run.app"
ANALYZER_URL=$(gcloud run services describe analyzer --region=us-central1 --format="value(status.url)")
DASHBOARD_URL=$(gcloud run services describe dashboard --region=us-central1 --format="value(status.url)")

echo "Services:"
echo "1. 📥 Log Collector: $LOG_URL"
echo "2. 🔍 Analyzer: $ANALYZER_URL"
echo "3. 📊 Dashboard: $DASHBOARD_URL"
echo ""

# Test 1: Basic health checks
echo "Test 1: Health Checks..."
curl -s $LOG_URL && echo "✅ Log Collector: OK"
curl -s $ANALYZER_URL && echo "✅ Analyzer: OK"
curl -s $DASHBOARD_URL && echo "✅ Dashboard: OK"

# Test 2: Send normal event
echo ""
echo "Test 2: Normal login (should be safe)..."
curl -X POST "$LOG_URL/log?ip=192.168.1.10&action=login_successful"
echo ""

# Test 3: Send threat (failed login)
echo "Test 3: Failed login (should trigger threat)..."
curl -X POST "$LOG_URL/log?ip=192.168.1.99&action=login_failed"
echo ""

# Test 4: Check threats on dashboard
echo "Waiting 5 seconds for processing..."
sleep 5
echo ""
echo "Test 4: Checking threats on dashboard..."
curl -s "$DASHBOARD_URL/threats" | python3 -m json.tool 2>/dev/null || curl -s "$DASHBOARD_URL/threats"

# Test 5: View logs
echo ""
echo "Test 5: Recent Cloud Run logs..."
gcloud logging read "resource.type=cloud_run_revision" \
  --limit=5 \
  --order=desc \
  --format="value(timestamp, resource.labels.service_name, textPayload)" \
  --project=security-test-001-486007

echo ""
echo "✅ TEST COMPLETE!"
echo ""
echo "📊 Monitor your system:"
echo "- Logs: https://console.cloud.google.com/run?project=security-test-001-486007"
echo "- Metrics: https://console.cloud.google.com/monitoring"
echo "- Billing: https://console.cloud.google.com/billing (should show $0)"

