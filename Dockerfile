# syntax=docker/dockerfile:1
# ---------------------------------------------------------------------------
# NestJS — imagen multietapa. Contrato: PLATFORM.md §6.
#
# Etapa `dev`  -> `nest start --watch` dentro del pod: recompila al sincronizar
#                 un fichero. Sin esta etapa no hay inner loop.
# Etapa `prod` -> `node dist/main` sobre dependencias de producción.
# ---------------------------------------------------------------------------

# node:24.18.0-alpine — LTS activa (Krypton, 2026-06-23).
# CONDICIÓN DE SALIDA: subir cuando Node 26 pase a LTS.
FROM node:24.18.0-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

# --- dev: watch + depurador --------------------------------------------------
FROM deps AS dev
WORKDIR /app
COPY . .
ENV NODE_ENV=development
# 3000 = HTTP (targetPort del Service; el Service expone 80).
# 9229 = inspector de Node. Se ata a 0.0.0.0 porque el depurador vive FUERA del
# pod y llega por `kubectl port-forward`; atado a 127.0.0.1 el forward conecta
# y el depurador nunca engancha.
EXPOSE 3000 9229
CMD ["npx", "nest", "start", "--debug", "0.0.0.0:9229", "--watch"]

# --- build -------------------------------------------------------------------
FROM deps AS build
WORKDIR /app
COPY . .
RUN npm run build

# --- prod --------------------------------------------------------------------
FROM node:24.18.0-alpine AS prod
WORKDIR /app
ENV NODE_ENV=production
COPY package.json package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force
COPY --from=build /app/dist ./dist
USER node
EXPOSE 3000
CMD ["node", "dist/main"]
