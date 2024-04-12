const sequelize = require("sequelize");

const db = require(__dirname + "/../services/db");

const Kafka = db.define('Kafka', {
    id: {
      type: sequelize.INTEGER,
      autoIncrement: true,
      primaryKey: true
    },
    timestamp: {
      type: sequelize.DATE,
      allowNull: false,
    },
    uri: {
      type: sequelize.STRING,
      allowNull: false,
    },
    status: {
      type: sequelize.INTEGER,
      allowNull: false,
    },
    expected_status_code: {
        type: sequelize.INTEGER,
        allowNull: false,
    },
    headers: {
      type: sequelize.JSON,
      allowNull: false,
    }
});


module.exports = Kafka;