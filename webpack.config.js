const path = require('path')
const HTMLWebpackPlugin = require('html-webpack-plugin')

module.exports = {
  entry: './src-elm/index.js',
  output: {
    filename: 'bundle.js',
    path: path.resolve(__dirname, 'src-elm', 'dist'),
  },
  devServer: {
    static: {
      directory: path.join(__dirname, 'src-elm', 'public'),
    },
    compress: true,
    port: 9000,
  },
  module: {
    rules: [{
      test: /\.elm$/,
      exclude: [/elm-stuff/, /node_modules/],
      use: [
        {
          loader: 'elm-hot-webpack-loader'
        },
        {
          loader: 'elm-webpack-loader',
          options: {
            cwd: path.join(__dirname, 'src-elm')
          }
        }
      ]
    }]
  },
  plugins: [
    new HTMLWebpackPlugin({
      template: "src-elm/index.html"
    })
  ]
}