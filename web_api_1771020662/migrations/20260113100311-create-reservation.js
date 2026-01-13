'use strict';
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('reservations', {
      id: { allowNull: false, autoIncrement: true, primaryKey: true, type: Sequelize.INTEGER },
      customer_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: { model: 'customers', key: 'id' },
        onDelete: 'RESTRICT'
      },
      reservation_number: { type: Sequelize.STRING, unique: true, allowNull: false },
      reservation_date: { type: Sequelize.DATE, allowNull: false },
      number_of_guests: { type: Sequelize.INTEGER, allowNull: false },
      table_number: { type: Sequelize.STRING },
      status: { type: Sequelize.STRING, defaultValue: 'pending' },
      special_requests: { type: Sequelize.TEXT },
      subtotal: { type: Sequelize.DECIMAL(10, 2), defaultValue: 0 },
      service_charge: { type: Sequelize.DECIMAL(10, 2), defaultValue: 0 },
      discount: { type: Sequelize.DECIMAL(10, 2), defaultValue: 0 },
      total: { type: Sequelize.DECIMAL(10, 2), defaultValue: 0 },
      payment_method: { type: Sequelize.STRING },
      payment_status: { type: Sequelize.STRING, defaultValue: 'pending' },
      created_at: { allowNull: false, type: Sequelize.DATE },
      updated_at: { allowNull: false, type: Sequelize.DATE }
    });
  },
  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('reservations');
  }
};