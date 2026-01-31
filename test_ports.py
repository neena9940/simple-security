# test_ports.py
import requests
import time

print("🧪 Testing with ports 8005, 8006, 8007")
print("=" * 50)

# Define ports
PORTS = {
    "log-collector": 8005,
    "analyzer": 8006,
    "dashboard": 8007
}

# Check services
print("1. Checking services...")
for name, port in PORTS.items():
    try:
        r = requests.get(f"http://localhost:{port}", timeout=3)
        status = r.json().get("status", "unknown")
        service_port = r.json().get("port", "unknown")
        print(f"   ✅ {name}: {status} (port {service_port})")
    except Exception as e:
        print(f"   ❌ {name}: Not responding - {e}")

# Send test log
print("\n2. Sending test log to port 8005...")
try:
    r = requests.post(
        "http://localhost:8005/log",
        params={"ip": "10.0.0.99", "action": "login_failed"},
        timeout=5
    )
    print(f"   ✅ Log sent: {r.status_code}")
    print(f"   Response: {r.json()}")
except Exception as e:
    print(f"   ❌ Error: {e}")

# Check threats
print("\n3. Checking threats on port 8007...")
time.sleep(3)

try:
    r = requests.get("http://localhost:8007/threats", timeout=5)
    data = r.json()
    count = data.get("count", 0)
    print(f"   ✅ Threats: {count} found")

    if count > 0:
        print("   🎉 SUCCESS! Microservices are communicating!")
        for threat in data.get("threats", [])[:3]:  # Show first 3
            print(f"   - {threat.get('ip')}: {threat.get('type')}")
    else:
        print("   ⚠️ No threats found. Check Docker logs.")

except Exception as e:
    print(f"   ❌ Error: {e}")

print("\n✅ Test complete!")