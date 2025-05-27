from pathlib import Path
from tempfile import NamedTemporaryFile

from flask import Flask, request, jsonify
from flask_cors import CORS
from ultralytics import YOLO

MODEL_PATH = Path(__file__).with_name("best.pt")
CONF_THRESHOLD = 0.25
PORT = 5050

print("[INFO] loading model…")
model = YOLO(str(MODEL_PATH))
print("[INFO] classes:", model.names)

app = Flask(__name__)
CORS(app)

def _save_tmp(file_storage) -> Path:
    tmp = NamedTemporaryFile(delete=False, suffix=Path(file_storage.filename).suffix)
    file_storage.save(tmp.name)
    return Path(tmp.name)

@app.route("/predict", methods=["POST"])
def predict():
    if "image" not in request.files:
        return jsonify({"error": "image field missing"}), 400

    img_path = _save_tmp(request.files["image"])

    try:
        result = model(img_path, conf=CONF_THRESHOLD)[0]
    except Exception as e:
        img_path.unlink(missing_ok=True)
        return jsonify({"error": str(e)}), 500

    detections = [
        {
            "label": model.names.get(int(box.cls[0]), str(int(box.cls[0]))),
            "confidence": float(box.conf[0]),
        }
        for box in result.boxes
    ]

    img_path.unlink(missing_ok=True)
    return jsonify({"predictions": detections})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=PORT)
