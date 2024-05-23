module.exports = {
  content: ["./*.html", "./assets/**/*.js"],

  theme: {
    screens: {
      sm: "540px",
      // => @media (min-width: 576px) { ... }

      md: "720px",
      // => @media (min-width: 768px) { ... }

      lg: "960px",
      // => @media (min-width: 992px) { ... }

      xl: "1140px",
      // => @media (min-width: 1200px) { ... }

      "2xl": "1320px",
      // => @media (min-width: 1400px) { ... }
    },
    container: {
      center: true,
      padding: "16px",
    },
    extend: {
      colors: {
        black: "#212b36",
        dark: "#111827",
        "dark-700": "#090e34b3",
        primary: "#FF5C5C",
        "primary-200": "#ccccff",
        "primary-100": "#E0F2FE",
        secondary: "#18BFFF ",
        "secondary-100": "#fff7f5",
        "secondary-500": "#00A7E6",
        "body-color": "#374151",
        tertiary: "#F3F4F6",
        warning: "#FBBF24",
      },
      boxShadow: {
        input: "0px 7px 20px rgba(0, 0, 0, 0.03)",
        pricing: "0px 39px 23px -27px rgba(0, 0, 0, 0.04)",
        "switch-1": "0px 0px 5px rgba(0, 0, 0, 0.15)",
        testimonial: "0px 60px 120px -20px #EBEFFD",
      },
    },
  },
  variants: {
    extend: {},
  },
  plugins: [],
};
