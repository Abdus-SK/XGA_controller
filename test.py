# hex generator
from PIL import Image

IMG_PATH = "rick.jpg"      # your input image
OUT_PATH = "rick.hex"
H_a, V_a = 1024, 768

img = Image.open(IMG_PATH).convert("RGB")
img = img.resize((H_a, V_a))   # crop instead of resize if you want no distortion

with open(OUT_PATH, "w") as f:
    for v in range(V_a):
        for h in range(H_a):
            r, g, b = img.getpixel((h, v))
            f.write(f"{r:02x}{g:02x}{b:02x}\n")   # matches your 24-bit {R,G,B} packing