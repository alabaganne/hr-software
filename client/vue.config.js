module.exports = {
  devServer: {
    // Required when serving through Nginx with hr-software.alabaganne.com.
    disableHostCheck: true,
    public: 'hr-software.alabaganne.com',
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
