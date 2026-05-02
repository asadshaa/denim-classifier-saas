import sys
import os

def generate_simulated_heatmap(image_path, output_path):
    try:
        import cv2
        import numpy as np
        
        # Mode 2: Fallback Simulated Heatmap
        # In Mode 1 (True Grad-CAM), we would load the .h5 model here and calculate gradients.
        
        # Load original image
        img = cv2.imread(image_path)
        if img is None:
            print("Error: Could not read image.")
            sys.exit(1)
            
        height, width, _ = img.shape
        
        # Create a simulated "attention" map based on center focus and some noise
        heatmap = np.zeros((height, width), dtype=np.float32)
        
        # Create a 2D Gaussian mask focused near the center but slightly randomized
        center_x = width // 2 + int(np.random.normal(0, width // 10))
        center_y = height // 2 + int(np.random.normal(0, height // 10))
        
        y, x = np.ogrid[-center_y:height-center_y, -center_x:width-center_x]
        sigma = min(width, height) / 3
        mask = np.exp(-(x*x + y*y) / (2.*sigma*sigma))
        
        # Add some high-frequency noise to simulate texture edge attention
        noise = np.random.normal(0, 0.2, (height, width))
        heatmap = np.clip(mask + noise, 0, 1)
        
        # Convert to 8-bit
        heatmap = np.uint8(255 * heatmap)
        
        # Apply JET colormap
        heatmap_colored = cv2.applyColorMap(heatmap, cv2.COLORMAP_JET)
        
        # Superimpose the heatmap on original image
        intensity = 0.5
        superimposed_img = heatmap_colored * intensity + img * (1.0 - intensity)
        
        # Save
        cv2.imwrite(output_path, superimposed_img)
        print("SUCCESS")
        
    except ImportError:
        # Fallback if cv2 is not installed: just say missing dependency
        print("ERROR_CV2_MISSING")
        sys.exit(1)
    except Exception as e:
        print(f"Error: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python generate_heatmap.py <input_image_path> <output_image_path>")
        sys.exit(1)
        
    input_path = sys.argv[1]
    output_path = sys.argv[2]
    
    generate_simulated_heatmap(input_path, output_path)
