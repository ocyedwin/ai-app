import os
import cv2
import torch
import numpy as np
from PIL import Image
from usearch.index import Index
from transformers import AutoProcessor, AutoModel
import argparse


model = AutoModel.from_pretrained("google/siglip-so400m-patch14-384")
processor = AutoProcessor.from_pretrained("google/siglip-so400m-patch14-384")

# TODO: increase higher batch size
def extract_vector(image_path):
    image = Image.open(image_path).convert("RGB")
    inputs = processor(images=image, return_tensors="pt")
    with torch.no_grad():
        image_features = model.get_image_features(**inputs)
    return image_features[0].numpy() # batch size of 1 returns (batch_size, feature_dim) which is first (and only) item


def main():
    parser = argparse.ArgumentParser(description='Process video and create image embeddings index')
    parser.add_argument('video_path', type=str, help='Path to the input video file')
    args = parser.parse_args()

    file_name = args.video_path.split('/')[-1]
    # create a working directory for the video using absolute path
    working_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'tmp', file_name))
    os.makedirs(working_dir, exist_ok=True)

    cap = cv2.VideoCapture(args.video_path)
    fps = cap.get(cv2.CAP_PROP_FPS)

    image_paths = []
    vectors = []
    skip_duration = 0  # 10 minutes
    frame_interval = 1  # seconds between frames

    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    total_duration = total_frames / fps
    current_time = skip_duration

    while current_time < total_duration:
        frame_number = int(fps * current_time)
        cap.set(cv2.CAP_PROP_POS_FRAMES, frame_number)
        ret, image = cap.read()

        if not ret:
            print(f"Failed to read frame at {current_time} seconds. Stopping iteration.")
            break

        image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        pil_image = Image.fromarray(image_rgb)

        image_path = f'{working_dir}/frame_{int(current_time/frame_interval)}.png'
        pil_image.save(image_path)

        image_paths.append(image_path)
        vectors.append(extract_vector(image_path))
        
        current_time += frame_interval

    vectors = np.array(vectors).astype('float32')

    ndim = vectors.shape[1]
    index = Index(ndim=ndim)
    index.add(None, vectors, log=True)

    video_name = args.video_path.split('/')[-1]

    index.save(f'{working_dir}/index.${video_name}')

if __name__ == '__main__':
    main()