#!/usr/bin/env python
# coding: utf-8

# # Your First AI application
# 
# Going forward, AI algorithms will be incorporated into more and more everyday applications. For example, you might want to include an image classifier in a smart phone app. To do this, you'd use a deep learning model trained on hundreds of thousands of images as part of the overall application architecture. A large part of software development in the future will be using these types of models as common parts of applications. 
# 
# In this project, you'll train an image classifier to recognize different species of flowers. You can imagine using something like this in a phone app that tells you the name of the flower your camera is looking at. In practice you'd train this classifier, then export it for use in your application. We'll be using [this dataset](http://www.robots.ox.ac.uk/~vgg/data/flowers/102/index.html) from Oxford of 102 flower categories, you can see a few examples below. 
# 
# <img src='assets/Flowers.png' width=500px>
# 
# The project is broken down into multiple steps:
# 
# * Load the image dataset and create a pipeline.
# * Build and Train an image classifier on this dataset.
# * Use your trained model to perform inference on flower images.
# 
# We'll lead you through each part which you'll implement in Python.
# 
# When you've completed this project, you'll have an application that can be trained on any set of labeled images. Here your network will be learning about flowers and end up as a command line application. But, what you do with your new skills depends on your imagination and effort in building a dataset. For example, imagine an app where you take a picture of a car, it tells you what the make and model is, then looks up information about it. Go build your own dataset and make something new.

# ## Import Resources

# In[2]:


import tensorflow as tf
from tensorflow.keras.preprocessing import image_dataset_from_directory
import numpy as np
import matplotlib.pyplot as plt
import pathlib
import tensorflow_datasets as tfds
import tensorflow_hub as hub
from tensorflow.keras import layers, models
from tensorflow.keras.models import load_model
from PIL import Image
import matplotlib.pyplot as plt
import json 


# ## Load the Dataset
# 
# Here you'll use `tensorflow_datasets` to load the [Oxford Flowers 102 dataset](https://www.tensorflow.org/datasets/catalog/oxford_flowers102). This dataset has 3 splits: `'train'`, `'test'`, and `'validation'`.  You'll also need to make sure the training data is normalized and resized to 224x224 pixels as required by the pre-trained networks.
# 
# The validation and testing sets are used to measure the model's performance on data it hasn't seen yet, but you'll still need to normalize and resize the images to the appropriate size.

# In[35]:


dataset, info = tfds.load('oxford_flowers102', with_info=True, as_supervised=True)
BATCH_SIZE = 32 

train_dataset = dataset['train'].map(preprocess).batch(BATCH_SIZE).shuffle(1000)
val_dataset = dataset['validation'].map(preprocess).batch(BATCH_SIZE)
test_dataset = dataset['test'].map(preprocess).batch(BATCH_SIZE)
print(info)


# ## Explore the Dataset

# In[36]:


num_train_examples = info.splits['train'].num_examples
num_val_examples = info.splits['validation'].num_examples
num_test_examples = info.splits['test'].num_examples

num_classes = info.features['label'].num_classes

print(f"Number of training examples: {num_train_examples}")
print(f"Number of validation examples: {num_val_examples}")
print(f"Number of test examples: {num_test_examples}")
print(f"Number of classes: {num_classes}")


# In[37]:


for image, label in train_dataset.take(3):
    print(f"Image shape: {image.shape}")
    print(f"Label: {label.numpy()}")


# In[38]:


for image, label in train_dataset.take(1):
    image = image[0] 
    
   
    plt.imshow(image.numpy())  
    plt.title(f"Label: {label.numpy()}") 
    plt.axis('off') 
    plt.show()


# ### Label Mapping
# 
# You'll also need to load in a mapping from label to category name. You can find this in the file `label_map.json`. It's a JSON object which you can read in with the [`json` module](https://docs.python.org/3.7/library/json.html). This will give you a dictionary mapping the integer coded labels to the actual names of the flowers.

