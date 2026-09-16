FROM python:3.13-slim
WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
COPY pyproject.toml ./
RUN pip install tomli && \
    python -c "import tomli; p=tomli.load(open('pyproject.toml','rb')); r=p['build-system']['requires']+['wheel']+p['project']['dependencies']; print('\n'.join(r))" > /tmp/serein-requirements.txt && \
    pip install -r /tmp/serein-requirements.txt && \
    rm /tmp/serein-requirements.txt
COPY README.md ./
COPY src ./src
RUN pip install --no-deps --no-build-isolation . && pip check
CMD ["python", "-m", "serein", "--config", "/config/config.toml", "--live", "http", "--host", "0.0.0.0", "--port", "8011"]
