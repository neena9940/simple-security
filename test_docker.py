import requests
import time
import sys


def test_docker_setup():
    print("🧪 Testing Dockerized Microservices")
    print("=" * 50)

    # Services mapped to host ports
    services = {
        "Log Collector": "http://localhost:8005",
        "Threat Analyzer": "http://localhost:8006",
        "Dashboard": "http://localhost:8007"
    }

    # Check if services are running
    print("1. Checking service health...")
    for name, url in services.items():
        try:
            response = requests.get(url, timeout=5)
            status = response.json().get("status", "unknown")
            port = response.json().get("port", "unknown")
            print(f"   ✅ {name}: {status} (port {port})")
        except Exception as e:
            print(f"   ❌ {name}: Not responding - {e}")
            return False

    # Send a test log
    print("\n2. Sending test log...")
    try:
        response = requests.post(
            "http://localhost:8005/log",
            params={"ip": "192.168.1.100", "action": "login_failed"},
            timeout=10
        )
        print(f"   ✅ Log sent: {response.status_code}")
        print(f"   Response: {response.json()}")
    except Exception as e:
        print(f"   ❌ Failed to send log: {e}")
        return False

    # Wait for processing
    print("\n3. Waiting for threat analysis (3 seconds)...")
    time.sleep(3)

    # Check threats
    print("\n4. Checking threats...")
    try:
        response = requests.get("http://localhost:8006/threats", timeout=5)
        data = response.json()
        threat_count = data.get("count", 0)
        print(f"   ✅ Threats check: {response.status_code}")
        print(f"   Total threats stored: {threat_count}")

        if threat_count > 0:
            print(f"   🎉 SUCCESS! System is working!")
            print(f"   Threats: {data.get('threats', [])}")
        else:
            print(f"   ⚠️ No threats found. Check Docker logs.")

    except Exception as e:
        print(f"   ❌ Failed to get threats: {e}")
        return False

    print("\n" + "=" * 50)
    print("✅ Test complete!")
    return True


if __name__ == "__main__":
    success = test_docker_setup()
    sys.exit(0 if success else 1)