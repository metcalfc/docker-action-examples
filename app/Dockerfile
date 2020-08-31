FROM python:3.7-alpine AS base
WORKDIR /app
COPY requirements.txt /app
RUN pip3 install -r requirements.txt

FROM base as src
COPY . /app

FROM src as test
COPY requirements.dev.txt /app
RUN pip3 install -r requirements.dev.txt
RUN python3 -m pytest

FROM src as prod
ENTRYPOINT ["python3"]
CMD ["app.py"]
