FROM python:3.6-stretch

RUN mkdir code
WORKDIR code
VOLUME /code

CMD python utils/print_markdown.py
