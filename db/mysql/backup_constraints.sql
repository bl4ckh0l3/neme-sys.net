--
-- Definition of constraints
--

ALTER TABLE `USER_PREFERENCES` ADD FOREIGN KEY (`id_user`) REFERENCES `USER` (`id`) ON DELETE CASCADE;
ALTER TABLE `USER_PREFERENCES` ADD FOREIGN KEY (`id_friend`) REFERENCES `USER` (`id`);
ALTER TABLE `USER_FIELDS_MATCH` ADD FOREIGN KEY (`id_parent_user`) REFERENCES `USER` (`id`) ON DELETE CASCADE;
ALTER TABLE `USER_FIELDS_MATCH` ADD FOREIGN KEY (`id_field`) REFERENCES `USER_FIELDS` (`id`) ON DELETE CASCADE;
ALTER TABLE `CONTENT_ATTACHMENTS` ADD FOREIGN KEY (`id_parent_content`) REFERENCES `CONTENT` (`id`) ON DELETE CASCADE;
ALTER TABLE `CONTENT_FIELDS_VALUES` ADD FOREIGN KEY (`id_field`) REFERENCES `CONTENT_FIELDS` (`id`) ON DELETE CASCADE;
ALTER TABLE `USER_FIELDS` ADD FOREIGN KEY (`type`) REFERENCES `SYSTEM_FIELDS_TYPE` (`id`);
ALTER TABLE `USER_ATTACHMENTS` ADD FOREIGN KEY (`id_user`) REFERENCES `USERS` (`id`) ON DELETE CASCADE;
ALTER TABLE `USER_FRIENDS` ADD FOREIGN KEY (`id_friend`) REFERENCES `USERS` (`id`) ON DELETE CASCADE;
ALTER TABLE `USER_FRIENDS` ADD FOREIGN KEY (`id_user`) REFERENCES `USERS` (`id`) ON DELETE CASCADE;

#ALTER TABLE `attach_x_prodotti` ADD FOREIGN KEY (`id_prodotto`) REFERENCES `prodotti` (`id_prodotto`) ON DELETE CASCADE;
#ALTER TABLE `prodotti_x_carrello` ADD FOREIGN KEY (`id_carrello`) REFERENCES `carrello` (`id_carrello`) ON DELETE CASCADE;
#ALTER TABLE `prodotti_x_ordine` ADD FOREIGN KEY (`id_ordine`) REFERENCES `ordini` (`id_ordine`) ON DELETE CASCADE;
#ALTER TABLE `spese_x_ordine` ADD FOREIGN KEY (`id_ordine`) REFERENCES `ordini` (`id_ordine`) ON DELETE CASCADE;
#ALTER TABLE `attach_x_prodotti` ADD FOREIGN KEY (`id_prodotto`) REFERENCES `prodotti` (`id_prodotto`) ON DELETE CASCADE;
#ALTER TABLE `shipping_address` ADD FOREIGN KEY (`id_user`) REFERENCES `utenti` (`id`) ON DELETE CASCADE;
#ALTER TABLE `order_shipping_address` ADD FOREIGN KEY (`id_order`) REFERENCES `ordini` (`id_ordine`) ON DELETE CASCADE;
#ALTER TABLE `order_shipping_address` ADD FOREIGN KEY (`id_shipping`) REFERENCES `shipping_address` (`id`) ON DELETE CASCADE;
#ALTER TABLE `downloadable_products` ADD FOREIGN KEY (`id_product`) REFERENCES `prodotti` (`id_prodotto`) ON DELETE CASCADE;
#ALTER TABLE `usr_group_x_margin_disc` ADD FOREIGN KEY (`id_marg_disc`) REFERENCES `margin_discount` (`id`) ON DELETE CASCADE;
#ALTER TABLE `usr_group_x_margin_disc` ADD FOREIGN KEY (`id_user_group`) REFERENCES `user_group` (`id`) ON DELETE CASCADE;
#ALTER TABLE `product_fields_values` ADD FOREIGN KEY (`id_field`) REFERENCES `product_fields` (`id`) ON DELETE CASCADE;
#ALTER TABLE `product_fields_match` ADD FOREIGN KEY (`id_prod`) REFERENCES `prodotti` (`id_prodotto`) ON DELETE CASCADE;
#ALTER TABLE `product_fields_match` ADD FOREIGN KEY (`id_field`) REFERENCES `product_fields` (`id`) ON DELETE CASCADE;
#ALTER TABLE `product_fields_value_match` ADD FOREIGN KEY (`id_prod`) REFERENCES `prodotti` (`id_prodotto`) ON DELETE CASCADE;
#ALTER TABLE `product_fields_value_match` ADD FOREIGN KEY (`id_field`) REFERENCES `product_fields` (`id`) ON DELETE CASCADE;
#ALTER TABLE `product_fields_x_order` ADD FOREIGN KEY (`id_order`) REFERENCES `ordini` (`id_ordine`) ON DELETE CASCADE;
#ALTER TABLE `product_fields` ADD FOREIGN KEY (`id_group`) REFERENCES `product_fields_group` (`id`);
#ALTER TABLE `product_fields` ADD FOREIGN KEY (`type`) REFERENCES `product_fields_type` (`id`);
#ALTER TABLE `product_fields_x_card` ADD FOREIGN KEY (`id_card`) REFERENCES `carrello` (`id_carrello`) ON DELETE CASCADE;
#ALTER TABLE `relation_x_prodotto` ADD FOREIGN KEY (`id_prod`) REFERENCES `prodotti` (`id_prodotto`) ON DELETE CASCADE;
#ALTER TABLE `relation_x_prodotto` ADD FOREIGN KEY (`id_prod_ref`) REFERENCES `prodotti` (`id_prodotto`) ON DELETE CASCADE;
#ALTER TABLE `tax_group_value` ADD FOREIGN KEY (`id_group`) REFERENCES `tax_group` (`id`) ON DELETE CASCADE;
#ALTER TABLE `prodotto_main_field_translation` ADD FOREIGN KEY (`id_prod`) REFERENCES `prodotti` (`id_prodotto`) ON DELETE CASCADE;
#ALTER TABLE `ads` ADD FOREIGN KEY (`id_element`) REFERENCES `news` (`id`) ON DELETE CASCADE;
#ALTER TABLE `ads_promotion` ADD FOREIGN KEY (`id_ads`) REFERENCES `ads` (`id_ads`) ON DELETE CASCADE;
#ALTER TABLE `ads_promotion` ADD FOREIGN KEY (`id_element`) REFERENCES `prodotti` (`id_prodotto`) ON DELETE CASCADE;
#ALTER TABLE `spese_accessorie_config` ADD FOREIGN KEY (`id_spesa`) REFERENCES `spese_accessorie` (`id`) ON DELETE CASCADE;
#ALTER TABLE `business_rules_config` ADD FOREIGN KEY (`id_rule`) REFERENCES `business_rules` (`id`) ON DELETE CASCADE;
#ALTER TABLE `business_rules_x_ordine` ADD FOREIGN KEY (`id_order`) REFERENCES `ordini` (`id_ordine`) ON DELETE CASCADE;
#ALTER TABLE `voucher_x_ordine` ADD FOREIGN KEY (`id_order`) REFERENCES `ordini` (`id_ordine`) ON DELETE CASCADE;