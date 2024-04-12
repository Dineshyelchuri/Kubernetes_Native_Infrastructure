const sequelize = require("sequelize");

const db = require(__dirname + "/../services/service.js");

const HttpCheck = db.define('HttpCheck', {
    id: {
      type: sequelize.STRING,
      primaryKey: true,
      defaultValue: sequelize.DataTypes.UUIDV4
    },
    name: {
      type: sequelize.STRING,
      allowNull: false,
    },
    uri: {
      type: sequelize.STRING,
      allowNull: false,
    },
    is_paused: {
      type: sequelize.BOOLEAN,
      allowNull: false,
    },
    num_retries: {
      type: sequelize.INTEGER,
      allowNull: false,
      validate: {
        min: 1,
        max: 5
      }
    },
    uptime_sla: {
      type: sequelize.INTEGER,
      allowNull: false,
      validate: {
        min: 0,
        max: 100
      }
    },
    response_time_sla: {
      type: sequelize.INTEGER,
      allowNull: false,
      validate: {
        min: 0,
        max: 100
      }
    },
    use_ssl: {
      type: sequelize.BOOLEAN,
      allowNull: false,
    },
    response_status_code: {
      type: sequelize.INTEGER,
      allowNull: false,
      defaultValue: 200
    },
    check_interval_in_seconds: {
      type: sequelize.INTEGER,
      allowNull: false,
      validate: {
        min: 1,
        max: 86400
      }
    }
  }, {
    createdAt: 'check_created',
    updatedAt: 'check_updated'
  });

  module.exports = HttpCheck;