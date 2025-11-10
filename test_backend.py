import requests
import json

def test_backend():
    base_url = "http://127.0.0.1:5000/api"
    
    # Test hesapları
    test_accounts = [
        {"username": "hasta", "password": "123456"},
        {"username": "doktor", "password": "123456"}, 
        {"username": "admin", "password": "123456"},
        {"username": "patient", "password": "123456"},
        {"username": "doctor", "password": "123456"}
    ]
    
    for account in test_accounts:
        print(f"\n🔍 Testing: {account['username']}")
        try:
            response = requests.post(
                f"{base_url}/auth/login",
                json=account,
                headers={"Content-Type": "application/json"}
            )
            
            print(f"Status: {response.status_code}")
            print(f"Response: {response.text}")
            
            if response.status_code == 200:
                data = response.json()
                print("✅ SUCCESS")
                print(f"Token: {data.get('token', 'MISSING')}")
                print(f"User: {json.dumps(data.get('user', {}), indent=2)}")
            else:
                print("❌ FAILED")
                
        except Exception as e:
            print(f"❌ ERROR: {e}")

if __name__ == "__main__":
    test_backend()