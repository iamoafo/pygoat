FROM python:3.11-slim-bullseye

# Set work directory
WORKDIR /app

# Install system dependencies for psycopg2 and DNS utilities
RUN apt-get update \
 && apt-get install --no-install-recommends -y \
    dnsutils \
    libpq-dev \
    python3-dev \
    gcc \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Upgrade pip to the desired version
RUN python -m pip install --no-cache-dir pip==22.0.4

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the project files
COPY . /app/

# Run migrations
RUN python3 manage.py migrate

# Expose port
EXPOSE 8000

# Start the application
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "6", "pygoat.wsgi"]
