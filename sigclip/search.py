import cv2
import torch
import numpy as np
from PIL import Image
from usearch.index import Index
from transformers import AutoProcessor, AutoModel
import argparse

model = AutoModel.from_pretrained("google/siglip-so400m-patch14-384")
processor = AutoProcessor.from_pretrained("google/siglip-so400m-patch14-384")

def extract_text_vector(text):
    inputs = processor(text=[text], return_tensors="pt", padding=True)
    with torch.no_grad():
        text_features = model.get_text_features(**inputs)
    return text_features[0].numpy()

def search_index(text_query, index, top_k=5):
    text_vector = extract_text_vector(text_query).astype('float32')
    labels, distances = index.search(text_vector, top_k)
    return labels, distances


def main():
    index = Index.restore('index.sigclip')

    text_query = 'temple'
    text_vector = extract_text_vector(text_query).astype('float32')

    matches = index.search(text_vector, 5)

    for match in matches:
        print(match.key)
        print(match.distance)

if __name__ == '__main__':
    main()
