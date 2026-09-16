FROM python:3.13-slim
WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
COPY pyproject.toml ./
RUN pip install tomli && \
    python -c "import tomli; p=tomli.load(open('pyproject.toml','rb')); r=p['build-system']['requires']+['wheel']+p['project']['dependencies']; print('\n'.join(r))" > /tmp/serein-requirements.txt && \
    pip install -r /tmp/serein-requirements.txt && \
    pip install uvicorn && \
    rm /tmp/serein-requirements.txt
COPY README.md ./
COPY src ./src
COPY config ./config
RUN pip install --no-deps --no-build-isolation . && pip check
CMD ["python", "-m", "serein", "--config", "/app/config/config.toml", "http", "--host", "0.0.0.0", "--port", "8011"]
