import wave, math, random, struct
import os

duration = 30 # seconds
sample_rate = 44100
num_samples = duration * sample_rate

out_path = 'assets/audio/meditations/ambient_ocean.wav'
os.makedirs(os.path.dirname(out_path), exist_ok=True)

with wave.open(out_path, 'w') as w:
    w.setnchannels(1)
    w.setsampwidth(2)
    w.setframerate(sample_rate)
    
    brown = 0.0
    for i in range(num_samples):
        white = random.uniform(-0.1, 0.1)
        brown = 0.98 * brown + white
        
        # limit brown noise to avoid massive clipping
        brown = max(-1.0, min(1.0, brown))
        
        t = i / sample_rate
        # Create a surging wave effect every 8 seconds (0.125 Hz)
        # env goes from 0.1 to 1.0
        env = 0.1 + 0.9 * ((math.sin(2 * math.pi * 0.125 * t) + 1) / 2.0)
        
        # Add a secondary slower modulation for randomness
        env *= 0.5 + 0.5 * ((math.sin(2 * math.pi * 0.05 * t) + 1) / 2.0)
        
        val = int(brown * env * 32767)
        val = max(-32768, min(32767, val))
        
        w.writeframesraw(struct.pack('<h', val))
