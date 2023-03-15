FROM python:3.7-slim as builder

RUN apt update && \
    apt install --no-install-recommends -y build-essential gcc

COPY requirements.txt /requirements.txt

RUN python -m pip install --upgrade pip && \
    pip install --no-cache-dir --no-warn-script-location --user -r requirements.txt && \
    pip install --no-cache-dir --no-warn-script-location --user typing-extensions -U

# Stage 2: Runtime
FROM nvidia/cuda:11.0.3-cudnn8-runtime
ENV GRADIO_SERVER_NAME=0.0.0.0
ENV TZ=America/New_York

RUN rm /etc/apt/sources.list.d/cuda.list && \
    rm /etc/apt/sources.list.d/nvidia-ml.list

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update && \
    apt purge -y python3 python && \
    apt install --no-install-recommends -y build-essential software-properties-common libgl1-mesa-glx && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    apt install --no-install-recommends -y python3.7 python3.7-distutils && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 2 && \
    apt clean && rm -rf /var/lib/apt/lists/*
COPY --from=builder /root/.local/lib/python3.7/site-packages /usr/local/lib/python3.7/dist-packages
COPY app.py app.py

CMD ["python3", "-u", "app.py"]
EXPOSE 7860
