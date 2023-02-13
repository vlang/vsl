# TODO: Convert this to V code using `VTL` and `vlib` for image management
import numpy as np
from PIL import Image
import os

height = 500
width = 500
path = './outputs/' #
file_names = os.listdir(path)
for name in file_names:
    file_name, file_ext = os.path.splitext(name)
    if file_ext == ".bin":
        with open(path + name, 'rb') as f:
            binary_data = f.read()
        img_array = np.frombuffer(binary_data, dtype=np.uint8)
        img_array = img_array.reshape((height, width, 4))
        img = Image.fromarray(img_array, mode='RGBA')
        img.save(path + file_name + '.py.png')
