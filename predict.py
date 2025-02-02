import sys
import time 
import numpy as np
import matplotlib.pyplot as plt
import tensorflow as tf
import tensorflow_hub as hub
import tensorflow_datasets as tfds
from PIL import Image
import argparse
import json

batch_size = 32
image_size = 224


class_names = {}

def process_image(image): 
   
    image = tf.cast(image, tf.float32)
    image= tf.image.resize(image, (image_size, image_size))
    image /= 255
    image = image.numpy()
    
    return image
    

def predict(image_path, model, top_k=5):
    
    image = Image.open(image_path)
    image = np.asarray(image)
    image = np.expand_dims(image,  axis=0)
    image = process_image(image)
    prob_list = model.predict(image)
    
    
    classes = []
    probs = []
    
    rank = prob_list[0].argsort()[::-1]
    
    for i in range(top_k):
        
        index = rank[i] + 1
        cls = class_names[str(index)]
        
        probs.append(prob_list[0][index])
        classes.append(cls)
    
    return probs, classes


if __name__ == '__main__':
    print('predict.py, running')
    
    parser = argparse.ArgumentParser()
    parser.add_argument('arg1')
    parser.add_argument('arg2')
    parser.add_argument('--top_k')
    parser.add_argument('--category_names') 
    
    
    args = parser.parse_args()
    print(args)
    
    print('arg1:', args.arg1)
    print('arg2:', args.arg2)
    print('top_k:', args.top_k)
    print('category_names:', args.category_names)
    
    image_path = args.arg1
    
    model = tf.keras.models.load_model(args.arg2 ,custom_objects={'KerasLayer':hub.KerasLayer} )
    top_k = args.top_k
    if top_k is None: 
        top_k = 5

    with open(args.category_names, 'r') as f:
        class_names = json.load(f)
   
    probs, classes = predict(image_path, model, top_k)
    
    print(probs)
    print(classes)