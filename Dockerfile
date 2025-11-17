# Use a small, secure Python base image
FROM python:3.11-slim

# Set environment vars to avoid Python buffering and set a non-root user later
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Create and set working directory
WORKDIR /app

# Install system dependencies required for some Python packages (kept minimal)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
  && rm -rf /var/lib/apt/lists/*

# Copy only requirements first (caching layer)
COPY requirements.txt /app/requirements.txt

# Install Python dependencies (also install gunicorn as WSGI server)
RUN pip install --upgrade pip \
  && pip install --no-cache-dir -r /app/requirements.txt \
  && pip install --no-cache-dir gunicorn

# Copy app source code
COPY . /app

# Expose the port the app runs on
EXPOSE 5000

# Use a non-root user for security (optional but recommended)
RUN useradd --create-home appuser && chown -R appuser:appuser /app
USER appuser

# Start the app with gunicorn (assumes Flask app variable is named `app` in app.py)
CMD ["gunicorn", "--workers", "3", "--bind", "0.0.0.0:5000", "app:app"]

