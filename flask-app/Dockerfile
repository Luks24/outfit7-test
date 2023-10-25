# syntax=docker/dockerfile:1

FROM python:3.13-rc-slim

WORKDIR /app

RUN pip3 install flask

COPY . .

CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0", "--port", "8080"]