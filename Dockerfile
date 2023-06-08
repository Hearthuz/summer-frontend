FROM node:18-alpine3.16 AS installer

RUN apk add --no-cache libc6-compat

WORKDIR /app

COPY ./package.json ./yarn.lock ./

RUN yarn --frozen-lockfile --production

FROM node:18-alpine3.16 AS builder

WORKDIR /app

COPY --from=installer /app/node_modules ./node_modules
COPY --from=installer /app/package.json ./package.json

COPY . .

RUN yarn build

FROM node:18-alpine3.16 AS runner

WORKDIR /app

COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json

COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

EXPOSE 80

ENV PORT 80

CMD ["node", "server.js"]