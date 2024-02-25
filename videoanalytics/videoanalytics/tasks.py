import logging
import telebot
import os
from celery import shared_task

LOGGING_LEVEL = logging.INFO
logging.basicConfig(format="%(asctime)s|%(levelname)s|%(message)s", level=LOGGING_LEVEL)
logging.getLogger("videoanalytics").setLevel(logging.ERROR)
logger = logging.getLogger(__name__)

person_text = """
**Новая детекция! - Человек!**
- Дата и время: {time}
- Уверенность модели: {conf}
""".strip()

token = os.environ.get("OVCTECH_TG_TOKEN")
TG_CHAT_IDS = [int(id) for id in os.environ.get("OVCTECH_TG_CHAT_IDS").split(",")]

BOT = telebot.TeleBot(token=token)


@shared_task
def send_photo_to_telegram(image_path, text):
    for chat_id in TG_CHAT_IDS:
        try:
            BOT.send_photo(
                chat_id,
                photo=open(image_path, "rb"),
                caption=text,
                parse_mode="Markdown",
            )
            logger.info(f"Sent photo to {chat_id} with text: {text}")
        except Exception as e:
            logger.info(f"Failed to send photo to {chat_id}\nError: {e}")