# In[39]:


with open('label_map.json', 'r') as f:
    class_names = json.load(f)


# In[40]:


class_names = info.features['label'].int2str

for image, label in train_dataset.take(1):
    label_value = label[0].numpy().item()  
    flower_name = class_names(label_value)  
    
    plt.imshow(tf.squeeze(image[0]).numpy())  
    plt.title(f"Flower: {flower_name}")
    plt.axis('off')
    plt.show()

    print(f"Label: {label_value}, Flower Name: {flower_name}")


# ## Create Pipeline

# In[41]:


def preprocess(image, label):
   
    image = tf.image.resize(image, [224, 224])
    
    image = image / 255.0
    return image, label


# # Build and Train the Classifier
# 
# Now that the data is ready, it's time to build and train the classifier. You should use the MobileNet pre-trained model from TensorFlow Hub to get the image features. Build and train a new feed-forward classifier using those features.
# 
# We're going to leave this part up to you. If you want to talk through it with someone, chat with your fellow students! 
# 
# Refer to the rubric for guidance on successfully completing this section. Things you'll need to do:
# 
# * Load the MobileNet pre-trained network from TensorFlow Hub.
# * Define a new, untrained feed-forward network as a classifier.
# * Train the classifier.
# * Plot the loss and accuracy values achieved during training for the training and validation set.
# * Save your trained model as a Keras model. 
# 
# We've left a cell open for you below, but use as many as you need. Our advice is to break the problem up into smaller parts you can run separately. Check that each part is doing what you expect, then move on to the next. You'll likely find that as you work through each part, you'll need to go back and modify your previous code. This is totally normal!
# 
# When training make sure you're updating only the weights of the feed-forward network. You should be able to get the validation accuracy above 70% if you build everything right.
# 
# **Note for Workspace users:** One important tip if you're using the workspace to run your code: To avoid having your workspace disconnect during the long-running tasks in this notebook, please read in the earlier page in this lesson called Intro to GPU Workspaces about Keeping Your Session Active. You'll want to include code from the workspace_utils.py module. Also, If your model is over 1 GB when saved as a checkpoint, there might be issues with saving backups in your workspace. If your saved checkpoint is larger than 1 GB (you can open a terminal and check with `ls -lh`), you should reduce the size of your hidden layers and train again.

# In[42]:


IMAGE_SIZE = 224 


mobilenet_url = "https://tfhub.dev/google/tf2-preview/mobilenet_v2/feature_vector/4"
feature_extractor = hub.KerasLayer(mobilenet_url, input_shape=(IMAGE_SIZE, IMAGE_SIZE, 3), trainable=False)

model = models.Sequential([
    feature_extractor,
    layers.Dense(1024, activation='relu'),
    layers.Dropout(0.2),
    layers.Dense(102, activation='softmax') 
])


model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])


# In[43]:


history = model.fit(
    train_dataset,
    validation_data=val_dataset,
    epochs=10  
)


acc = history.history['accuracy']
val_acc = history.history['val_accuracy']
loss = history.history['loss']
val_loss = history.history['val_loss']


epochs_range = range(len(acc))

plt.figure(figsize=(12, 6))


plt.subplot(1, 2, 1)
plt.plot(epochs_range, acc, label='Training Accuracy', color='blue')
plt.plot(epochs_range, val_acc, label='Validation Accuracy', color='orange')
plt.legend(loc='lower right')
plt.title('Training and Validation Accuracy')
plt.xlabel('Epochs')
plt.ylabel('Accuracy')

plt.subplot(1, 2, 2)
plt.plot(epochs_range, loss, label='Training Loss', color='blue')
plt.plot(epochs_range, val_loss, label='Validation Loss', color='orange')
plt.legend(loc='upper right')
plt.title('Training and Validation Loss')
plt.xlabel('Epochs')
plt.ylabel('Loss')

plt.tight_layout()
plt.show()


