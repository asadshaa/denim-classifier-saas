from fastapi import FastAPI, UploadFile, File, HTTPException
import uvicorn
import numpy as np
import cv2
import tensorflow as tf
import os
import json
import time
from typing import List

app = FastAPI(title="DenimAI Inference Service")

# Configuration
MODEL_PATH = os.path.join(os.path.dirname(__file__), "..", "assets", "model", "denim_model.tflite")
CLASSES = [
    "138-CG", "1553-EL", "1583-EM", "1600-JK", "1780-A", "1830-BE", "1830-BZ",
    "1952-BC", "1965-G", "1976-W", "2034-A", "2051", "P140394I", "P140406BB",
    "P140541", "P140676", "P140813", "P140858", "P140901", "PRP180CA", "PRT0235AY"
]

# Load TFLite Model once at startup
try:
    interpreter = tf.lite.Interpreter(model_path=MODEL_PATH)
    interpreter.allocate_tensors()
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    
    # Auto-detect heads
    main_idx = None
    sub_idx = None
    for output in output_details:
        if output['shape'][-1] == 21: main_idx = output['index']
        elif output['shape'][-1] == 5: sub_idx = output['index']
except Exception as e:
    print(f"Error loading model: {e}")

def preprocess(image_bytes):
    # Decode bytes to OpenCV image
    nparr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    
    # BGR to RGB
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    
    # Resize with Bilinear Interpolation to match Mobile
    img = cv2.resize(img, (224, 224), interpolation=cv2.INTER_LINEAR)
    
    # MATCHING TRAINING PIPELINE EXACTLY
    # The model has a Lambda(img * 255) layer internally, so we MUST 
    # provide input in the [0, 1] range as per your 'test_random_predictions' code.
    img = img.astype("float32") / 255.0
    
    return np.expand_dims(img, axis=0)

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    try:
        contents = await file.read()
        input_data = preprocess(contents)
        
        interpreter.set_tensor(input_details[0]['index'], input_data)
        
        start_time = time.perf_counter()
        interpreter.invoke()
        inference_time_ms = (time.perf_counter() - start_time) * 1000
        
        main_logits = interpreter.get_tensor(main_idx)[0]
        sub_logits = interpreter.get_tensor(sub_idx)[0]
        
        # Log values for parity check
        print(f"Inference complete. Max Main: {np.max(main_logits):.4f}")
        
        main_class_idx = np.argmax(main_logits)
        sub_class_idx = np.argmax(sub_logits)
        
        top_indices = np.argsort(main_logits)[-5:][::-1]
        top_predictions = [
            {"class": CLASSES[i], "prob": float(main_logits[i])} 
            for i in top_indices
        ]
        
        return {
            "main_class": CLASSES[main_class_idx],
            "subclass": int(sub_class_idx),
            "confidence_main": float(main_logits[main_class_idx]),
            "confidence_sub": float(sub_logits[sub_class_idx]),
            "top_predictions": top_predictions,
            "inference_time_ms": round(inference_time_ms, 2),
            "model_version": "v1.0"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
