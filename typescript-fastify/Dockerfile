FROM node:18.9.1-slim AS base
ENV WORKDIR=/app

FROM base AS deps
WORKDIR $WORKDIR
COPY ./package*.json ./
RUN npm ci

FROM base AS build
WORKDIR $WORKDIR
COPY --from=deps $WORKDIR/node_modules ./node_modules
COPY ./src ./src
COPY ./package*.json ./
COPY ./tsconfig*.json ./
RUN npm run build && npm prune --production

FROM deps AS test
WORKDIR $WORKDIR
COPY ./src ./src
COPY ./tsconfig.json ./

FROM base AS app
WORKDIR $WORKDIR

USER node:node

COPY --from=build $WORKDIR/node_modules ./node_modules
COPY --from=build $WORKDIR/dist ./dist
CMD [ "node", "dist/index.js" ]
