/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{js,jsx,ts,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#f2f9ff',
          100: '#e6f3ff',
          200: '#bfdfff',
          300: '#99ccff',
          400: '#4da6ff',
          500: '#0080ff',
          600: '#0073e6',
          700: '#0060bf',
          800: '#004d99',
          900: '#003f7d',
        },
      },
    },
  },
  plugins: [],
}
