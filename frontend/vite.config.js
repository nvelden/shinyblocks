import { fileURLToPath } from "node:url";
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

const root = fileURLToPath(new URL(".", import.meta.url));

export default defineConfig({
  root,
  plugins: [react()],
  define: {
    "process.env.NODE_ENV": JSON.stringify("production")
  },
  build: {
    outDir: "../inst/www",
    emptyOutDir: false,
    sourcemap: false,
    minify: "esbuild",
    lib: {
      entry: "src/index.jsx",
      name: "shinyblocksRuntimeBundle",
      formats: ["iife"],
      fileName: () => "shinyblocks-runtime.js"
    }
  }
});
