const { environment } = require('@rails/webpacker')
const jquery = require('./plugins/jquery')
const typescript =  require('./loaders/typescript')

// Hack to get bootstrap tooltips & popovers working with webpacker
// https://stackoverflow.com/questions/60470917/tooltip-is-not-a-function-rails-6-webpack
const webpack = require('webpack')
environment.plugins.append(
  'Provide',
  new webpack.ProvidePlugin({
    $: 'jquery/src/jquery',
    jQuery: 'jquery/src/jquery',
    Popper: ['popper.js', 'default']
  })
);
environment.config.merge({
  resolve: {
    alias: {
      jquery: 'jquery/src/jquery'
    }
  }
});

environment.loaders.prepend('typescript', typescript)


// Add React SVG Loader
// https://github.com/rails/webpacker/blob/master/docs/webpack.md#react-svg-loader
const babelLoader = environment.loaders.get('babel')
environment.loaders.insert('svg', {
  test: /\.svg$/,
  use: babelLoader.use.concat([
    {
      loader: 'react-svg-loader',
      options: {
        jsx: true // true outputs JSX tags
      }
    }
  ])
}, { before: 'file' })

const fileLoader = environment.loaders.get('file')
fileLoader.exclude = /\.(svg)$/i


environment.plugins.prepend('jquery', jquery)
module.exports = environment
