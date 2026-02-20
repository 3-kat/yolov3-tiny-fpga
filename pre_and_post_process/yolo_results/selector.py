import os
import shutil

# Configuration
SOURCE_DIR = "/home/kal-thir/yolo_images"  # Where your laptop stores JPGs
PROJECT_DIR = "/home/kal-thir/qbbbbbb_yolo_fresh/pygen0"
LOADIMG_PATH = "/home/kal-thir/qbbbbbb_yolo_fresh/pygen0/loadimg.c"

def select_and_update():
    # 1. List images
    images = [f for f in os.listdir(SOURCE_DIR) if f.endswith('.jpg')]
    for i, name in enumerate(images):
        print(f"[{i}] {name}")
    
    choice = int(input("\nEnter the number of the image you want to load: "))
    selected_img = images[choice]
    
    # 2. Copy image to project folder
    dest_path = os.path.join(PROJECT_DIR, selected_img)
    shutil.copy(os.path.join(SOURCE_DIR, selected_img), dest_path)
    print(f"✅ Copied {selected_img} to pygen0")

    # 3. Update loadimg.c
    with open(LOADIMG_PATH, 'r') as f:
        lines = f.readlines()

    with open(LOADIMG_PATH, 'w') as f:
        for line in lines:
            if 'char* filename =' in line:
                f.write(f'char* filename = "{dest_path}";\n')
            else:
                f.write(line)
    print(f"✅ Updated loadimg.c with new filename.")

if __name__ == "__main__":
    select_and_update()
