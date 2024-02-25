import logging
import os

import cv2
from ultralytics import YOLO

from . import constants as CONST
from . import utils

LOGGING_LEVEL = logging.ERROR
logging.basicConfig(format="%(asctime)s|%(levelname)s|%(message)s", level=LOGGING_LEVEL)
logging.getLogger("videoanalytics").setLevel(logging.ERROR)
logger = logging.getLogger(__name__)


current_dir = os.path.dirname(os.path.abspath(__file__))
models = [
    YOLO(f"{current_dir}/modules/{x}.pt").to("cpu") for x in CONST.CONNECTED_MODULES
]


def draw_metadata(frame, detections):
    for i in range(len(detections)):
        class_name = detections[i]["class_name"]
        confidence = detections[i]["confidence"]
        color = tuple(CONST.COLORS[CONST.WANTED_CLASSES[class_name]["color"]])
        if (
            class_name in CONST.WANTED_CLASSES
            and confidence > CONST.WANTED_CLASSES[class_name]["confidence"]
        ):
            # bounding boxes
            box = detections[i]["box"]
            x1, y1, x2, y2 = (
                round(box[0]),
                round(box[1]),
                round(box[2]),
                round(box[3]),
            )
            cv2.rectangle(frame, (x1, y1), (x2, y2), color, 2)
            # label
            label = f"{class_name} ({confidence:.2f})"
            cv2.putText(
                frame, label, (x1 - 10, y1 - 10), cv2.FONT_HERSHEY_SIMPLEX, 2, color, 2
            )
            # save to /data
            logger.info(f"Saving detection: {label}")
            utils.save_and_send_detection(
                frame=frame, class_name=class_name, confidence=confidence
            )
    return frame


def detect(frame):
    detections = []

    for model in models:
        results = model(frame, conf=0.6)

        for detected_object in results:
            boxes = detected_object.boxes
            keypoints = None
            if detected_object.keypoints is not None:
                keypoints = detected_object.keypoints.data
            for box in boxes:
                xyxy = box.xyxy[0].tolist()
                class_id = int(box.cls)
                class_name = model.names[class_id]
                confidence = box.conf[0].tolist()
                detection = {
                    "class_id": class_id,
                    "class_name": class_name,
                    "confidence": confidence,
                    "box": xyxy,
                    "keypoints": keypoints,
                }
                detections.append(detection)
    logger.info(f"Detected {len(detections)} objects: {detections}")
    return (draw_metadata(frame, detections), detections)
