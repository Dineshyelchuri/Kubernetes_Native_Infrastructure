const { Sequelize } = require("sequelize");
const db = new Sequelize(
  process.env.POSTGRES_DB,
  process.env.POSTGRES_USER,
  process.env.POSTGRES_PASSWORD,
  {
    host: process.env.POSTGRES_HOST,
    dialect: "postgres",
    logging: console.log,
    schema: process.env.SCHEMA_NAME
  }
);

db.authenticate().then(() => {
    console.log('Connection has been established successfully.');
}).catch((error) => {
    console.log('Unable to connect to the database: ', error);
});

module.exports = db;