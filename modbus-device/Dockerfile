### 1. Get Linux
FROM python:3.6

### 2. Install pymodbus
RUN pip install pymodbus

### 3. Start server
EXPOSE 502    
ADD server.py /
CMD ["python3", "server.py"]