FROM nvidia/cudagl:11.4.2-base

ENV PATH="/root/.go/bin:/root/go/bin:${PATH}"
ENV TZ=Etc/UTC
ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:0
ENV NVIDIA_DRIVER_CAPABILITIES=graphics

WORKDIR /ws

RUN apt -y update && apt -y install ffmpeg gifsicle python3 curl build-essential libx11-dev xorg-dev libegl1-mesa-dev
RUN curl -LO https://get.golang.org/$(uname)/go_installer && chmod +x go_installer && SHELL=bash ./go_installer
RUN go install github.com/polyfloyd/shady/cmd/shady@latest

COPY render ./render

CMD ["python3", "render/process.py"]