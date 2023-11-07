FROM node:20

WORKDIR /app

COPY package.json .
COPY package-lock.json .
RUN npm install

COPY server.js .

EXPOSE 9001

CMD ["npm","start"]
