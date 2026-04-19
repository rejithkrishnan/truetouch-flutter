from gtts import gTTS
import os

output_dir = r"D:\Coding\flutter\trutouch\assets\audio\voice"
os.makedirs(output_dir, exist_ok=True)

words = [
    "dog",
    "cat",
    "cow",
    "chicken",
    "lion",
    "elephant",
    "bird",
    "bear",
    "car",
    "bus",
    "train",
    "airplane",
    "ball",
    "spoon",
    "shoe",
    "clock",
    "apple",
    "banana",
    "flower",
    "tree",
]

for word in words:
    tts = gTTS(text=word, lang="en", tld="co.uk", slow=True)
    output_path = os.path.join(output_dir, f"{word}.mp3")
    tts.save(output_path)
    print(f"Saved: {output_path}")

print("\nDone! All 20 voice files generated.")
