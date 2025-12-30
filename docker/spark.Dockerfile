FROM apache/spark:3.5.1
ENV PROJECT_HOME=/app MONGO_URI=mongodb://mongo-flights:27017 KAFKA_BOOTSTRAP=kafka:9092
WORKDIR /app
RUN mkdir -p /tmp/.ivy2/cache
COPY flight_prediction/target/scala-2.12/flight_prediction_2.12-0.1.jar /app/job.jar
CMD ["/opt/spark/bin/spark-submit", \
     "--class", "es.upm.dit.ging.predictor.MakePrediction", \
     "--master", "local[*]", \
     "--conf", "spark.jars.ivy=/tmp/.ivy2", \
     "--packages", "org.mongodb.spark:mongo-spark-connector_2.12:10.4.1,org.apache.spark:spark-sql-kafka-0-10_2.12:3.5.3", \
     "/app/job.jar"]
