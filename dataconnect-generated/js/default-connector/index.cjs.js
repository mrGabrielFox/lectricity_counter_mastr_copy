const { getDataConnect, validateArgs } = require('firebase/data-connect');

const connectorConfig = {
  connector: 'default',
  service: 'electricity_counter_master',
  location: 'us-central1'
};
exports.connectorConfig = connectorConfig;

