FROM python:3.9.23-bookworm
EXPOSE 8000
WORKDIR /app
COPY . .
RUN pip install -r devrequirements.txt
ENV STRESS_TEST_FLAG=true
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]

