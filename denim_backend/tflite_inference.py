import sys
import json
import numpy as np
import cv2
import os

# Suppress TensorFlow logging
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'

try:
    import tensorflow.lite as tflite
except ImportError:
    try:
        import tflite_runtime.interpreter as tflite
    except ImportError:
        print(json.dumps({"error": "TensorFlow Lite not installed"}))
        sys.exit(1)

# Path to your model
MODEL_PATH = os.path.join(os.path.dirname(__file__), "..", "..", "assets", "model", "denim_model.tflite")

CLASSES = [
  "138-CG", "1553-EL", "1583-EM", "1600-JK", "1780-A", "1830-BE", "1830-BZ",
  "1952-BC", "1965-G", "1976-W", "2034-A", "2051", "P140394I", "P140406BB",
  "P140541", "P140676", "P140813", "P140858", "P140901", "PRP180CA", "PRT0235AY"
]

def run_inference(image_path):
    if not os.path.exists(MODEL_PATH):
        return {"error": f"Model file not found at {MODEL_PATH}"}

    try:
        # Load Interpreter
        interpreter = tflite.Interpreter(model_path=MODEL_PATH)
        interpreter.allocate_tensors()

        input_details = interpreter.get_input_details()
        output_details = interpreter.get_output_details()

        # Preprocess Image
        img = cv2.imread(image_path)
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        img = cv2.resize(img, (224, 224))
        img = img.astype(np.float32) / 255.0
        img = np.expand_dims(img, axis=0)

        # Set Input
        interpreter.set_tensor(input_details[0]['index'], img)

        # Run Inference
        interpreter.invoke()

        # Get Outputs
        # Order depends on how the model was saved. Usually based on names.
        # We'll check the output shapes to identify them.
        main_output = None
        sub_output = None

        for output in output_details:
            shape = output['shape']
            if shape[1] == 21:
                main_output = interpreter.get_tensor(output['index'])[0]
            elif shape[1] == 5:
                sub_output = interpreter.get_tensor(output['index'])[0]

        if main_output is None or sub_output is None:
            return {"error": "Could not identify model output heads"}

        main_idx = np.argmax(main_output)
        sub_idx = np.argmax(sub_output)

        top_indices = np.argsort(main_output)[-5:][::-1]
        top_predictions = [
            {"class": CLASSES[i], "prob": float(main_output[i])} 
            for i in top_indices
        ]

        return {
            "main_class": CLASSES[main_idx],
            "subclass": int(sub_idx),
            "confidence_main": float(main_output[main_idx]),
            "confidence_sub": float(sub_output[sub_idx]),
            "top_predictions": top_predictions
        }

    except Exception as e:
        return {"error": str(e)}

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(json.dumps({"error": "No image path provided"}))
        sys.exit(1)

    image_path = sys.argv[1]
    result = run_inference(image_path)
    print(json.dumps(result))
