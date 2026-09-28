FROM python:3.14-slim

WORKDIR /app

COPY requirements.txt /app/

RUN pip install --no-cache-dir requirements.txt

EXPOSE 5000

CMD ["python", "test_app.py"]
