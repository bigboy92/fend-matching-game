import argparse
import tensorflow as tf
import numpy as np
import json
from PIL import Image

def process_image(image):
    """Preprocess the image for prediction."""
    image = tf.image.resize(image, (224, 224)) / 255.0
    return image.numpy()

def predict(image_path, model, top_k):
    """Predict the top K classes and probabilities for an image."""
    image = Image.open(image_path)
    image = np.expand_dims(process_image(np.asarray(image)), axis=0)
    predictions = model.predict(image)
    top_probs = np.sort(predictions[0])[-top_k:][::-1]
    top_classes = np.argsort(predictions[0])[-top_k:][::-1]
    return top_probs, top_classes

def load_class_names(category_names):
    """Load the category names from a JSON file."""
    with open(category_names, 'r') as f:
        class_names = json.load(f)
    return class_names

def main():
    parser = argparse.ArgumentParser(description="Flower Classification Prediction")
    parser.add_argument('image_path', type=str, help="Path to the image")
    parser.add_argument('model_path', type=str, help="Path to the saved model")
    parser.add_argument('--top_k', type=int, default=5, help="Return top K most likely classes")
    parser.add_argument('--category_names', type=str, default=None, help="Path to category names JSON file")

    args = parser.parse_args()

    # Load the model
    model = tf.keras.models.load_model(args.model_path, 
                                       custom_objects={'KerasLayer': tf.keras.applications.MobileNetV2})

    # Predict
    probs, classes = predict(args.image_path, model, args.top_k)

    # Map classes to names if category names file is provided
    if args.category_names:
        class_names = load_class_names(args.category_names)
        class_labels = [class_names[str(cls)] for cls in classes]
    else:
        class_labels = classes

    # Print results
    for i in range(len(probs)):
        print(f"{class_labels[i]}: {probs[i]:.4f}")

if __name__ == "__main__":
    main()
