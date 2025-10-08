FROM node:20-alpine AS deps
WORKDIR /usr/src/app
COPY package.json package-lock.json* pnpm-lock.yaml* yarn.lock* ./
RUN if [ -f pnpm-lock.yaml ]; then npm i -g pnpm && pnpm i; \
    elif [ -f yarn.lock ]; then yarn; \
    else npm i; fi

FROM node:20-alpine
WORKDIR /usr/src/app
COPY --from=deps /usr/src/app/node_modules ./node_modules
COPY . .
EXPOSE 5173
CMD ["sh", "-lc", "[ -d node_modules ] || npm ci; npm run dev -- --host"]
