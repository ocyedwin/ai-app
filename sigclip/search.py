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
    labels = index.search(text_vector, top_k)
    return labels


def main():
    parser = argparse.ArgumentParser(description='Search images using text query')
    parser.add_argument('--index', '-i', type=str, required=True,
                       help='Path to the index file')
    parser.add_argument('--query', '-q', type=str, required=True,
                       help='Text query to search for')
    parser.add_argument('--top-k', '-k', type=int, default=5,
                       help='Number of results to return (default: 5)')
    
    args = parser.parse_args()
    
    print(f"Index: {args.index}")
    print(f"Query: {args.query}")
    print(f"Top K: {args.top_k}")

    index = Index.restore(args.index)
    matches = search_index(args.query, index, args.top_k)

    for match in matches:
        print(f"Key: {match.key}, Distance: {match.distance}")

if __name__ == '__main__':
    main()
