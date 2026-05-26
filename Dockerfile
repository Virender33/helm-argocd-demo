FROM python:3.11-slim

WORKDIR /app

COPY myapp/requirements.txt .
RUN pip install -r requirements.txt

COPY myapp/app.py .

EXPOSE 5000

CMD ["python", "app.py"]
