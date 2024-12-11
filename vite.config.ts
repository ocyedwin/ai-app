import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'

export default defineConfig({
  esbuild: {
    target: "esnext"
  },
  plugins: [
    RubyPlugin(),
  ],
})
