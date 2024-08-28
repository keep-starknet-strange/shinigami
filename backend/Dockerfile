FROM node:20.5.0

SHELL ["bash", "-c"]
RUN curl https://get.starkli.sh | sh && \
    source $HOME/.starkli/env && \
    source $HOME/.starkli/env && \
    starkliup && \
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.1 && \
    . "$HOME/.asdf/asdf.sh" && \
    . "$HOME/.asdf/completions/asdf.bash" && \
    asdf plugin add scarb && \
    asdf install scarb latest && \
    asdf global scarb latest

WORKDIR /backend

COPY ./index.js ./package.json ./pnpm-lock.yaml ./

RUN npm i

RUN npm run start

EXPOSE 3000

CMD ["node", "index.js"]