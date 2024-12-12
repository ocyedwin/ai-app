import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'

export default defineConfig({
  // NOTE: esbuild section added to support decorators for Lit
  esbuild: {
    target: "esnext",
    tsconfigRaw: {
      compilerOptions: {
        experimentalDecorators: true,
      },
    },
  },
  plugins: [
    RubyPlugin(),
  ],
})
