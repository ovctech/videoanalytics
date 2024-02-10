import logging
import cv2

from collections.abc import Iterator
from django.http import StreamingHttpResponse
from django.shortcuts import render
from django.http import HttpResponseServerError

LOGGING_LEVEL = logging.INFO
logging.basicConfig(format="%(asctime)s|%(levelname)s|%(message)s", level=LOGGING_LEVEL)
logging.getLogger("videoanalytics").setLevel(logging.ERROR)
logger = logging.getLogger(__name__)


def video_demo(request):
    return render(request, "video_demo.html")


def gen_frames(camera_url: str | int) -> Iterator[bytes]:
    logger.info(f"Attempting to open camera URL:{camera_url}")
    if camera_url != 0:
        camera_url = "/app/videoanalytics/test.mp4"
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
                ret, buffer = cv2.imencode(".jpg", frame)
                frame = buffer.tobytes()
                yield (
                    b"--frame\r\n" b"Content-Type: image/jpeg\r\n\r\n" + frame + b"\r\n"
                )
        except Exception as e:
            logger.error("Error capturing frame:", str(e))
            break
    cap.release()


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
