import sys
import json
import numpy as np
import cv2
import os
import time

# Suppress TensorFlow logging
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'

try:
    import tensorflow as tf
except ImportError:
    print(json.dumps({"error": "TensorFlow (full) not installed. Required for EfficientNet preprocessing."}))
    sys.exit(1)

# Configuration
MODEL_PATH = os.path.join(os.path.dirname(__file__), "..", "assets", "model", "denim_model.tflite")
CLASSES = [
    "138-CG", "1553-EL", "1583-EM", "1600-JK", "1780-A", "1830-BE", "1830-BZ",
    "1952-BC", "1965-G", "1976-W", "2034-A", "2051", "P140394I", "P140406BB",
    "P140541", "P140676", "P140813", "P140858", "P140901", "PRP180CA", "PRT0235AY"
]

class InferenceEngine:
    def __init__(self, model_path):
        if not os.path.exists(model_path):
            raise FileNotFoundError(f"Model not found at {model_path}")
        
        self.interpreter = tf.lite.Interpreter(model_path=model_path)
        self.interpreter.allocate_tensors()
        self.input_details = self.interpreter.get_input_details()
        self.output_details = self.interpreter.get_output_details()
        
        # Verify Input
        # print(f"Input Details: {self.input_details[0]['shape']}, {self.input_details[0]['dtype']}")
        
        # Auto-identify indices for Main (21) and Sub (5) heads by checking shapes
        self.main_head_idx = None
        self.sub_head_idx = None
        
        for output in self.output_details:
            shape = output['shape']
            if shape[-1] == 21:
                self.main_head_idx = output['index']
            elif shape[-1] == 5:
                self.sub_head_idx = output['index']
        
        if self.main_head_idx is None or self.sub_head_idx is None:
            sys.stderr.write("Warning: Could not auto-detect output heads by shape (21 and 5). Falling back to indices [0] and [1].\n")
            self.main_head_idx = self.output_details[0]['index']
            self.sub_head_idx = self.output_details[1]['index']

    def preprocess(self, image_path):
        # 1. Load image using OpenCV
        img = cv2.imread(image_path)
        if img is None:
            raise ValueError(f"Could not read image at {image_path}")
        
        # Handle EXIF rotation (critical for mobile parity)
        try:
            from PIL import Image, ImageOps
            pil_img = Image.open(image_path)
            pil_img = ImageOps.exif_transpose(pil_img)
            img = cv2.cvtColor(np.array(pil_img), cv2.COLOR_RGB2BGR)
        except:
            pass

        # 2. Convert BGR to RGB
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

        # 3. Resize EXACTLY to (224, 224)
        img = cv2.resize(img, (224, 224), interpolation=cv2.INTER_LINEAR)

        # 4. Match training pipeline exactly
        # The model has an internal Lambda layer that multiplies by 255.
        # We must provide input in [0, 1] range.
        img = img.astype("float32") / 255.0

        # 6. Add batch dimension
        return np.expand_dims(img, axis=0)

    def predict(self, image_path):
        try:
            input_data = self.preprocess(image_path)
            self.interpreter.set_tensor(self.input_details[0]['index'], input_data)
            self.interpreter.invoke()
            
            main_logits = self.interpreter.get_tensor(self.main_head_idx)[0]
            sub_logits = self.interpreter.get_tensor(self.sub_head_idx)[0]
            
            # DEBUG: Print raw values to stderr so they don't break the Node.js JSON parser
            sys.stderr.write(f"DEBUG RAW - Main Max: {np.max(main_logits):.4f}, Sub Max: {np.max(sub_logits):.4f}\n")
            sys.stderr.write(f"DEBUG RAW - Main Sum: {np.sum(main_logits):.4f}\n")
            sys.stderr.flush()
            
            main_idx = np.argmax(main_logits)
            sub_idx = np.argmax(sub_logits)
            
            # Debug Log: Top 3 Predictions
            top_indices = np.argsort(main_logits)[-5:][::-1]
            top_predictions = [
                {"class": CLASSES[i], "prob": float(main_logits[i])} 
                for i in top_indices
            ]
            
            # Print debug for consistency check
            # print(f"DEBUG: Top 3 -> {top_predictions[:3]}")
            
            return {
                "main_class": CLASSES[main_idx],
                "subclass": int(sub_idx),
                "confidence_main": float(main_logits[main_idx]),
                "confidence_sub": float(sub_logits[sub_idx]),
                "top_predictions": top_predictions
            }
        except Exception as e:
            return {"error": str(e)}

def main():
    try:
        engine = InferenceEngine(MODEL_PATH)
    except Exception as e:
        print(json.dumps({"error": f"Initialization failed: {str(e)}"}))
        sys.exit(1)

    while True:
        line = sys.stdin.readline()
        if not line:
            break
            
        try:
            request = json.loads(line)
            command = request.get("command")
            
            if command == "predict":
                path = request.get("path")
                result = engine.predict(path)
                print(json.dumps(result))
            
            elif command == "batch":
                paths = request.get("paths", [])
                results = [engine.predict(p) for p in paths]
                print(json.dumps({"results": results}))
            
            sys.stdout.flush()
        except Exception as e:
            print(json.dumps({"error": f"Parse error: {str(e)}"}))
            sys.stdout.flush()

if __name__ == "__main__":
    main()
