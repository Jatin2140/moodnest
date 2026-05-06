import json

with open('assets/data/meditations.json', 'r') as f:
    data = json.load(f)

for item in data:
    item['audioAsset'] = 'assets/audio/meditations/ambient_ocean.wav'

with open('assets/data/meditations.json', 'w') as f:
    json.dump(data, f, indent=2)
