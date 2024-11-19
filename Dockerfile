FROM registry.access.redhat.com/ubi9/python-311@sha256:a6b99f7ce1d29dee82c6ddcb29422ff528dc7164911f4f460f58b21b6f1fc7a5 AS base
# er-outputs-secrets version. keep in sync with pyproject.toml
LABEL konflux.additional-tags="0.2.1"
COPY LICENSE /licenses/


#
# Builder image
#
FROM base AS builder
COPY --from=ghcr.io/astral-sh/uv:0.5.3@sha256:86d3ff1ee650ff0f602e5056919745847d273c2b9ff63584c4ea5119067b1836 /uv /bin/uv

ENV \
    # use venv from ubi image
    UV_PROJECT_ENVIRONMENT="/opt/app-root" \
    # compile bytecode for faster startup
    UV_COMPILE_BYTECODE="true" \
    # disable uv cache. it doesn't make sense in a container
    UV_NO_CACHE=true

# Install dependencies
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-install-project --no-group dev

COPY main.py ./
RUN uv sync --frozen --no-group dev


#
# Test image
#
FROM builder AS test

COPY Makefile ./
RUN uv sync --frozen

COPY tests ./tests
RUN make test


#
# Production image
#
FROM base AS prod
COPY --from=builder /opt/app-root /opt/app-root
ENTRYPOINT [ "python3", "main.py" ]
