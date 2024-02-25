import logging
from datetime import datetime

import cv2
from .tasks import send_photo_to_telegram

LOGGING_LEVEL = logging.INFO
logging.basicConfig(format="%(asctime)s|%(levelname)s|%(message)s", level=LOGGING_LEVEL)
logging.getLogger("videoanalytics").setLevel(logging.ERROR)
logger = logging.getLogger(__name__)

last_save_time = datetime.now()
time_between_savings = 15


def save_and_send_detection(frame, class_name, confidence):
    global last_save_time
    current_time = datetime.now()
    if (current_time - last_save_time).total_seconds() >= time_between_savings:
        logger.info(
            f"Time has passed. Saving detection: {class_name} ({confidence:.2f})"
        )
        last_save_time = current_time
        way_to_save = f"/data/{current_time}__{class_name}__{100*confidence:.1f}%.jpg"
        text = f"**Новая детекция! - {class_name}**\n- - Дата и время: {current_time}\n- - Уверенность модели: {confidence:.2f}"
        cv2.imwrite(way_to_save, frame)
        send_photo_to_telegram.delay(way_to_save, text)
