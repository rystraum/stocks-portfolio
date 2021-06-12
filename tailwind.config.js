const colors = require('tailwindcss/colors');

module.exports = {
    mode: 'jit',
    purge: [
        './app/views/**/*.erb',
        './app/helpers/application_helper.rb',
        './app/javascript/**/*.{js,jsx,ts,tsx,vue}',
        './app/components/**/*.erb',
    ],
    darkMode: false, // or 'media' or 'class'
    theme: {
        extend: {
            colors: {
                primary: colors.amber,
                transparent: 'transparent',
                current: 'currentColor',
            },
            fontSize: {
                xxs: ['0.5rem', { lineHeight: '1rem' }],
            },
        },
    },
    variants: {
        extend: {
            opacity: ['disabled'],
        },
    },
    plugins: [
        require('@tailwindcss/typography'),
        require('@tailwindcss/forms'),
        require('@tailwindcss/line-clamp'),
        require('@tailwindcss/aspect-ratio'),
    ],
};
