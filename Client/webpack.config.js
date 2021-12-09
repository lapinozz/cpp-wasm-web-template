const HtmlWebpackPlugin = require("html-webpack-plugin");
const globImporter = require('node-sass-glob-importer');
const extract = require("mini-css-extract-plugin");
const path = require("path");

module.exports = {
    entry: './content/js/index.js',
    module: {
        rules: [{
                test: /\.(sa|sc|c)ss$/,
                use: [extract.loader, "css-loader", { loader: "sass-loader", options: { sassOptions: { importer: globImporter() } } }]
            },
            {
                test: /\.js$/,
                exclude: /node_modules/,
                use: ["babel-loader"]
            },
            {
                test: /\.(png|jpe?g|gif|svg|ttf|ico)$/,
                use: [{
                    loader: 'file-loader',
                    options: {
                        outputPath: "assets"
                    }
                }]
            },
            {
                test: /\.(wasm|wasm.map)$/,
                type: "javascript/auto",
                use: [{
                    loader: 'file-loader',
                    options: {
                      name: '[name].[ext]',
                    }
                }]
            }
        ]
    },
    optimization: {
        splitChunks: { chunks: "all" }
    },
    plugins: [
        new extract({
            filename: 'style.css'
        }),
        new HtmlWebpackPlugin({
            template: path.resolve(__dirname, "content", "index.html"),
            /* favicon: "./src/favicon.ico" */
        })
    ],
    resolve: {
        fallback: {
            "fs": false,
            "crypto": false,
            "path": false,
        },
    },
    devServer: {}
};