import wave, math, random, struct
import os
import json

sample_rate = 44100
duration = 15 # seconds

def write_wav(filename, gen_sample_func):
    out_path = f'assets/audio/meditations/{filename}'
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with wave.open(out_path, 'w') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sample_rate)
        
        state = {'brown': 0.0, 'pink_b0':0.0, 'pink_b1':0.0, 'pink_b2':0.0, 'pink_b3':0.0, 'pink_b4':0.0, 'pink_b5':0.0, 'pink_b6':0.0}
        
        for i in range(duration * sample_rate):
            val = gen_sample_func(i, sample_rate, state)
            val = max(-32768, min(32767, int(val * 32767)))
            w.writeframesraw(struct.pack('<h', val))

def generate_ocean(i, sr, state):
    white = random.uniform(-0.1, 0.1)
    state['brown'] = 0.98 * state['brown'] + white
    state['brown'] = max(-1.0, min(1.0, state['brown']))
    
    t = i / sr
    env = 0.1 + 0.9 * ((math.sin(2 * math.pi * 0.125 * t) + 1) / 2.0)
    env *= 0.5 + 0.5 * ((math.sin(2 * math.pi * 0.05 * t) + 1) / 2.0)
    return state['brown'] * env

def generate_rain(i, sr, state):
    white = random.uniform(-1, 1)
    state['pink_b0'] = 0.99886 * state['pink_b0'] + white * 0.0555179
    state['pink_b1'] = 0.99332 * state['pink_b1'] + white * 0.0750759
    state['pink_b2'] = 0.96900 * state['pink_b2'] + white * 0.1538520
    state['pink_b3'] = 0.86650 * state['pink_b3'] + white * 0.3104856
    state['pink_b4'] = 0.55000 * state['pink_b4'] + white * 0.5329522
    state['pink_b5'] = -0.7616 * state['pink_b5'] - white * 0.0168980
    pink = state['pink_b0'] + state['pink_b1'] + state['pink_b2'] + state['pink_b3'] + state['pink_b4'] + state['pink_b5'] + state['pink_b6'] + white * 0.5362
    state['pink_b6'] = white * 0.115926
    
    pink = pink * 0.08
    if random.random() < 0.005:
        pink += random.uniform(0.1, 0.2)
    return pink

def generate_forest(i, sr, state):
    white = random.uniform(-0.03, 0.03)
    t = i / sr
    base = white
    chirp = 0
    cycle = t % 5
    if 0.5 < cycle < 0.7:
        freq = 2000 + 1000 * math.sin(2 * math.pi * 10 * t)
        chirp = 0.1 * math.sin(2 * math.pi * freq * t)
    if 3.2 < cycle < 3.4:
        freq = 3000 - 1000 * math.sin(2 * math.pi * 15 * t)
        chirp = 0.08 * math.sin(2 * math.pi * freq * t)
    return base + chirp

def generate_space(i, sr, state):
    t = i / sr
    freq1 = 50 + 10 * math.sin(2 * math.pi * 0.02 * t)
    drone1 = 0.3 * math.sin(2 * math.pi * freq1 * t)
    freq2 = 55 + 15 * math.sin(2 * math.pi * 0.015 * t)
    drone2 = 0.3 * math.sin(2 * math.pi * freq2 * t)
    
    white = random.uniform(-0.02, 0.02)
    state['brown'] = 0.99 * state['brown'] + white
    state['brown'] = max(-1.0, min(1.0, state['brown']))
    
    return drone1 + drone2 + state['brown'] * 0.1

if __name__ == '__main__':
    print("Generating sounds...")
    write_wav('ambient_ocean.wav', generate_ocean)
    write_wav('ambient_rain.wav', generate_rain)
    write_wav('ambient_forest.wav', generate_forest)
    write_wav('ambient_space.wav', generate_space)
    
    print("Updating meditations.json...")
    with open('assets/data/meditations.json', 'r') as f:
        data = json.load(f)

    mappings = {
        "med_001": "ambient_forest.wav",  # Morning Gratitude
        "med_002": "ambient_space.wav",   # Body Scan for Rest
        "med_003": "ambient_rain.wav",    # Focus Reset
        "med_004": "ambient_ocean.wav",   # Letting Go
        "med_005": "ambient_forest.wav",  # Energise & Uplift
        "med_006": "ambient_space.wav",   # Deep Sleep Journey
        "med_007": "ambient_rain.wav",    # Midday Mini Reset
        "med_008": "ambient_ocean.wav",   # Self-Compassion
    }

    for item in data:
        file_name = mappings.get(item['id'], 'ambient_ocean.wav')
        item['audioAsset'] = f"assets/audio/meditations/{file_name}"

    with open('assets/data/meditations.json', 'w') as f:
        json.dump(data, f, indent=2)
    
    print("Done!")
