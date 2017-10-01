DROP TABLE IF EXISTS `CURRENCY`;
CREATE TABLE `CURRENCY` (  `id` int(11) unsigned NOT NULL auto_increment,  `currency` varchar(5) NOT NULL,  `rate` decimal(20,4) NOT NULL,  `refer_date` date NOT NULL,  `insert_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,  `active` smallint(1) unsigned NOT NULL default '0',  `is_default` smallint(1) unsigned NOT NULL default '0',  PRIMARY KEY  (`id`),  KEY `currency` (`currency`),  KEY `rate` (`rate`)) ENGINE=InnoDB  DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS `PAYMENT`;
CREATE TABLE `PAYMENT` (  `id` int(11) unsigned NOT NULL auto_increment,  `description` varchar(250) default NULL,  `payment_data` varchar(250) NOT NULL,  `commission` decimal(20,4) NOT NULL default '0.0000',  `commission_type` SMALLINT(1) UNSIGNED NOT NULL  default '1',  `external_url` smallint(1) unsigned NOT NULL default '0',  `id_module` int(10) default NULL,  `active` smallint(1) unsigned NOT NULL default '0',  `payment_type` smallint(1) unsigned NOT NULL default '0',  `apply_to`smallint(1) unsigned NOT NULL default '0',  PRIMARY KEY  (`id`),  KEY `id_module` (`id_module`),  KEY `description` (`description`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS `PAYMENT_FIELDS`;
CREATE TABLE `PAYMENT_FIELDS` (  `id` int(11) unsigned NOT NULL auto_increment,  `id_payment` int(11) NOT NULL,  `id_module` int(11) default NULL,  `keyword` varchar(50) NOT NULL,  `value` varchar(250) default NULL,  `match_field` varchar(100) default NULL,  PRIMARY KEY  USING BTREE (`id`),  UNIQUE KEY `Index_UX` (`id_payment`,`id_module`,`keyword`,`match_field`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS `PAYMENT_MODULES`;
CREATE TABLE `PAYMENT_MODULES` (  `id` INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,  `name` VARCHAR(45) NOT NULL,  `icon` TEXT,  `id_order_field` VARCHAR(150) NOT NULL,  `ip_provider` VARCHAR(150) NOT NULL default '',  PRIMARY KEY (`id`),  INDEX `Index_2`(`name`),  INDEX `Index_3`(`id_order_field`))ENGINE = InnoDB  DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS `PAYMENT_MODULES_FIELDS`;
CREATE TABLE `PAYMENT_MODULES_FIELDS` (  `id` int(11) unsigned NOT NULL auto_increment,  `id_module` int(11) default NULL,  `keyword` varchar(50) NOT NULL,  `value` varchar(250) default NULL,  `match_field` varchar(100) default NULL,  PRIMARY KEY  (`id`),  UNIQUE KEY `Index_2` (`id_module`,`keyword`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS `PAYMENT_TRANSACTIONS`;
CREATE TABLE `PAYMENT_TRANSACTIONS` (  `id` int(11) unsigned NOT NULL auto_increment,  `id_order` int(11) NOT NULL,  `id_module` INTEGER NOT NULL,  `id_transaction` varchar(100) NOT NULL,  `status` varchar(100) default NULL,  `notified` smallint(1) unsigned NOT NULL default '0',  `insert_date` datetime NOT NULL,  PRIMARY KEY  (`id`),  INDEX `Index_2` (`id_order`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS `SUPPLEMENT`;
CREATE TABLE `SUPPLEMENT` (  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,  `description` VARCHAR(100) NOT NULL,  `value` DECIMAL(20,4) NOT NULL default '0.0000',  `type` SMALLINT(1) UNSIGNED NOT NULL,  PRIMARY KEY (`id`),  INDEX `Index_2`(`value`),  INDEX `Index_3`(`type`)) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;
DROP TABLE IF EXISTS `SUPPLEMENT_GROUP`;
CREATE TABLE IF NOT EXISTS `SUPPLEMENT_GROUP` (    `id` int(11) unsigned NOT NULL auto_increment,  `description` VARCHAR(100) NOT NULL,  PRIMARY KEY (`id`),  INDEX `Index_TG_dc`(`description`)) ENGINE = InnoDB  DEFAULT CHARSET=utf8;	
DROP TABLE IF EXISTS `SUPPLEMENT_GROUP_VALUES`;
CREATE TABLE IF NOT EXISTS `SUPPLEMENT_GROUP_VALUES` (    `id` int(11) unsigned NOT NULL auto_increment,  `id_group` int(11) NOT NULL,  `country_code` VARCHAR(2) NOT NULL,  `state_region_code` VARCHAR(10) DEFAULT NULL,  `id_fee` int(11) NOT NULL,  `exclude_calculation` SMALLINT(1) UNSIGNED NOT NULL default '0',  PRIMARY KEY (`id`),  INDEX `Index_TGV_ig`(`id_group`),		    INDEX `Index_TGV_cc`(`country_code`),		    INDEX `Index_TGV_src`(`state_region_code`)) ENGINE = InnoDB  DEFAULT CHARSET=utf8;	
DROP TABLE IF EXISTS `FEE`;
CREATE TABLE IF NOT EXISTS `FEE` (  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,  `description` VARCHAR(150) NOT NULL,  `amount` DECIMAL(20,4) NOT NULL,  `type` SMALLINT(3) UNSIGNED NOT NULL,  `id_supplement` int(11) NOT NULL default '-1',  `supplement_group` int(11) NOT NULL default '-1',   `apply_to`SMALLINT(1) UNSIGNED,  `autoactive` SMALLINT(1) UNSIGNED NOT NULL default '0',  `multiply` SMALLINT(1) UNSIGNED NOT NULL default '0',  `required` SMALLINT(1) UNSIGNED NOT NULL default '0',  `fee_group` VARCHAR(100) default NULL,   `type_view` SMALLINT(1) UNSIGNED NOT NULL default '0',  `ext_provider` SMALLINT(1) NOT NULL default '0', `ext_params` text, PRIMARY KEY (`id`),  INDEX `Index_1`(`description`),  INDEX `Index_2`(`amount`),  INDEX `Index_3`(`id_supplement`)) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;
DROP TABLE IF EXISTS `FEE_CONFIG`;
CREATE TABLE IF NOT EXISTS `FEE_CONFIG` (  `id`  int(11) UNSIGNED NOT NULL AUTO_INCREMENT,  `id_fee` int(11) NOT NULL,  `desc_prod_field` VARCHAR(100) default NULL, `rate_from` DECIMAL(20,4) NOT NULL default '0.00', `rate_to` DECIMAL(20,4) NOT NULL default '0.00', `operation` SMALLINT( 1 ) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'operation type: 0 null, 1 sum, 2 substract;', `value` DECIMAL(20,4) NOT NULL,    PRIMARY KEY (`id`),  UNIQUE KEY `Index_U` (`id_fee`,`desc_prod_field`,`rate_from`,`rate_to`),  INDEX `Index_From`(`rate_from`),  INDEX `Index_To`(`rate_to`),  INDEX `Index_Val`(`value`)) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;
DROP TABLE IF EXISTS `PRODUCT`;
CREATE TABLE IF NOT EXISTS `PRODUCT` (  `id` int(11) unsigned NOT NULL auto_increment,  `name` varchar(250) NOT NULL,  `summary` text,  `description` text,  `keyword` varchar(250) default NULL,  `status` smallint(2) unsigned NOT NULL default '0',  `meta_description` TEXT default NULL,  `meta_keyword` TEXT default NULL,  `page_title` TEXT default NULL,  `id_user` INT(11) NOT NULL,  `publish_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,  `insert_date` timestamp NOT NULL,  `delete_date` datetime NOT NULL default '9999-12-31 23:59:59',  `price` decimal(20,4) NOT NULL,  `discount` decimal(20,4) NOT NULL default '0',  `quantity` int(10) NOT NULL,  `set_buy_qta` smallint(1) unsigned NOT NULL default '0',   `id_supplement` int(10) default NULL,  `id_supplement_group` INT( 10 ) DEFAULT NULL ,  `prod_type` smallint(1) unsigned NOT NULL,  `max_download` int(11) NOT NULL default '-1',   `max_download_time` int(11) NOT NULL default '-1',   `quantity_rotation_mode` int(3) NOT NULL default '0',   `rotation_mode_value` varchar(30) default NULL,   `reload_quantity` int(10) NOT NULL default '0',   `weight` decimal(20,4) NOT NULL default '0',  `length` decimal(20,4) NOT NULL default '0',  `width` decimal(20,4) NOT NULL default '0',  `height` decimal(20,4) NOT NULL default '0',  PRIMARY KEY  (`id`),  KEY `Index_2` (`name`),  KEY `Index_3` (`keyword`),  KEY `Index_4` (`id_user`),  KEY `Index_5` (`status`),  KEY `Index_6` (`price`),  KEY `Index_7` (`quantity_rotation_mode`)) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;
DROP TABLE IF EXISTS `PRODUCT_ATTACHMENTS`;
CREATE TABLE IF NOT EXISTS `PRODUCT_ATTACHMENTS` (  `id` int(11) unsigned NOT NULL auto_increment,  `id_parent_product` int(11) NOT NULL,  `file_path` VARCHAR(150) NOT NULL,  `file_name` VARCHAR(150) NOT NULL,  `content_type` varchar(50) NOT NULL,  `file_dida` text,  `file_label` int(11) UNSIGNED NOT NULL default '0',  `insert_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,  PRIMARY KEY  (`id`),  KEY `Index_1` (`id_parent_product`)) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;
DROP TABLE IF EXISTS `PRODUCT_ATTACHMENTS_DOWNLOAD`;
CREATE TABLE IF NOT EXISTS `PRODUCT_ATTACHMENTS_DOWNLOAD` (  `id` int(11) unsigned NOT NULL auto_increment,  `id_parent_product` int(11) NOT NULL,  `file_path` VARCHAR(150) NOT NULL,  `file_name` VARCHAR(150) NOT NULL,  `content_type` varchar(50) NOT NULL,  `file_dida` text,  `file_label` int(11) UNSIGNED NOT NULL default '0',  `file_size` int(11) UNSIGNED NOT NULL default '0',  `insert_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,  PRIMARY KEY  (`id`),  KEY `Index_1` (`id_parent_product`)) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;
DROP TABLE IF EXISTS `PRODUCT_ATTACHMENTS_LABEL`;
CREATE TABLE IF NOT EXISTS `PRODUCT_ATTACHMENTS_LABEL` (  `id` int(11) unsigned NOT NULL auto_increment,  `description` VARCHAR(50) NOT NULL,  PRIMARY KEY  (`id`),  KEY `Index_1` (`description`)) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;
DROP TABLE IF EXISTS `PRODUCT_LANGUAGES`;
CREATE TABLE `PRODUCT_LANGUAGES` (  `id_language` int(11) NOT NULL,  `id_parent_product` int(11) NOT NULL,  PRIMARY KEY (`id_language`, `id_parent_product`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS `PRODUCT_CATEGORIES`;
CREATE TABLE `PRODUCT_CATEGORIES` (  `id_category` int(11) NOT NULL,  `id_parent_product` int(11) NOT NULL,  PRIMARY KEY (`id_category`, `id_parent_product`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS `PRODUCT_FIELDS`;
CREATE TABLE `PRODUCT_FIELDS` (  `id` int(11) unsigned NOT NULL auto_increment,  `id_parent_product` int(11) NOT NULL,  `description` varchar(150) NOT NULL,  `group_description` varchar(150) DEFAULT NULL,  `type` int(11) unsigned NOT NULL,  `type_content` int(11) unsigned NOT NULL,  `sorting` int(3) unsigned NOT NULL DEFAULT 0,  `required` smallint(1) UNSIGNED NOT NULL DEFAULT 0,  `enabled` smallint(1) UNSIGNED NOT NULL DEFAULT 0,  `max_lenght` int(3) UNSIGNED DEFAULT NULL,  `editable` smallint(1) UNSIGNED NOT NULL DEFAULT 0,  `common` smallint(1) UNSIGNED NOT NULL DEFAULT 0,  `value` TEXT DEFAULT NULL,  PRIMARY KEY  (`id`),  KEY `Index_3` (`id_parent_product`),  KEY `Index_4` (`type`),  KEY `Index_5` (`value`(250))) ENGINE=InnoDB DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS `PRODUCT_FIELDS_VALUES`;
CREATE TABLE `PRODUCT_FIELDS_VALUES` (  `id_parent_field` int(11) unsigned NOT NULL,  `value` varchar(250) NOT NULL,  `sorting` int(3) unsigned NOT NULL DEFAULT 0,  `quantity` int(10) unsigned,  PRIMARY KEY  (`id_parent_field`,`value`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS `PRODUCT_FIELDS_REL_VALUES`;
CREATE TABLE IF NOT EXISTS `PRODUCT_FIELDS_REL_VALUES` (  `id_product` int(11) NOT NULL,  `id_field` int(11) NOT NULL,  `field_val` varchar(250) NOT NULL,  `id_field_rel` int(11) NOT NULL,  `field_rel_val` varchar(250) NOT NULL,  `field_rel_name` varchar(250) NOT NULL,  `quantity` int(10) unsigned NOT NULL,  KEY `kid_product` (`id_product`),  KEY `kid_field` (`id_field`),  KEY `kfield_val` (`field_val`),  KEY `kid_field_rel` (`id_field_rel`),  KEY `kfield_rel_val` (`field_rel_val`),  KEY `kfield_rel_name` (`field_rel_name`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS `PRODUCT_MAIN_FIELD_TRANSLATION`;
CREATE TABLE IF NOT EXISTS `PRODUCT_MAIN_FIELD_TRANSLATION` (  `id` int(11) unsigned NOT NULL auto_increment,  `id_prod` int(10) NOT NULL,  `main_field` int(3) NOT NULL,  `lang_code` varchar(2) NOT NULL,  `value` text,  PRIMARY KEY  (`id`),  UNIQUE KEY `Index_Pmft` (`id_prod`,`main_field`,`lang_code`),  INDEX `Index_Pmfti`(`id_prod`),  INDEX `Index_Pmftm`(`main_field`),  INDEX `Index_Pmftl`(`lang_code`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS `PRODUCT_FIELD_TRANSLATION`;
CREATE TABLE IF NOT EXISTS `PRODUCT_FIELD_TRANSLATION` (  `id` int(11) unsigned NOT NULL auto_increment,  `id_prod` int(10) NOT NULL,  `id_field` int(3) NOT NULL,  `type` varchar(10) NOT NULL,  `base_val` varchar(250) default NULL,  `lang_code` varchar(2) NOT NULL,  `value` text,  PRIMARY KEY  (`id`),  UNIQUE KEY `Index_Pmft` (`id_prod`,`id_field`,`type`,`base_val`,`lang_code`),  INDEX `Index_Pmfti`(`id_prod`),  INDEX `Index_Pmftm`(`id_field`),  INDEX `Index_Pmftt`(`type`),  INDEX `Index_Pmftl`(`lang_code`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS `PRODUCT_ROTATION`;
CREATE TABLE `PRODUCT_ROTATION` (  `id_rotation_mode` int(11) NOT NULL,  `id_parent_product` int(11) NOT NULL,  `rotation_value` varchar(50),  `last_update` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,  PRIMARY KEY (`id_rotation_mode`, `id_parent_product`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS `PRODUCT_RELATIONS`;
CREATE TABLE IF NOT EXISTS `PRODUCT_RELATIONS` (  `id_parent_product` int(11) NOT NULL,  `id_product_rel` int(11) NOT NULL,  UNIQUE KEY `Index_Rp` (`id_parent_product`,`id_product_rel`),  INDEX `Index_RpP`(`id_parent_product`),  INDEX `Index_RpPr`(`id_product_rel`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS `PRODUCT_CALENDAR`;
CREATE TABLE IF NOT EXISTS `PRODUCT_CALENDAR` (  `id` int(11) unsigned NOT NULL auto_increment,  `id_parent_product` int(11) NOT NULL,  `start_date` timestamp NOT NULL,  `availability` int(10) NOT NULL DEFAULT 0,    `unit` int(10) NOT NULL DEFAULT 0,   `content` text,  PRIMARY KEY  (`id`),  KEY `Index_1` (`id_parent_product`),  KEY `Index_2` (`start_date`)) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;
DROP TABLE IF EXISTS `BILLING`;
CREATE TABLE IF NOT EXISTS `BILLING` (  `id` int(11) unsigned NOT NULL auto_increment,  `id_parent_order` int(11) NOT NULL,  `order_amount` DECIMAL(20,4) NOT NULL default '0.00',  `name` varchar(100) default NULL,  `cfiscvat` varchar(30) default NULL,  `address` varchar(250) default NULL,  `city` varchar(100) default NULL,  `zip_code` varchar(20) default NULL,  `country` varchar(100) default NULL,  `state_region` varchar(100) default NULL, `phone` varchar(50) default NULL, `last_update` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,  `insert_date` timestamp NOT NULL,  `order_date` timestamp NOT NULL, `id_registered_billing` int(11) NOT NULL default '0', `registered_date` timestamp NOT NULL,   PRIMARY KEY  (`id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS `BILLING_DATA`;
CREATE TABLE IF NOT EXISTS `BILLING_DATA` (  `id` int(11) unsigned NOT NULL auto_increment,  `name` varchar(100) default NULL,  `cfiscvat` varchar(30) default NULL,  `address` varchar(250) default NULL,  `city` varchar(100) default NULL,  `zip_code` varchar(20) default NULL,  `country` varchar(100) default NULL,  `state_region` varchar(100) default NULL,  `phone` varchar(50) default NULL,  PRIMARY KEY  (`id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS `SHIPPING_ADDRESS`;
CREATE TABLE IF NOT EXISTS `SHIPPING_ADDRESS` (  `id` int(11) unsigned NOT NULL auto_increment,  `id_user` int(11) NOT NULL,  `name` varchar(100) default NULL,  `surname` varchar(100) default NULL,  `cfiscvat` varchar(30) default NULL,  `address` varchar(250) default NULL,  `city` varchar(100) default NULL,  `zip_code` varchar(20) default NULL,  `country` varchar(100) default NULL,  `state_region` varchar(100) default NULL,  `is_company_client` SMALLINT(1) UNSIGNED NOT NULL default '0',    PRIMARY KEY  (`id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS `ORDER_SHIPPING_ADDRESS`;
CREATE TABLE IF NOT EXISTS `ORDER_SHIPPING_ADDRESS` (  `id_order` int(11) NOT NULL,  `name` varchar(100) default NULL,  `surname` varchar(100) default NULL,  `cfiscvat` varchar(30) default NULL,  `address` varchar(250) default NULL,  `city` varchar(100) default NULL,  `zip_code` varchar(20) default NULL,  `country` varchar(100) default NULL,  `state_region` varchar(100) default NULL,  `is_company_client` SMALLINT(1) UNSIGNED NOT NULL default '0',PRIMARY KEY (`id_order`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS `BILLS_ADDRESS`;
CREATE TABLE IF NOT EXISTS `BILLS_ADDRESS` (  `id` int(11) unsigned NOT NULL auto_increment,  `id_user` int(11) NOT NULL,  `name` varchar(100) default NULL,  `surname` varchar(100) default NULL,  `cfiscvat` varchar(30) default NULL,  `address` varchar(250) default NULL,  `city` varchar(100) default NULL,  `zip_code` varchar(20) default NULL,  `country` varchar(100) default NULL,  `state_region` varchar(100) default NULL,  PRIMARY KEY  (`id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS `ORDER_BILLS_ADDRESS`;
CREATE TABLE IF NOT EXISTS `ORDER_BILLS_ADDRESS` (  `id_order` int(11) NOT NULL,  `name` varchar(100) default NULL,  `surname` varchar(100) default NULL,  `cfiscvat` varchar(30) default NULL,  `address` varchar(250) default NULL,  `city` varchar(100) default NULL,  `zip_code` varchar(20) default NULL,  `country` varchar(100) default NULL,  `state_region` varchar(100) default NULL, PRIMARY KEY (`id_order`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS `SHOPPING_CART`;
CREATE TABLE IF NOT EXISTS `SHOPPING_CART` (  `id` int(11) unsigned NOT NULL auto_increment,  `id_user` int(11) NOT NULL,  `last_update` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,  PRIMARY KEY  (`id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;
DROP TABLE IF EXISTS `SHOPPING_CART_PRODUCT`;
CREATE TABLE IF NOT EXISTS `SHOPPING_CART_PRODUCT` (  `id_cart` int(11) NOT NULL,  `id_prod` int(11) NOT NULL,  `prod_counter` int(11) NOT NULL,  `prod_quantity` int(10) NOT NULL,  `prod_type` smallint(1) unsigned NOT NULL,  `prod_name` varchar(250) NOT NULL,  `id_ads` int(11) NOT NULL default '-1',  PRIMARY KEY  (`id_cart`,`id_prod`,`prod_counter`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS `SHOPPING_CART_PRODUCT_FIELD`;
CREATE TABLE IF NOT EXISTS `SHOPPING_CART_PRODUCT_FIELD` (  `id_cart` int(11) NOT NULL,  `id_prod` int(11) NOT NULL,  `prod_counter` INTEGER UNSIGNED NOT NULL,  `id_field` int(11) NOT NULL,  `field_type` int(11) NOT NULL,  `prod_quantity` int(10) NOT NULL,  `value` varchar(250) NOT NULL,  `description` varchar(150) NOT NULL,  PRIMARY KEY  (`id_cart`,`id_prod`,`prod_counter`,`id_field`,`value`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS `SHOPPING_CART_PRODUCT_CALENDAR`;
CREATE TABLE IF NOT EXISTS `SHOPPING_CART_PRODUCT_CALENDAR` (  `id_cart` int(11) NOT NULL,  `id_prod` int(11) NOT NULL,  `prod_counter` INTEGER UNSIGNED NOT NULL,  `date` timestamp NOT NULL,  `adults` int(11) NOT NULL DEFAULT '0',  `children` int(11) NOT NULL DEFAULT '0',  `rooms` int(11) NOT NULL DEFAULT '0',  `children_age` varchar(100) NOT NULL,  `search_text` varchar(250) NOT NULL,  PRIMARY KEY  (`id_cart`,`id_prod`,`prod_counter`,`date`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS `ORDERS`;
CREATE TABLE IF NOT EXISTS `ORDERS` (  `id` int(11) unsigned NOT NULL auto_increment,  `id_user` int(11) NOT NULL default '-1',  `guid` varchar(100) NOT NULL,  `notes` text,  `status` int(1) unsigned NOT NULL default '0',  `amount` DECIMAL(20,4) NOT NULL default '0.00',  `taxable` DECIMAL(20,4) NOT NULL default '0.00',  `supplement` decimal(20,4) NOT NULL default '0.00',  `payment_id` int(11) unsigned NOT NULL default '0',  `payment_commission` decimal(20,4) NOT NULL default '0.00',  `payment_done` smallint(1) unsigned NOT NULL DEFAULT '0', `download_notified` smallint(1) unsigned NOT NULL DEFAULT '0',  `no_registration` smallint(1) unsigned NOT NULL DEFAULT '0',  `mail_sent` smallint(1) unsigned NOT NULL DEFAULT '0',  `ads_enabled` smallint(1) unsigned NOT NULL DEFAULT '0',  `last_update` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,  `insert_date` timestamp NOT NULL,  PRIMARY KEY  (`id`),  KEY `Index_user` (`id_user`),  KEY `Index_guid` (`guid`)) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;
DROP TABLE IF EXISTS `ORDER_PRODUCTS`;
CREATE TABLE IF NOT EXISTS `ORDER_PRODUCTS` (  `id_order` int(11) NOT NULL,  `id_prod` int(11) NOT NULL,  `prod_counter` int(11) NOT NULL,  `prod_quantity` int(11) unsigned NOT NULL,  `prod_type` smallint(1) unsigned NOT NULL default '0',  `prod_name` varchar(250) NOT NULL,  `amount` DECIMAL(20,4) NOT NULL default '0.00',  `taxable` DECIMAL(20,4) NOT NULL default '0.00',  `supplement` decimal(20,4) NOT NULL default '0.00', `discount_perc` decimal(20,4) NOT NULL default '0.00',  `discount` decimal(20,4) NOT NULL default '0.00',  `margin` decimal(20,4) NOT NULL default '0.00',  `supplement_desc` varchar(100) DEFAULT NULL,  `id_ads` int(11) NOT NULL default '-1',  PRIMARY KEY  (`id_order`,`id_prod`,`prod_counter`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS `ORDER_PRODUCT_FIELDS`;
CREATE TABLE IF NOT EXISTS `ORDER_PRODUCT_FIELDS` (  `id_order` int(11) NOT NULL,  `id_prod` int(11) NOT NULL,  `prod_counter` int(11) NOT NULL,  `id_field` int(11) NOT NULL,  `field_type` int(11) NOT NULL,  `value` varchar(250) NOT NULL,  `prod_quantity` int(11) NOT NULL,  `description` varchar(250) NOT NULL,  PRIMARY KEY  (`id_order`,`id_prod`,`prod_counter`,`id_field`,`field_type`,`value`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS `ORDER_PRODUCT_CALENDAR`;
CREATE TABLE IF NOT EXISTS `ORDER_PRODUCT_CALENDAR` (  `id_order` int(11) NOT NULL,  `id_prod` int(11) NOT NULL,  `prod_counter` INTEGER UNSIGNED NOT NULL,  `date` timestamp NOT NULL,  `adults` int(11) NOT NULL DEFAULT '0',  `children` int(11) NOT NULL DEFAULT '0',  `rooms` int(11) NOT NULL DEFAULT '0',  `children_age` varchar(100) NOT NULL,  `search_text` varchar(250) NOT NULL,  PRIMARY KEY  (`id_order`,`id_prod`,`prod_counter`,`date`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS `ORDER_PRODUCT_ATTACHMENT_DOWNLOAD`;
CREATE TABLE `ORDER_PRODUCT_ATTACHMENT_DOWNLOAD` (`id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,`id_order` INT(11) NOT NULL ,`id_parent_product` INT(11) NOT NULL ,`id_down_file` INT(11) NOT NULL ,`id_user` INT(11) NOT NULL ,`active` SMALLINT(1) UNSIGNED NOT NULL default '0',`max_download` INT(3) NOT NULL  default '-1',`insert_date` TIMESTAMP NOT NULL ,`expire_date` datetime NOT NULL default '9999-12-31 23:59:59',`download_date` datetime NOT NULL default '9999-12-31 23:59:59',`download_counter` INT(3) UNSIGNED NOT NULL  default '0', PRIMARY KEY  (`id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS `ORDER_FEES`;
CREATE TABLE `ORDER_FEES` (  `id_order` INT(11) NOT NULL ,  `id_fee` INT(11) NOT NULL ,  `amount` DECIMAL(20,4) NOT NULL default '0.00',  `taxable` DECIMAL(20,4) NOT NULL default '0.00',  `supplement` decimal(20,4) NOT NULL default '0.00',    `fee_desc` varchar(100) DEFAULT NULL,  `autoactive` SMALLINT(1) UNSIGNED NOT NULL default '0',  `required` SMALLINT(1) UNSIGNED NOT NULL default '0',  `multiply` SMALLINT(1) UNSIGNED NOT NULL default '0',  `fee_group` VARCHAR(100) default NULL,  `ext_provider` SMALLINT(1) NOT NULL default '0', `shipping_enabled` smallint(1) NOT NULL default '0',  `shipping_response` text,  PRIMARY KEY  (`id_order`,`id_fee`))ENGINE = InnoDB  DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS `ADS`;
CREATE TABLE IF NOT EXISTS `ADS` (  `id` int(11) unsigned NOT NULL auto_increment,  `id_element` int(11) NOT NULL,  `id_user` int(11) NOT NULL,  `phone` varchar(100) DEFAULT NULL,  `type` int(1) unsigned NOT NULL default '0',  `price` decimal(20,4) DEFAULT NULL,  `insert_date` timestamp NOT NULL default CURRENT_TIMESTAMP,  PRIMARY KEY  (`id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS `ADS_PROMOTION`;
CREATE TABLE IF NOT EXISTS `ADS_PROMOTION` (  `id_ads` int(11) NOT NULL,  `id_element` int(11) NOT NULL,  `cod_element` VARCHAR(100) NOT NULL,  `active` SMALLINT(1) UNSIGNED NOT NULL default '0',  `insert_date` timestamp NOT NULL default CURRENT_TIMESTAMP,  PRIMARY KEY  (`id_ads`,`id_element`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS `BUSINESS_RULE`;
CREATE TABLE IF NOT EXISTS `BUSINESS_RULE` (  `id` int(11) unsigned NOT NULL auto_increment,  `rule_type` int(10) unsigned NOT NULL,  `label` varchar(100) NOT NULL,  `description` text,  `active` smallint(1) unsigned NOT NULL default '0',  `voucher_id` int(10) NOT NULL default '-1',  PRIMARY KEY  (`id`),  KEY `Index_label` (`label`)) ENGINE=InnoDB  DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS `BUSINESS_RULE_CONFIG`;
CREATE TABLE IF NOT EXISTS `BUSINESS_RULE_CONFIG` (  `id` int(11) unsigned NOT NULL auto_increment,  `id_rule` int(11) NOT NULL,  `id_product` int(11) NOT NULL default '-1',  `id_product_ref` int(10) NOT NULL default '-1',  `rate_from` decimal(20,4) NOT NULL default '0.00',  `rate_to` decimal(20,4) NOT NULL default '0.00',  `rate_from_ref` decimal(20,4) NOT NULL default '0.00',  `rate_to_ref` decimal(20,4) NOT NULL default '0.00',  `operation` smallint(1) unsigned NOT NULL default '0' COMMENT 'tipo di operatione da eseguire: 0 nulla, 1 somma, 2 sottrazione;',  `applyto` smallint(1) unsigned NOT NULL default '0' COMMENT 'a chi deve essere applicata la regola: 0 nulla, 1 a prod_orig, 2 a prod_ref, 3 al meno caro, 4 al pi√π caro, 5 a tutti e due;',  `apply_to_quantity` int(10) unsigned NOT NULL default '0' COMMENT 'per quale quantit√†¬† deve essere applicata la regola',  `value` decimal(20,4) NOT NULL default '0.00',  PRIMARY KEY  (`id`),  UNIQUE KEY `Index_U` (`id_rule`,`id_product`,`rate_from`,`rate_to`,`id_product_ref`),  KEY `Index_From` (`rate_from`),  KEY `Index_To` (`rate_to`),  KEY `Index_Val` (`value`)) ENGINE=InnoDB  DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS `ORDER_BUSINESS_RULES`;
CREATE TABLE IF NOT EXISTS `ORDER_BUSINESS_RULES` (  `id_rule` int(11) NOT NULL,  `id_order` int(11) NOT NULL,  `id_product` int(11) NOT NULL default '-1',  `product_counter` int(11) unsigned NOT NULL default '0',  `rule_type` int(10) unsigned NOT NULL,  `label` VARCHAR(100) NOT NULL,  `value` DECIMAL(20,4) NOT NULL,     PRIMARY KEY (`id_rule`,`id_order`,`id_product`,`product_counter`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS `VOUCHER_CAMPAIGN`;
CREATE TABLE IF NOT EXISTS `VOUCHER_CAMPAIGN` (  `id` int(11) unsigned NOT NULL auto_increment,  `label` varchar(100) NOT NULL,  `voucher_type` int(10) unsigned NOT NULL default '0' COMMENT 'tipo di voucher creato - 0=one shot, 1=per x volte, 2=one shot entro il periodo specificato, 3=per x volte entro il periodo specificato, 4=gift (come one shot ma con id_utente che ha fatto il regalo associato al voucher)',  `description` text,  `voucher_amount` decimal(20,4) NOT NULL,  `operation` smallint(1) unsigned NOT NULL default '0' COMMENT 'tipo di calcolo applicato - 0=percentuale, 1=fisso',  `active` smallint(1) unsigned NOT NULL default '0',  `max_generation` int(10) NOT NULL default '-1',  `max_usage` int(10) NOT NULL default '-1',  `enable_date` datetime NOT NULL default '9999-12-31 23:59:59',  `expire_date` datetime NOT NULL default '9999-12-31 23:59:59',  `exclude_prod_rule` smallint(1) unsigned NOT NULL default '0',  PRIMARY KEY  (`id`),  KEY `Index_label` (`label`)) ENGINE=InnoDB  DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS `VOUCHER_CODE`;
CREATE TABLE IF NOT EXISTS `VOUCHER_CODE` (  `id` int(11) unsigned NOT NULL auto_increment,  `code` varchar(100) NOT NULL COMMENT 'il codice voucher verr√† generato con un nuovo GUID ad hoc',  `voucher_campaign` int(10) NOT NULL,  `insert_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,  `usage_counter` int(10) unsigned NOT NULL default '0',  `id_user` int(10) unsigned default NULL,  PRIMARY KEY  (`id`,`code`),  KEY `Index_vc` (`voucher_campaign`)) ENGINE=InnoDB  DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS `ORDER_VOUCHERS`;
CREATE TABLE IF NOT EXISTS `ORDER_VOUCHERS` (  `id_order` int(11) NOT NULL,  `id_voucher` int(11) NOT NULL,  `voucher_code` varchar(100) NOT NULL,  `voucher_amount` decimal(20,4) NOT NULL,  `insert_date` TIMESTAMP NOT NULL ,  PRIMARY KEY  (`id_order`,`voucher_code`,`id_voucher`, `insert_date`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT INTO `MAIL` (`id`, `name`, `description`, `lang_code`, `receiver`, `sender`, `cc`, `bcc`, `priority`, `subject`, `body`, `active`, `body_html`, `base`, `modify_date`, `mail_category`) VALUES(17, 'product-unavailable', 'Template per l''invio della mail di comunicazione prodotto disattivato per esaurimento scorte di magazzino', '', 'info@neme-sys.it', 'info@neme-sys.it', '', '', 1, 'product unavailable', '<html>\r\n    <head>\r\n    </head>\r\n    <body>\r\n        [#content#]\r\n    </body>\r\n</html>', 1, 1, 1, '2015-11-12 22:54:17', 'comunicazioni interne');
INSERT INTO `MAIL` (`id`, `name`, `description`, `lang_code`, `receiver`, `sender`, `cc`, `bcc`, `priority`, `subject`, `body`, `active`, `body_html`, `base`, `modify_date`, `mail_category`) VALUES(18, 'order-confirmed', 'Template per l''invio della mail di conferma creazione ordine', '', 'info@neme-sys.it', 'info@neme-sys.it', '', '', 1, 'Conferma ordine!', '<html>\r\n    <head>\r\n    </head>\r\n    <body>\r\n        [#content#]\r\n    </body>\r\n</html>', 1, 1, 1, '2015-11-14 01:04:42', 'comunicazioni utente');
INSERT INTO `MAIL` (`id`, `name`, `description`, `lang_code`, `receiver`, `sender`, `cc`, `bcc`, `priority`, `subject`, `body`, `active`, `body_html`, `base`, `modify_date`, `mail_category`) VALUES(20, 'order-down-confirmed', 'Template per l''invio della mail di conferma download attachment per ordine', '', 'info@neme-sys.it', 'info@neme-sys.it', '', '', 1, 'Conferma download attachments!', '<html dir="ltr">\r\n    <head>\r\n        <title></title>\r\n    </head>\r\n    <body>\r\n        [#content#]<br />\r\n    </body>\r\n</html>', 1, 1, 1, '2016-01-18 23:19:23', 'comunicazioni utente');
INSERT INTO `MAIL` (`id`, `name`, `description`, `lang_code`, `receiver`, `sender`, `cc`, `bcc`, `priority`, `subject`, `body`, `active`, `body_html`, `base`, `modify_date`, `mail_category`) VALUES(21, 'order-shipping-mail', 'mail per l''invio di comunicazioni relative allo shipping di un ordine effettuato, con relativo tracking number e image label', '', 'info@neme-sys.it', 'info@neme-sys.it', '', '', 1, 'neme-sys .net - shipping order', '<html dir="ltr">\r\n    <head>\r\n        <title></title>\r\n    </head>\r\n    <body>\r\n        [#content#]\r\n    </body>\r\n</html>', 1, 1, 1, '2017-09-20 13:24:15', 'comunicazioni utente');
INSERT INTO `PRODUCT_ATTACHMENTS_LABEL` VALUES (1, 'img small');
INSERT INTO `PRODUCT_ATTACHMENTS_LABEL` VALUES (2, 'img big');
INSERT INTO `PRODUCT_ATTACHMENTS_LABEL` VALUES (3, 'img medium');
INSERT INTO `PRODUCT_ATTACHMENTS_LABEL` VALUES (4, 'img card');
INSERT INTO `PRODUCT_ATTACHMENTS_LABEL` VALUES (5, 'pdf');
INSERT INTO `PRODUCT_ATTACHMENTS_LABEL` VALUES (6, 'doc');
INSERT INTO `PRODUCT_ATTACHMENTS_LABEL` VALUES (7, 'audio-video');
INSERT INTO `PRODUCT_ATTACHMENTS_LABEL` VALUES (8, 'file protected');
INSERT INTO `PRODUCT_ATTACHMENTS_LABEL` VALUES (9, 'others...');
INSERT INTO `PAYMENT_MODULES_FIELDS` (`id`, `id_module`, `keyword`, `value`, `match_field`) VALUES(3,  2, 'EXTERNAL_URL', 'https://www.paypal.com/cgi-bin/webscr', NULL);
INSERT INTO `PAYMENT_MODULES_FIELDS` (`id`, `id_module`, `keyword`, `value`, `match_field`) VALUES(24, 2, 'ENDPOINT_URL', 'https://api-3t.paypal.com/nvp', NULL);
INSERT INTO `PAYMENT_MODULES_FIELDS` (`id`, `id_module`, `keyword`, `value`, `match_field`) VALUES(23, 2, 'PWD', NULL, NULL);
INSERT INTO `PAYMENT_MODULES_FIELDS` (`id`, `id_module`, `keyword`, `value`, `match_field`) VALUES(5,  2, 'USER', NULL, NULL);
INSERT INTO `PAYMENT_MODULES_FIELDS` (`id`, `id_module`, `keyword`, `value`, `match_field`) VALUES(10, 2, 'PAYMENTREQUEST_0_CURRENCYCODE', 'EUR', NULL);
INSERT INTO `PAYMENT_MODULES_FIELDS` (`id`, `id_module`, `keyword`, `value`, `match_field`) VALUES(11, 2, 'LOGOIMG', NULL, NULL);
INSERT INTO `PAYMENT_MODULES_FIELDS` (`id`, `id_module`, `keyword`, `value`, `match_field`) VALUES(14, 2, 'SIGNATURE', NULL, NULL);
INSERT INTO `PAYMENT_MODULES_FIELDS` (`id`, `id_module`, `keyword`, `value`, `match_field`) VALUES(18, 1, 'EXTERNAL_URL', 'https://ecomm.sella.it/pagam/pagam.aspx', NULL);
INSERT INTO `PAYMENT_MODULES_FIELDS` (`id`, `id_module`, `keyword`, `value`, `match_field`) VALUES(19, 1, 'currency', '242', NULL);
INSERT INTO `PAYMENT_MODULES_FIELDS` (`id`, `id_module`, `keyword`, `value`, `match_field`) VALUES(20, 1, 'shoplogin', '', NULL);
INSERT INTO `PAYMENT_MODULES` (`id`,`name`,`icon`,`id_order_field`,`ip_provider`) VALUES (1,'sella','<img src="/common/img/credit_cards.png" border="0" align="absmiddle">','shoptransactionid|b','');
INSERT INTO `PAYMENT_MODULES` (`id`,`name`,`icon`,`id_order_field`,`ip_provider`) VALUES (2,'paypal','<a href="#" onclick=javascript:window.open("https://www.paypal.com/us/cgi-bin/webscr?cmd=xpt/Marketing/popup/OLCWhatIsPayPal-outside","olcwhatispaypal","toolbar=no, location=no, directories=no, status=no, menubar=no, scrollbars=yes, resizable=yes, width=400, height=350");><img  src="https://www.paypal.com/en_US/i/logo/PayPal_mark_50x34.gif" border="0" alt="Acceptance Mark" align="absmiddle"></a>','','212.48.8.140|87.0.139.170');
INSERT INTO `CURRENCY` (`id`,`currency`,`rate`,`refer_date`,`insert_date`,`active`,`is_default`) VALUES(1,'EUR','1.0000','2002-01-01','2002-01-01 00:00:00',1,1);
INSERT INTO `TEMPLATE` (`id`, `directory`, `lang_code`, `description`, `is_base`, `order_by`, `elem_x_page`, `modify_date`) VALUES (4, 'base-product', '', 'products', 0, 1, 10, '2013-06-14 19:51:06');
INSERT INTO `TEMPLATE_PAGES` (`id`, `templateid`, `file_path`, `file_name`, `priority`) VALUES (8, 4, 'product/', 'list.aspx', 1);
INSERT INTO `TEMPLATE_PAGES` (`id`, `templateid`, `file_path`, `file_name`, `priority`) VALUES (9, 4, 'product/', 'list.aspx.cs', -1);
INSERT INTO `TEMPLATE_PAGES` (`id`, `templateid`, `file_path`, `file_name`, `priority`) VALUES (10, 4, 'product/', 'detail.aspx', 2);
INSERT INTO `TEMPLATE_PAGES` (`id`, `templateid`, `file_path`, `file_name`, `priority`) VALUES (11, 4, 'product/', 'detail.aspx.cs', -1);
INSERT INTO `TEMPLATE_PAGES` (`id`, `templateid`, `file_path`, `file_name`, `priority`) VALUES (12, 4, 'product/', 'ajaxcheckprodavailability.aspx', -1);
INSERT INTO `TEMPLATE_PAGES` (`id`, `templateid`, `file_path`, `file_name`, `priority`) VALUES (13, 4, 'product/', 'ajaxcheckprodfieldsqta.aspx', -1);
INSERT INTO `TEMPLATE_PAGES` (`id`, `templateid`, `file_path`, `file_name`, `priority`) VALUES (14, 4, 'product/', 'ajaxcheckprodqta.aspx', -1);