const express = require('express');
const path = require('path');
const app = express();
const port = 3000;

app.use((req, res, next) => {
    res.setHeader('Cross-Origin-Opener-Policy', 'same-origin');
    res.setHeader('Cross-Origin-Embedder-Policy', 'require-corp');
    next();
});

app.use(express.static(path.join(__dirname, "..", "Build")));

app.listen(port, () => {
    console.log(path.join(__dirname, "..", "Build"))
  console.log(`Server is running at http://localhost:${port}`);
});