export const config = {
  development: process.env.NODE_ENV !== "production",
  port: process.env.PORT || 3000,
  database: {
    url: process.env.DATABASE_URL || "./dev.db",
  },
  cors: {
    origin: process.env.CORS_ORIGIN || "*",
  },
};
