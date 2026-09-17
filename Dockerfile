FROM python:3.13-slim
WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
COPY pyproject.toml ./
RUN pip install tomli && \
    python -c "import tomli; p=tomli.load(open('pyproject.toml','rb')); r=p['build-system']['requires']+['wheel']+p['project']['dependencies']; extras=p.get('project',{}).get('optional-dependencies',{}); [r.extend(v) for v in extras.values()]; print('\n'.join(set(r)))" > /tmp/serein-requirements.txt && \
    pip install -r /tmp/serein-requirements.txt && \
    rm /tmp/serein-requirements.txt
COPY README.md ./
COPY src ./src
COPY config ./config
RUN pip install --no-deps --no-build-isolation . && pip check
CMD sh -c "python -m serein --config config/config.toml setup && python -m serein --config config/config.toml prepare-routes --profile config/embedding-profile.json --examples examples/route-examples.json && python -m serein --config config/config.toml http --host 0.0.0.0 --port 8011 --token-env SEREIN_TOKEN"
