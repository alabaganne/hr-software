module.exports = {
  devServer: {
    proxy: {
      '^/api': {
        target: 'http://backend',
        changeOrigin: true,
      },
      '^/storage': {
        target: 'http://backend',
        changeOrigin: true,
      },
    },
  },
}
