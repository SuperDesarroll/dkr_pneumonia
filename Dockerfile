# For more information, please refer to https://aka.ms/vscode-docker-python
FROM python:3.11-slim

EXPOSE 8000

# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && \
    apt-get install -y libjpeg-dev zlib1g-dev libpng-dev libtiff-dev libopenjp2-7-dev libfreetype6-dev liblcms2-dev libwebp-dev tcl-dev tk-dev libharfbuzz-dev libfribidi-dev libxcb1-dev libhdf5-dev

RUN pip install --upgrade pip

# Install pip requirements
COPY ./docker/requirements.txt .

RUN apt-get update -y \    
    && apt-get install python3-opencv -y \        
    && apt-get install unzip -y \
    && apt-get install zip -y 

RUN pip install h5py

RUN python -m pip install -r requirements.txt

WORKDIR /app
COPY . /app

WORKDIR /app/models
COPY . /app/models


#RUN zip -s 40m -r WilhemNet_86.zip WilhemNet_86.h5
#RUN split -b 40m  WilhemNet_86.h5 segment
RUN echo "SE DEBE UNIR LOS ARCHIVOS"
RUN cat segment* > WilhemNet_86.h5
RUN ls

WORKDIR /app
# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-python-configure-containers
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser


# During debugging, this entry point will be overridden. For more information, please refer to https://aka.ms/vscode-docker-python-debug
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "-k", "uvicorn.workers.UvicornWorker", "app.main:app"]
