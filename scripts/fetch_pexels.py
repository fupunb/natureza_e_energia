import urllib.request
import urllib.parse
import json
import os

API_KEY = os.environ.get("PEXELS_API_KEY", "")
BASE_URL = "https://api.pexels.com/v1/search"
HEADERS = {
    "Authorization": API_KEY,
    "User-Agent": "Natureza e Energia Build Script"
}

IMAGES_TO_FETCH = {
    "highway": "car driving highway motion blur",
    "running": "athlete sprint track motion speed",
    "bike": "person riding bicycle bright",
    "dog": "dog running grass play",
    "cheetah": "cheetah running wild fast animal horizontal",
    "particle": "abstract glowing particles physics light",
    "map": "map direction navigation travel",
    "speedometer": "car speedometer dashboard fast"
}

OUT_DIR = "docs/deslocamento_velocidade/images"
os.makedirs(OUT_DIR, exist_ok=True)

for filename, query in IMAGES_TO_FETCH.items():
    out_path = os.path.join(OUT_DIR, f"{filename}.jpg")
    print(f"Fetching '{query}' -> {filename}.jpg")
    
    url = f"{BASE_URL}?query={urllib.parse.quote(query)}&per_page=1&orientation=landscape"
    req = urllib.request.Request(url, headers=HEADERS)
    
    try:
        with urllib.request.urlopen(req) as resp:
            data = json.loads(resp.read().decode('utf-8'))
            if not data.get("photos"):
                print(f"  No photos found for {query}")
                continue
            
            photo_url = data["photos"][0]["src"]["large"]
            
            # Download image
            img_req = urllib.request.Request(photo_url, headers={"User-Agent": "Mozilla/5.0"})
            with urllib.request.urlopen(img_req) as img_resp:
                with open(out_path, "wb") as f:
                    f.write(img_resp.read())
            print(f"  Saved {filename}")
    except Exception as e:
        print(f"  Error fetching {filename}: {e}")

print("Done fetching images.")
