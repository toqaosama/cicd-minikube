FROM python:3.12-slim

WORKDIR /app
ENV PYTHONUNBUFFERED=1

COPY req.txt .
RUN pip install --no-cache-dir -r req.txt

COPY Python.py .

EXPOSE 5000
CMD ["gunicorn", "-b", "0.0.0.0:5000", "Python:app"]
