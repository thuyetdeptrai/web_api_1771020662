'use strict';
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('menu_items', {
      id: { allowNull: false, autoIncrement: true, primaryKey: true, type: Sequelize.INTEGER },
      name: { type: Sequelize.STRING, allowNull: false },
      description: { type: Sequelize.TEXT },
      category: { type: Sequelize.STRING, allowNull: false },
      price: { type: Sequelize.DECIMAL(10, 2), allowNull: false },
      image_url: { type: Sequelize.STRING },
      preparation_time: { type: Sequelize.INTEGER },
      is_vegetarian: { type: Sequelize.BOOLEAN, defaultValue: false },
      is_spicy: { type: Sequelize.BOOLEAN, defaultValue: false },
      is_available: { type: Sequelize.BOOLEAN, defaultValue: true },
      rating: { type: Sequelize.DECIMAL(2, 1), defaultValue: 0.0 },
      created_at: { allowNull: false, type: Sequelize.DATE },
      updated_at: { allowNull: false, type: Sequelize.DATE }
    });
  },
  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('menu_items');
  }
};