# ## Testing your Network
# 
# It's good practice to test your trained network on test data, images the network has never seen either in training or validation. This will give you a good estimate for the model's performance on completely new images. You should be able to reach around 70% accuracy on the test set if the model has been trained well.

# In[44]:


test_loss, test_accuracy = model.evaluate(test_dataset)
print(f"Test Loss: {test_loss}")
print(f"Test Accuracy: {test_accuracy * 100:.2f}%")


# ## Save the Model
# 
# Now that your network is trained, save the model so you can load it later for making inference. In the cell below save your model as a Keras model (*i.e.* save it as an HDF5 file).

# In[45]:


# TODO: Save your trained model as a Keras model.
model.save('flower_classifier_model.keras')

print("Model saved successfully as 'flower_classifier_model.keras'")


# ## Load the Keras Model
# 
# Load the Keras model you saved above.

# In[46]:


# TODO: Load the Keras model


with tf.keras.utils.custom_object_scope({'KerasLayer': hub.KerasLayer}):
    model = load_model('flower_classifier_model.keras') 

print("Model loaded successfully!")


# # Inference for Classification
# 
# Now you'll write a function that uses your trained network for inference. Write a function called `predict` that takes an image, a model, and then returns the top $K$ most likely class labels along with the probabilities. The function call should look like: 
# 
# ```python
# probs, classes = predict(image_path, model, top_k)
# ```
# 
# If `top_k=5` the output of the `predict` function should be something like this:
# 
# ```python
# probs, classes = predict(image_path, model, 5)
# print(probs)
# print(classes)
# > [ 0.01558163  0.01541934  0.01452626  0.01443549  0.01407339]
# > ['70', '3', '45', '62', '55']
# ```
# 
# Your `predict` function should use `PIL` to load the image from the given `image_path`. You can use the [Image.open](https://pillow.readthedocs.io/en/latest/reference/Image.html#PIL.Image.open) function to load the images. The `Image.open()` function returns an `Image` object. You can convert this `Image` object to a NumPy array by using the `np.asarray()` function.
# 
# The `predict` function will also need to handle pre-processing the input image such that it can be used by your model. We recommend you write a separate function called `process_image` that performs the pre-processing. You can then call the `process_image` function from the `predict` function. 
# 
# ### Image Pre-processing
# 
# The `process_image` function should take in an image (in the form of a NumPy array) and return an image in the form of a NumPy array with shape `(224, 224, 3)`.
# 
# First, you should convert your image into a TensorFlow Tensor and then resize it to the appropriate size using `tf.image.resize`.
# 
# Second, the pixel values of the input images are typically encoded as integers in the range 0-255, but the model expects the pixel values to be floats in the range 0-1. Therefore, you'll also need to normalize the pixel values. 
# 
# Finally, convert your image back to a NumPy array using the `.numpy()` method.

# In[47]:


# TODO: Create the process_image function
def process_image(image_path):
   
    image = Image.open(image_path)
    
    
    image = tf.convert_to_tensor(image)
    
   
    image = tf.image.resize(image, (224, 224))
    
    
    image = image / 255.0
    
    
    return image.numpy()


# To check your `process_image` function we have provided 4 images in the `./test_images/` folder:
# 
# * cautleya_spicata.jpg
# * hard-leaved_pocket_orchid.jpg
# * orange_dahlia.jpg
# * wild_pansy.jpg
# 
# The code below loads one of the above images using `PIL` and plots the original image alongside the image produced by your `process_image` function. If your `process_image` function works, the plotted image should be the correct size. 

# In[48]:


from PIL import Image

image_path = './test_images/hard-leaved_pocket_orchid.jpg'
im = Image.open(image_path)
test_image = np.asarray(im)

processed_test_image = process_image(image_path)  # Change this line


