// Tailwind v4 uses a single PostCSS plugin. No separate tailwind.config.js needed —
// configuration lives in app/globals.css via @theme and @custom-variant.
export default {
  plugins: { "@tailwindcss/postcss": {} },
};
