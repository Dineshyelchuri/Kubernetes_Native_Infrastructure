const express = require("express");
const router = require("./routes/route");
const db = require("./services/service");
const bodyParser = require("body-parser");

const app = express();

app.use(bodyParser.json());

const PORT = 3000;

app.use('/', router);

db.sync().then(() => {
  console.log('Tables are created successfully!');
}).catch((error) => {
  console.log('Unable to create tables : ', error);
});

app.listen(PORT, () => {
  console.log(`Server started on http://localhost:${PORT}`);
});

module.exports = app;