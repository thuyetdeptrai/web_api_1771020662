'use strict';
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('reservation_items', {
      id: { allowNull: false, autoIncrement: true, primaryKey: true, type: Sequelize.INTEGER },
      reservation_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: { model: 'reservations', key: 'id' },
        onDelete: 'CASCADE'
      },
      menu_item_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: { model: 'menu_items', key: 'id' },
        onDelete: 'RESTRICT'
      },
      quantity: { type: Sequelize.INTEGER, allowNull: false },
      price: { type: Sequelize.DECIMAL(10, 2), allowNull: false },
      created_at: { allowNull: false, type: Sequelize.DATE },
      updated_at: { allowNull: false, type: Sequelize.DATE }
    });
  },
  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('reservation_items');
  }
};