FROM python:3.10-slim

ENV PROJECT_HOME=/app MONGO_URI=mongodb://mongo-flights:27017 KAFKA_BOOTSTRAP=kafka:9092
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY resources/web /app
EXPOSE 5001
CMD ["python", "predict_flask.py"]