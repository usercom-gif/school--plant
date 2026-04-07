import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";
import path from "path";
import Inspector from "unplugin-vue-dev-locator/vite";

// https://vite.dev/config/
export default defineConfig({
  build: {
    sourcemap: "hidden",
  },
  plugins: [vue(), Inspector()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"), // ✅ 定义 @ = src
    },
  },
  server: {
    host: "0.0.0.0",
    port: 5173,
    strictPort: true, // Force 5173, fail if busy
    proxy: {
      "/api": {
        target: "http://localhost:8080/api", // Backend context path is /api
        changeOrigin: true,
        xfwd: true, // Forward real IP
        rewrite: (path) => path.replace(/^\/api/, ""),
      },
    },
  },
});