fig, (ax1, ax2) = plt.subplots(figsize=(10, 10), ncols=2)
ax1.imshow(test_image)
ax1.set_title('Original Image')
ax2.imshow(processed_test_image)
ax2.set_title('Processed Image')
plt.tight_layout()
plt.show()


# Once you can get images in the correct format, it's time to write the `predict` function for making inference with your model.
# 
# ### Inference
# 
# Remember, the `predict` function should take an image, a model, and then returns the top $K$ most likely class labels along with the probabilities. The function call should look like: 
# 
# ```python
# probs, classes = predict(image_path, model, top_k)
# ```
# 
# If `top_k=5` the output of the `predict` function should be something like this:
# 
# ```python
# probs, classes = predict(image_path, model, 5)
# print(probs)
# print(classes)
# > [ 0.01558163  0.01541934  0.01452626  0.01443549  0.01407339]
# > ['70', '3', '45', '62', '55']
# ```
# 
# Your `predict` function should use `PIL` to load the image from the given `image_path`. You can use the [Image.open](https://pillow.readthedocs.io/en/latest/reference/Image.html#PIL.Image.open) function to load the images. The `Image.open()` function returns an `Image` object. You can convert this `Image` object to a NumPy array by using the `np.asarray()` function.
# 
# **Note:** The image returned by the `process_image` function is a NumPy array with shape `(224, 224, 3)` but the model expects the input images to be of shape `(1, 224, 224, 3)`. This extra dimension represents the batch size. We suggest you use the `np.expand_dims()` function to add the extra dimension. 

# In[49]:


# TODO: Create the predict function
def predict(image_path, model, top_k=5):

    processed_image = process_image(image_path)
    
  
    processed_image = np.expand_dims(processed_image, axis=0)
    
  
    predictions = model.predict(processed_image)
  
    top_k_indices = predictions[0].argsort()[-top_k:][::-1] 
    top_k_probs = predictions[0][top_k_indices]  
    top_k_classes = top_k_indices.astype(str)
    
    return top_k_probs, top_k_classes



# # Sanity Check
# 
# It's always good to check the predictions made by your model to make sure they are correct. To check your predictions we have provided 4 images in the `./test_images/` folder:
# 
# * cautleya_spicata.jpg
# * hard-leaved_pocket_orchid.jpg
# * orange_dahlia.jpg
# * wild_pansy.jpg
# 
# In the cell below use `matplotlib` to plot the input image alongside the probabilities for the top 5 classes predicted by your model. Plot the probabilities as a bar graph. The plot should look like this:
# 
# <img src='assets/inference_example.png' width=600px>
# 
# You can convert from the class integer labels to actual flower names using `class_names`. 

# In[53]:






# In[58]:


def plot_prediction(image_path, model, top_k=5):
    probs, classes = predict(image_path, model, top_k)

  
    print("Classes:", classes)
    print("Length of class_names:", len(class_names)) 

    try:
       
        top_class_names = [class_names[str(int(cls))] for cls in classes]
    except IndexError as e:
        print(f"IndexError: {e} - Check if class indices are within the range of class_names.")
        return
    except ValueError as e:
        print(f"ValueError: {e} - Unable to convert class index to integer.")
        return
    except KeyError as e:
        print(f"KeyError: {e} - Check if class indices exist in class_names.")
        return

  
    img = Image.open(image_path)

   
    fig, (ax1, ax2) = plt.subplots(figsize=(10, 5), ncols=2)

    
    ax1.imshow(img)
    ax1.set_title('Input Image')
    ax1.axis('off')

 
    ax2.barh(top_class_names, probs, color='blue')
    ax2.set_xlim(0, 1)
    ax2.set_title('Class Probability')

    plt.tight_layout()
    plt.show()


with open('label_map.json', 'r') as f:
    class_names = json.load(f)

image_path = './test_images/hard-leaved_pocket_orchid.jpg'
plot_prediction(image_path, model, top_k=5)


# In[63]:





# In[ ]:





# In[ ]:




