FROM node:21.7.1-alpine

RUN apk add --no-cache bash git jq curl

WORKDIR /app
COPY ./frontend/package.json ./frontend/package-lock.json ./
RUN npm install
COPY ./frontend ./

SHELL ["/bin/bash", "-c"]
# Clear the entrypoint
ENTRYPOINT []
CMD ["npm", "run", "dev"]
