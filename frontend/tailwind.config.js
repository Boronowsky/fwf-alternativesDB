/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{js,jsx,ts,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          dark: '#2E4600',    // Forest Green
          medium: '#486B00',  // Grass
          light: '#A2C523',   // Lime
          earth: '#7D4427',   // Earth
          50: '#f2f7e6',
          100: '#e4f0cc',
          200: '#cce4a3',
          300: '#b3d87a',
          400: '#a2c523',     // Lime im 400er Bereich für Kompatibilität
          500: '#486B00',     // Grass im 500er Bereich für Kompatibilität 
          600: '#3a5700',
          700: '#2E4600',     // Forest Green im 700er Bereich für Kompatibilität
          800: '#243600',
          900: '#1a2700',
        },
        success: {
          500: '#486B00', // Grass statt ursprünglichem Grün
        },
        warning: {
          500: '#7D4427', // Earth statt ursprünglichem Orange
        },
        gray: {
          900: '#1e293b', // Dunkel (beibehalten)
          700: '#475569', // Mittel (beibehalten)
          100: '#f1f5f9', // Hell (beibehalten)
        }
      },
      gradientColorStops: theme => ({
        'lime-light': '#A2C523',
        'lime-fade': 'rgba(162, 197, 35, 0.7)',
      }),
    },
  },
  plugins: [],
}