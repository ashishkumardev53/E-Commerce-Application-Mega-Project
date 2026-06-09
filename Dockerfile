# Stage 1: Build Stage
# Is stage ka kaam application ko build karna hai.
# Yahan source code se production-ready files generate hoti hain.
FROM node:18-alpine AS builder

# Container ke andar /app naam ka working folder create karte hain
# Aur uske baad saare commands isi directory ke andar execute honge.
WORKDIR /app

# Kuch npm packages ko install karne ke liye Python, Make aur G++ ki zarurat padti hai.
# Ye tools native modules ko compile karne ke kaam aate hain.
RUN apk add --no-cache python3 make g++

# package.json aur package-lock.json files ko copy kar rahe hain.
# In files me project ki dependencies ki information hoti hai.
COPY package*.json ./

# npm ci command exact dependencies install karti hai
# jo package-lock.json me defined hoti hain.
# Production build ke liye ye npm install se zyada reliable aur fast hoti hai.
RUN npm ci

# Ab project ka pura source code container ke andar copy kar rahe hain.
COPY . .

# Next.js application ka production build create kar rahe hain.
# Is command ke baad .next folder generate ho jayega.
RUN npm run build


# Stage 2: Production Stage
# Ye final lightweight image hai jo sirf application run karegi.
# Isme unnecessary build tools include nahi honge.
FROM node:18-alpine AS runner

# Container ke andar application ke liye working directory set kar rahe hain.
WORKDIR /app

# Builder stage se standalone server files copy kar rahe hain.
# Ye Next.js application ko run karne ke liye required hoti hain.
COPY --from=builder /app/.next/standalone ./

# Static files (CSS, JS, Images wagaira) copy kar rahe hain.
# Browser ko ye files serve ki jaati hain.
COPY --from=builder /app/.next/static ./.next/static

# Public folder copy kar rahe hain.
# Isme generally images, favicon aur static assets hote hain.
COPY --from=builder /app/public ./public

# Application ko production mode me run karne ke liye environment variable set kar rahe hain.
ENV NODE_ENV=production

# Application kis port par chalegi uska default port define kar rahe hain.
ENV PORT=3000

# Docker ko batate hain ki container port 3000 par traffic accept karega.
EXPOSE 3000

# Container start hote hi ye command execute hogi.
# server.js Next.js application ko run karega.
CMD ["node", "server.js"]