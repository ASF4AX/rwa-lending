FROM node:20-alpine
WORKDIR /usr/src/app

# Use pnpm
RUN npm i -g pnpm

# Install deps with lockfile
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# Copy app source
COPY . .

EXPOSE 5173

# Install on startup if node_modules volume is empty, then run dev (bind 0.0.0.0, fixed port)
CMD ["sh", "-lc", "[ -d node_modules ] || pnpm i --frozen-lockfile; pnpm dev --host 0.0.0.0 --port 5173 --strictPort"]
