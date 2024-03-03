import logging
import cv2
import psycopg2
import os

from collections.abc import Iterator
from django.http import StreamingHttpResponse
from django.http import HttpResponseServerError

from . import yolo

LOGGING_LEVEL = logging.ERROR
logging.basicConfig(format="%(asctime)s|%(levelname)s|%(message)s", level=LOGGING_LEVEL)
logging.getLogger("videoanalytics").setLevel(logging.ERROR)
logger = logging.getLogger(__name__)


def get_camera_url():
    host = os.environ.get("POSTGRES_HOST")
    port = os.environ.get("POSTGRES_PORT")
    database = os.environ.get("POSTGRES_DB")
    user = os.environ.get("POSTGRES_USER")
    password = os.environ.get("POSTGRES_PASSWORD")

    conn = psycopg2.connect(
        host=host,
        port=port,
        database=database,
        user=user,
        password=password,
    )
    cursor = conn.cursor()

    cursor.execute("SELECT camera_url FROM my_table WHERE id = 1")
    result = cursor.fetchone()

    cursor.close()
    conn.close()

    return result[0] if result else "/app/videoanalytics/test.mp4"


def gen_frames(camera_url: str | int) -> Iterator[bytes]:
    logger.info(f"Attempting to open camera URL:{camera_url}")
    if camera_url != 0:
        camera_url = get_camera_url()
    cap = cv2.VideoCapture(camera_url)
    if not cap.isOpened():
        logger.info("Failed to open camera.")
        return

    while True:
        try:
            success, frame = cap.read()
            if not success:
                logger.info("Failed to capture frame.")
                break
            else:
                logger.debug("Frame captured.")

                # Perform object detection with error handling
                try:
                    annotated_frame, detections = yolo.detect(frame)
                except Exception as detection_error:
                    logger.error(
                        "Error during object detection: %s", str(detection_error)
                    )
                    annotated_frame = None

                if annotated_frame is not None:
                    _, buffer = cv2.imencode(".jpg", annotated_frame)
                    annotated_frame_bytes = buffer.tobytes()

                    yield (
                        b"--frame\r\n"
                        b"Content-Type: image/jpeg\r\n\r\n"
                        + annotated_frame_bytes
                        + b"\r\n"
                    )
        except Exception as e:
            logger.error("Error capturing frame: %s", str(e))
            break


def video_feed(request) -> StreamingHttpResponse:
    camera_url = request.GET.get("camera_url", 0)
    try:
        return StreamingHttpResponse(
            gen_frames(camera_url),
            content_type="multipart/x-mixed-replace; boundary=frame",
        )
    except HttpResponseServerError as e:
        logger.error("Failed to open video feed:", str(e))
        return HttpResponseServerError("Failed to open video feed.")
