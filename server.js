const express = require("express");

const app = express();

const port = process.env.PORT || 8080;

app.use(express.static(__dirname));

app.get("/build", (req, res) => {
  res.render("./index.html");
});

app.listen(port, () => {
  // eslint-disable-next-line no-console
  console.log("started listening");
});
