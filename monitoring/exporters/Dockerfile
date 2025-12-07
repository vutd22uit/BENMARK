FROM python:3.11-slim

WORKDIR /app

# Install dependencies
RUN pip install --no-cache-dir prometheus-client

# Copy exporter script
COPY compliance_exporter.py /app/

# Create reports directory
RUN mkdir -p /app/reports

# Set environment variables
ENV EXPORTER_PORT=9090
ENV ENVIRONMENT=production
ENV INSPEC_RESULTS_DIR=/app/reports

EXPOSE 9090

CMD ["python", "compliance_exporter.py"]
