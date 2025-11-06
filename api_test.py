import os
import requests
import urllib3

API_KEY = os.getenv("GEMINI_API_KEY", "AIzaSyDbkdu50nrNDYgKuGaYowc_B0EXlKO_yzQ")

URL = "https://zjxx.lol/v1beta/models/gemini-2.5-flash:generateContent"
HEADERS = {
    "x-goog-api-key": API_KEY,
    "Content-Type": "application/json",
}
VERIFY_SSL = False
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
PAYLOAD = {
    "contents": [
        {
            "parts": [
                {"text": "Explain how AI works in a few words"}
            ]
        }
    ]
}

response = requests.post(URL, headers=HEADERS, json=PAYLOAD, timeout=60, verify=VERIFY_SSL)
response.raise_for_status()
data = response.json()

try:
    text = data["candidates"][0]["content"]["parts"][0]["text"]
except (KeyError, IndexError, TypeError):
    text = str(data)

print(text)