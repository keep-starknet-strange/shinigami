FROM --platform=linux/amd64 node:21.7.1-alpine

RUN apk add --no-cache bash curl git jq ncurses

SHELL ["/bin/bash", "-c"]
RUN curl --proto '=https' --tlsv1.2 -sSf https://docs.swmansion.com/scarb/install.sh | bash -s -- -v 2.9.2
RUN curl https://get.starkli.sh | sh && \
    source /root/.starkli/env && \
    starkliup
ENV PATH="$PATH:/root/.local/bin:/root/.starkli/bin"

WORKDIR /tests

COPY ./tests/text_to_byte_array.sh ./

WORKDIR /backend

COPY ./backend/package.json ./backend/package-lock.json ./
RUN npm i

COPY ./backend ./

WORKDIR /

COPY Scarb.toml Scarb.lock .tool-versions ./
COPY ./src ./src
RUN scarb build

WORKDIR /backend

EXPOSE 8080

CMD ["node", "index.js"]
