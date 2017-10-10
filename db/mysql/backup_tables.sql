-- --------------------------------------------------------
-- 
-- Structure of table `MODULES`
-- 
DROP TABLE IF EXISTS `MODULES`;
CREATE TABLE IF NOT EXISTS `MODULES` (
  `keyword` varchar(100) NOT NULL,
  `description` TEXT default NULL,
  `version` varchar(100) NOT NULL,
  `active` char(1) NOT NULL default '0',
  `insert_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`keyword`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `CATEGORY`
-- 
DROP TABLE IF EXISTS `CATEGORY`;
CREATE TABLE IF NOT EXISTS `CATEGORY` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `num_menu` smallint(2) NOT NULL default '1',
  `hierarchy` varchar(100) NOT NULL,
  `description` varchar(250) default NULL,
  `has_elements` smallint(1) unsigned NOT NULL default '0',
  `visible` smallint(1) unsigned NOT NULL default '0',
  `id_template` int(11) default NULL,
  `meta_description` TEXT default NULL,
  `meta_keyword` TEXT default NULL,
  `page_title` TEXT default NULL,
  `sub_domain_url` varchar(250) default NULL,  
  `automatic` smallint(1) unsigned NOT NULL default '0',  
  `file_path` varchar(250) default NULL,
  PRIMARY KEY  (`id`),
  KEY `num_menu` (`num_menu`),
  KEY `hierarchy` (`hierarchy`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;


-- --------------------------------------------------------
-- 
-- Structure of table `CATEGORY_TEMPLATES`
-- 
DROP TABLE IF EXISTS `CATEGORY_TEMPLATES`;
CREATE TABLE IF NOT EXISTS `CATEGORY_TEMPLATES` (
  `categoryid` int(11) NOT NULL,
  `templateid` int(11) NOT NULL,
  `templatepageid` int(11) NOT NULL,
  `lang_code` varchar(10) NOT NULL,
  `url_rewrite` varchar(250) default NULL, 
  PRIMARY KEY (`categoryid`, `templateid`, `templatepageid`, `lang_code`),
  KEY `url_rewrite` (`url_rewrite`)
)ENGINE = InnoDB  DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `LANGUAGE`
-- 
DROP TABLE IF EXISTS `LANGUAGE`;
CREATE TABLE IF NOT EXISTS `LANGUAGE` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `label` varchar(100)  NOT NULL,
  `description` varchar(250) default NULL,
  `lang_active` smallint(1) unsigned NOT NULL default '0',
  `subdomain_active` smallint(1) unsigned NOT NULL default '0',
  `url_subdomain` varchar(250) default NULL,
  PRIMARY KEY  (`id`),
  KEY `Index_1` (`label`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;


-- --------------------------------------------------------
-- 
-- Structure of table `AVAILABLE_LANGUAGES`
-- 
DROP TABLE IF EXISTS `AVAILABLE_LANGUAGES`;
CREATE TABLE IF NOT EXISTS `AVAILABLE_LANGUAGES` (
  `keyword` VARCHAR(6) NOT NULL,
  `description` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`keyword`)
) ENGINE = InnoDB  DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `LOGS`
-- 
DROP TABLE IF EXISTS `LOG`;
CREATE TABLE IF NOT EXISTS `LOG` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `msg` TEXT default NULL,
  `usr` varchar(50) NOT NULL,
  `type` varchar(15) NOT NULL,
  `date_event` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`),
  KEY `usr` (`usr`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;


-- --------------------------------------------------------
-- 
-- Structure of table `MULTI_LANGUAGES`
-- 
DROP TABLE IF EXISTS `MULTI_LANGUAGES`;
CREATE TABLE IF NOT EXISTS `MULTI_LANGUAGES` (
  `id` int(20) unsigned NOT NULL auto_increment,
  `keyword` varchar(250) NOT NULL,
  `lang_code` varchar(10) NOT NULL,
  `value` text,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `Index_ML` (`keyword`,`lang_code`),
  INDEX `Index_kw`(`keyword`),
  INDEX `Index_lc`(`lang_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `MAIL`
-- 
DROP TABLE IF EXISTS `MAIL`;
CREATE TABLE IF NOT EXISTS `MAIL` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `name` varchar(100) NOT NULL,
  `description` text,
  `lang_code` varchar(3) DEFAULT NULL,
  `receiver` text,
  `sender` text,
  `cc` text,
  `bcc` text,
  `priority` int(3) DEFAULT NULL,
  `subject` varchar(250),
  `body` text,
  `active` smallint(1) unsigned NOT NULL default '0',
  `body_html` smallint(1) unsigned NOT NULL default '0',
  `base` smallint(1) unsigned NOT NULL default '0',
  `modify_date` timestamp NOT NULL,
  `mail_category` varchar(150) DEFAULT NULL, 
  PRIMARY KEY  (`id`),
  UNIQUE KEY `Mail_UX` (`name`,`lang_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;


-- --------------------------------------------------------
-- 
-- Structure of table `COUNTRY`
-- 
DROP TABLE IF EXISTS `COUNTRY`;
CREATE TABLE IF NOT EXISTS `COUNTRY` (
`id` int(11) unsigned NOT NULL auto_increment,
  `country_code` VARCHAR(5) NOT NULL,
  `country_description` VARCHAR(100) NOT NULL,
  `state_region_code` VARCHAR(15) DEFAULT NULL,
  `state_region_description` VARCHAR(100) DEFAULT NULL,
  `active` SMALLINT(1) UNSIGNED NOT NULL default '0',
  `use_for` int(3) UNSIGNED DEFAULT NULL,  
  PRIMARY KEY (`id`),
  INDEX `Index_CC`(`country_code`),
  INDEX `Index_SRC`(`state_region_code`)
) ENGINE = InnoDB  DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `GOOGLEMAP_LOCALIZATION`
-- 
DROP TABLE IF EXISTS `GOOGLEMAP_LOCALIZATION`;
CREATE TABLE IF NOT EXISTS `GOOGLEMAP_LOCALIZATION` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `id_element` int(11) NOT NULL,
  `type` SMALLINT(1) UNSIGNED NOT NULL default '1',
  `latitude` decimal(10,6) DEFAULT NULL,
  `longitude` decimal(10,6) DEFAULT NULL, 
  `txtinfo` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `Index_gl` (`id_element`,`type`,`latitude`,`longitude`)
) ENGINE = InnoDB  DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `CONTENT`
-- 
DROP TABLE IF EXISTS `CONTENT`;
CREATE TABLE IF NOT EXISTS `CONTENT` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `title` varchar(250) NOT NULL,
  `summary` text,
  `description` text,
  `keyword` varchar(250) default NULL,
  `status` smallint(2) unsigned NOT NULL default '0',
  `meta_description` TEXT default NULL,
  `meta_keyword` TEXT default NULL,
  `page_title` TEXT default NULL,
  `id_user` INT(11) NOT NULL,
  `publish_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `insert_date` timestamp NOT NULL,
  `delete_date` datetime NOT NULL default '9999-12-31 23:59:59',
  PRIMARY KEY  (`id`),
  KEY `Index_2` (`title`),
  KEY `Index_3` (`keyword`),
  KEY `Index_4` (`id_user`),
  KEY `Index_5` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;


-- --------------------------------------------------------
-- 
-- Structure of table `CONTENT_ATTACHMENTS`
-- 
DROP TABLE IF EXISTS `CONTENT_ATTACHMENTS`;
CREATE TABLE IF NOT EXISTS `CONTENT_ATTACHMENTS` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `id_parent_content` int(11) NOT NULL,
  `file_path` VARCHAR(150) NOT NULL,
  `file_name` VARCHAR(150) NOT NULL,
  `content_type` varchar(50) NOT NULL,
  `file_dida` text,
  `file_label` int(11) UNSIGNED NOT NULL default '0',
  `insert_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`),
  KEY `Index_1` (`id_parent_content`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;


-- --------------------------------------------------------
-- 
-- Structure of table `CONTENT_ATTACHMENTS_LABEL`
-- 
DROP TABLE IF EXISTS `CONTENT_ATTACHMENTS_LABEL`;
CREATE TABLE IF NOT EXISTS `CONTENT_ATTACHMENTS_LABEL` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `description` VARCHAR(50) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `Index_1` (`description`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;


-- --------------------------------------------------------
-- 
-- Structure of table `CONTENT_LANGUAGES`
-- 
DROP TABLE IF EXISTS `CONTENT_LANGUAGES`;
CREATE TABLE `CONTENT_LANGUAGES` (
  `id_language` int(11) NOT NULL,
  `id_parent_content` int(11) NOT NULL,
  PRIMARY KEY (`id_language`, `id_parent_content`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `CONTENT_CATEGORIES`
-- 
DROP TABLE IF EXISTS `CONTENT_CATEGORIES`;
CREATE TABLE `CONTENT_CATEGORIES` (
  `id_category` int(11) NOT NULL,
  `id_parent_content` int(11) NOT NULL,
  PRIMARY KEY (`id_category`, `id_parent_content`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `CONTENT_DOWNLOADS`
-- 
DROP TABLE IF EXISTS `CONTENT_DOWNLOADS`;
CREATE TABLE IF NOT EXISTS `CONTENT_DOWNLOADS` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `attachid` INT(11) NOT NULL ,
  `id_user` INT(11) default NULL ,
  `user_host` varchar(100) default NULL,
  `user_info` varchar(250) default NULL,
  `file_path` varchar(150) NOT NULL,
  `file_name` varchar(150) NOT NULL,
  `content_type` varchar(50) NOT NULL,
  `download_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`),
  KEY `Index_1` (`attachid`),
  KEY `Index_2` (`id_user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;


-- --------------------------------------------------------
-- 
-- Structure of table `CONTENT_FIELDS`
-- 
DROP TABLE IF EXISTS `CONTENT_FIELDS`;
CREATE TABLE `CONTENT_FIELDS` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `id_parent_content` int(11) NOT NULL,
  `description` varchar(150) NOT NULL,
  `group_description` varchar(150) DEFAULT NULL,
  `type` int(11) unsigned NOT NULL,
  `type_content` int(11) unsigned NOT NULL,
  `sorting` int(3) unsigned NOT NULL DEFAULT 0,
  `required` smallint(1) UNSIGNED NOT NULL DEFAULT 0,
  `enabled` smallint(1) UNSIGNED NOT NULL DEFAULT 0,
  `max_lenght` int(3) UNSIGNED DEFAULT NULL,
  `editable` smallint(1) UNSIGNED NOT NULL DEFAULT 0,
  `for_blog` smallint(1) UNSIGNED NOT NULL DEFAULT 0,
  `common` smallint(1) UNSIGNED NOT NULL DEFAULT 0,
  `value` TEXT DEFAULT NULL,
  PRIMARY KEY  (`id`),
  KEY `Index_3` (`id_parent_content`),
  KEY `Index_4` (`type`),
  KEY `Index_5` (`value`(250))
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `CONTENT_FIELDS_VALUES`
-- 
DROP TABLE IF EXISTS `CONTENT_FIELDS_VALUES`;
CREATE TABLE `CONTENT_FIELDS_VALUES` (
  `id_field` int(11) unsigned NOT NULL,
  `value` varchar(250) NOT NULL,
  `sorting` int(3) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY  (`id_field`,`value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `SYSTEM_FIELDS_TYPE`
-- 
DROP TABLE IF EXISTS `SYSTEM_FIELDS_TYPE`;
CREATE TABLE `SYSTEM_FIELDS_TYPE` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `description` varchar(100) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `SYSTEM_FIELDS_TYPE_CONTENT`
-- 
DROP TABLE IF EXISTS `SYSTEM_FIELDS_TYPE_CONTENT`;
CREATE TABLE `SYSTEM_FIELDS_TYPE_CONTENT` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `description` varchar(100) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `NEWSLETTER`
-- 
DROP TABLE IF EXISTS `NEWSLETTER`;
CREATE TABLE IF NOT EXISTS `NEWSLETTER` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `description` varchar(150) NOT NULL,
  `active` smallint(1) unsigned NOT NULL default '0',
  `templateid` int(11) NOT NULL default '-1',
  `id_voucher_campaign` int(11) default '-1',
  `modify_date` timestamp NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `Index_active` (`active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `TEMPLATE`
-- 
DROP TABLE IF EXISTS `TEMPLATE`;
CREATE TABLE IF NOT EXISTS `TEMPLATE` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `directory` varchar(250) NOT NULL,
  `description` varchar(250) default NULL,
  `is_base` smallint(1) unsigned NOT NULL DEFAULT '0',
  `order_by` int(2) unsigned NOT NULL DEFAULT '0',
  `elem_x_page` int(3) unsigned NOT NULL DEFAULT '1',
  `modify_date` timestamp NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `Index_dir` (`directory`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;


-- --------------------------------------------------------
-- 
-- Structure of table `TEMPLATE_PAGES`
-- 
DROP TABLE IF EXISTS `TEMPLATE_PAGES`;
CREATE TABLE IF NOT EXISTS `TEMPLATE_PAGES` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `templateid` int(11) NOT NULL,
  `file_path` VARCHAR(100) NOT NULL,
  `file_name` VARCHAR(100) NOT NULL,
  `priority` INTEGER NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  INDEX `Index_2`(`templateid`),
  INDEX `Index_3`(`priority`)
)ENGINE = InnoDB  DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `USER`
-- 
DROP TABLE IF EXISTS `USER`;
CREATE TABLE IF NOT EXISTS `USER` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `username` varchar(100) NOT NULL,
  `password` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `role` int(10) unsigned NOT NULL,
  `privacy` smallint(1) NOT NULL DEFAULT '0',
  `newsletter` smallint(1) NOT NULL DEFAULT '0',
  `active` smallint(1) NOT NULL DEFAULT '0',
  `discount` DECIMAL(20,4) NOT NULL default '0',
  `bo_comments` text,
  `insert_date` timestamp NOT NULL,
  `modify_date` timestamp NOT NULL,
  `public` INTEGER(1) UNSIGNED NOT NULL DEFAULT 0,
  `user_group` int(11) default NULL,  
  `automatic` smallint(1) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;


-- --------------------------------------------------------
-- 
-- Structure of table `USER_ATTACHMENTS`
-- 
DROP TABLE IF EXISTS `USER_ATTACHMENTS`;
CREATE TABLE IF NOT EXISTS `USER_ATTACHMENTS` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `id_user` INTEGER NOT NULL,
  `filename` varchar(250) NOT NULL,
  `content_type` varchar(50) NOT NULL,
  `path` varchar(250) NOT NULL,
  `file_dida` text,
  `file_label` varchar(100) NOT NULL,
  `is_avatar` smallint(1) NOT NULL DEFAULT 0,
  `insert_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`),
  KEY `Index_2` (`id_user`),
  KEY `Index_3` (`file_label`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;


-- --------------------------------------------------------
-- 
-- Structure of table `USER_FRIENDS`
-- 
DROP TABLE IF EXISTS `USER_FRIENDS`;
CREATE TABLE `USER_FRIENDS` (
  `id_friend` int(11) NOT NULL,
  `id_parent_user` int(11) NOT NULL,
  `active` smallint(1) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`id_friend`, `id_parent_user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `USER_LANGUAGES`
-- 
DROP TABLE IF EXISTS `USER_LANGUAGES`;
CREATE TABLE `USER_LANGUAGES` (
  `id_language` int(11) NOT NULL,
  `id_parent_user` int(11) NOT NULL,
  PRIMARY KEY (`id_language`, `id_parent_user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `USER_CATEGORIES`
-- 
DROP TABLE IF EXISTS `USER_CATEGORIES`;
CREATE TABLE `USER_CATEGORIES` (
  `id_category` int(11) NOT NULL,
  `id_parent_user` int(11) NOT NULL,
  PRIMARY KEY (`id_category`, `id_parent_user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `USER_CONFIRMATION`
-- 
DROP TABLE IF EXISTS `USER_CONFIRMATION`;
CREATE TABLE IF NOT EXISTS `USER_CONFIRMATION` (
  `id_user` int(11) NOT NULL,
  `confirmation_code` varchar(100) NOT NULL,
  PRIMARY KEY  (`id_user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `USER_GROUP`
-- 
DROP TABLE IF EXISTS `USER_GROUP`;
CREATE TABLE IF NOT EXISTS `USER_GROUP` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `short_desc` varchar(100) NOT NULL,
  `long_desc` text,
  `default_group` smallint(1) unsigned NOT NULL default '0',
  `supplement_group` INT(11) UNSIGNED DEFAULT NULL ,  
  `discount` DECIMAL(20,4) NOT NULL default '0',
  `margin` DECIMAL(20,4) NOT NULL default '0',
  `apply_prod_discount` smallint(1) unsigned NOT NULL default '0',
  `apply_user_discount` smallint(1) unsigned NOT NULL default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;


-- --------------------------------------------------------
-- 
-- Structure of table `USER_NEWSLETTERS`
-- 
DROP TABLE IF EXISTS `USER_NEWSLETTERS`;
CREATE TABLE `USER_NEWSLETTERS` (
  `newsletterid` int(10) NOT NULL,
  `id_parent_user` int(10) NOT NULL,
  PRIMARY KEY  (`id_parent_user`,`newsletterid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `USER_FIELDS`
-- 
DROP TABLE IF EXISTS `USER_FIELDS`;
CREATE TABLE `USER_FIELDS` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `description` varchar(150) NOT NULL,
  `group_description` varchar(150) DEFAULT NULL,
  `type` int(11) unsigned NOT NULL,
  `type_content` int(11) unsigned NOT NULL,
  `sorting` int(3) unsigned NOT NULL DEFAULT 0,
  `required` smallint(1) UNSIGNED NOT NULL DEFAULT 0,
  `enabled` smallint(1) UNSIGNED NOT NULL DEFAULT 0,
  `max_lenght` int(3) UNSIGNED DEFAULT NULL,
  `use_for` smallint(1) UNSIGNED NOT NULL DEFAULT 1,
  `apply_to`SMALLINT(1) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY  (`id`),
  KEY `Index_4` (`type`),
  KEY `Index_5` (`description`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `USER_FIELDS_MATCH`
-- 
DROP TABLE IF EXISTS `USER_FIELDS_MATCH`;
CREATE TABLE `USER_FIELDS_MATCH` (
  `id_field` INTEGER NOT NULL,
  `id_parent_user` INTEGER NOT NULL,
  `value` text,
  PRIMARY KEY (`id_field`, `id_parent_user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `USER_FIELDS_VALUES`
-- 
DROP TABLE IF EXISTS `USER_FIELDS_VALUES`;
CREATE TABLE `USER_FIELDS_VALUES` (
  `id_field` int(11) unsigned NOT NULL,
  `value` varchar(250) NOT NULL,
  `sorting` int(3) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY  (`id_field`,`value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `USER_PREFERENCES`
-- 
DROP TABLE IF EXISTS `USER_PREFERENCES`;
CREATE TABLE `USER_PREFERENCES` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `id_user` int(11) NOT NULL,
  `id_friend` int(11) NOT NULL,
  `id_comment` int(11) DEFAULT 0,
  `comment_type` int(2) DEFAULT 0,
  `type` int(1) NOT NULL,
  `message` text,
  `insert_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `active` int(1) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY  (`id`),
  KEY `Index_2` (`id_user`),
  KEY `Index_3` (`id_friend`),
  KEY `Index_4` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `USER_DOWNLOADS`
-- 
DROP TABLE IF EXISTS `USER_DOWNLOADS`;
CREATE TABLE IF NOT EXISTS `USER_DOWNLOADS` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `id_file` INT(11) UNSIGNED NOT NULL ,
  `user` varchar(100) default NULL ,
  `user_host` varchar(100) default NULL,
  `user_info` varchar(250) default NULL,
  `filename` varchar(250) NOT NULL,
  `content_type` varchar(50) NOT NULL,
  `path` varchar(250) NOT NULL,
  `download_date` TIMESTAMP NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;


-- --------------------------------------------------------
-- 
-- Structure of table `COMMENT`
-- 
DROP TABLE IF EXISTS `COMMENT`;
CREATE TABLE IF NOT EXISTS `COMMENT` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `id_element` int(11) NOT NULL,
  `element_type` int(1) NOT NULL,
  `id_user` int(11) NOT NULL,
  `message` text,
  `insert_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `vote_type` int(1) unsigned NOT NULL DEFAULT 0,
  `active` int(1) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY  (`id`),
  KEY `Index_2` (`id_element`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;


-- ----------------------------------------------------------------------- -- ---------------------------------------- -- ----------------------------------------------------------------------- --
-- ----------------------------------------------------------------------- -- TABELLE ECONEME-SYS -- ----------------------------------------------------------------------- --
-- ----------------------------------------------------------------------- -- ---------------------------------------- -- ----------------------------------------------------------------------- --


-- --------------------------------------------------------
-- 
-- Structure of table `CURRENCY`
-- 
DROP TABLE IF EXISTS `CURRENCY`;
CREATE TABLE `CURRENCY` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `currency` varchar(5) NOT NULL,
  `rate` decimal(20,4) NOT NULL,
  `refer_date` date NOT NULL,
  `insert_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `active` smallint(1) unsigned NOT NULL default '0',
  `is_default` smallint(1) unsigned NOT NULL default '0',
  PRIMARY KEY  (`id`),
  KEY `currency` (`currency`),
  KEY `rate` (`rate`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;
		

-- --------------------------------------------------------
-- 
-- Structure of table `PAYMENT` e tabelle correlate
-- 
DROP TABLE IF EXISTS `PAYMENT`;
CREATE TABLE `PAYMENT` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `description` varchar(250) default NULL,
  `payment_data` varchar(250) NOT NULL,
  `commission` decimal(20,4) NOT NULL default '0.0000',
  `commission_type` SMALLINT(1) UNSIGNED NOT NULL  default '1',
  `external_url` smallint(1) unsigned NOT NULL default '0',
  `id_module` int(10) default NULL,
  `active` smallint(1) unsigned NOT NULL default '0',
  `payment_type` smallint(1) unsigned NOT NULL default '0',
  `apply_to`smallint(1) unsigned NOT NULL default '0',
  PRIMARY KEY  (`id`),
  KEY `id_module` (`id_module`),
  KEY `description` (`description`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `PAYMENT_FIELDS`;
CREATE TABLE `PAYMENT_FIELDS` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `id_payment` int(11) NOT NULL,
  `id_module` int(11) default NULL,
  `keyword` varchar(50) NOT NULL,
  `value` varchar(250) default NULL,
  `match_field` varchar(100) default NULL,
  PRIMARY KEY  USING BTREE (`id`),
  UNIQUE KEY `Index_UX` (`id_payment`,`id_module`,`keyword`,`match_field`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `PAYMENT_MODULES`;
CREATE TABLE `PAYMENT_MODULES` (
  `id` INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `icon` TEXT,
  `id_order_field` VARCHAR(150) NOT NULL,
  `ip_provider` VARCHAR(150) NOT NULL default '',
  PRIMARY KEY (`id`),
  INDEX `Index_2`(`name`),
  INDEX `Index_3`(`id_order_field`)
)ENGINE = InnoDB  DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `PAYMENT_MODULES_FIELDS`;
CREATE TABLE `PAYMENT_MODULES_FIELDS` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `id_module` int(11) default NULL,
  `keyword` varchar(50) NOT NULL,
  `value` varchar(250) default NULL,
  `match_field` varchar(100) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `Index_2` (`id_module`,`keyword`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `PAYMENT_TRANSACTIONS`;
CREATE TABLE `PAYMENT_TRANSACTIONS` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `id_order` int(11) NOT NULL,
  `id_module` INTEGER NOT NULL,
  `id_transaction` varchar(100) NOT NULL,
  `status` varchar(100) default NULL,
  `notified` smallint(1) unsigned NOT NULL default '0',
  `insert_date` datetime NOT NULL,
  PRIMARY KEY  (`id`),
  INDEX `Index_2` (`id_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `SUPPLEMENT`
-- 
DROP TABLE IF EXISTS `SUPPLEMENT`;
CREATE TABLE `SUPPLEMENT` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `description` VARCHAR(100) NOT NULL,
  `value` DECIMAL(20,4) NOT NULL default '0.0000',
  `type` SMALLINT(1) UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `Index_2`(`value`),
  INDEX `Index_3`(`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;


-- --------------------------------------------------------
-- 
-- Structure of table SUPPLEMENT_GROUP`
-- 
DROP TABLE IF EXISTS `SUPPLEMENT_GROUP`;
CREATE TABLE IF NOT EXISTS `SUPPLEMENT_GROUP` (  
  `id` int(11) unsigned NOT NULL auto_increment,
  `description` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `Index_TG_dc`(`description`)
) ENGINE = InnoDB  DEFAULT CHARSET=utf8;	

-- --------------------------------------------------------
-- 
-- Structure of table SUPPLEMENT_GROUP_VALUES`
-- 
DROP TABLE IF EXISTS `SUPPLEMENT_GROUP_VALUES`;
CREATE TABLE IF NOT EXISTS `SUPPLEMENT_GROUP_VALUES` (  
  `id` int(11) unsigned NOT NULL auto_increment,
  `id_group` int(11) NOT NULL,
  `country_code` VARCHAR(2) NOT NULL,
  `state_region_code` VARCHAR(10) DEFAULT NULL,
  `id_fee` int(11) NOT NULL,
  `exclude_calculation` SMALLINT(1) UNSIGNED NOT NULL default '0',
  PRIMARY KEY (`id`),
  INDEX `Index_TGV_ig`(`id_group`),		  
  INDEX `Index_TGV_cc`(`country_code`),		  
  INDEX `Index_TGV_src`(`state_region_code`)
) ENGINE = InnoDB  DEFAULT CHARSET=utf8;	


-- --------------------------------------------------------
-- 
-- Structure of table `FEE`
-- 
DROP TABLE IF EXISTS `FEE`;
CREATE TABLE IF NOT EXISTS `FEE` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `description` VARCHAR(150) NOT NULL,
  `amount` DECIMAL(20,4) NOT NULL,
  `type` SMALLINT(3) UNSIGNED NOT NULL,
  `id_supplement` int(11) NOT NULL default '-1',
  `supplement_group` int(11) NOT NULL default '-1', 
  `apply_to`SMALLINT(1) UNSIGNED,
  `autoactive` SMALLINT(1) UNSIGNED NOT NULL default '0',
  `multiply` SMALLINT(1) UNSIGNED NOT NULL default '0',
  `required` SMALLINT(1) UNSIGNED NOT NULL default '0',
  `fee_group` VARCHAR(100) default NULL, 
  `type_view` SMALLINT(1) UNSIGNED NOT NULL default '0',
  `ext_provider` SMALLINT(1) NOT NULL default '0',
  `ext_params` text,
  PRIMARY KEY (`id`),
  INDEX `Index_1`(`description`),
  INDEX `Index_2`(`amount`),
  INDEX `Index_3`(`id_supplement`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;


-- --------------------------------------------------------
-- 
-- Structure of table `FEE_CONFIG`
-- 
DROP TABLE IF EXISTS `FEE_CONFIG`;
CREATE TABLE IF NOT EXISTS `FEE_CONFIG` (
  `id`  int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_fee` int(11) NOT NULL,
  `desc_prod_field` VARCHAR(100) default NULL,
 `rate_from` DECIMAL(20,4) NOT NULL default '0.00',
 `rate_to` DECIMAL(20,4) NOT NULL default '0.00',
 `operation` SMALLINT( 1 ) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'operation type: 0 null, 1 sum, 2 substract;',
 `value` DECIMAL(20,4) NOT NULL,  
  PRIMARY KEY (`id`),
  UNIQUE KEY `Index_U` (`id_fee`,`desc_prod_field`,`rate_from`,`rate_to`),
  INDEX `Index_From`(`rate_from`),
  INDEX `Index_To`(`rate_to`),
  INDEX `Index_Val`(`value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;


-- --------------------------------------------------------
-- 
-- Structure of table `PRODUCT`
-- 
DROP TABLE IF EXISTS `PRODUCT`;
CREATE TABLE IF NOT EXISTS `PRODUCT` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `name` varchar(250) NOT NULL,
  `summary` text,
  `description` text,
  `keyword` varchar(250) default NULL,
  `status` smallint(2) unsigned NOT NULL default '0',
  `meta_description` TEXT default NULL,
  `meta_keyword` TEXT default NULL,
  `page_title` TEXT default NULL,
  `id_user` INT(11) NOT NULL,
  `publish_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `insert_date` timestamp NOT NULL,
  `delete_date` datetime NOT NULL default '9999-12-31 23:59:59',
  `price` decimal(20,4) NOT NULL,
  `discount` decimal(20,4) NOT NULL default '0',
  `quantity` int(10) NOT NULL,
  `set_buy_qta` smallint(1) unsigned NOT NULL default '0', 
  `id_supplement` int(10) default NULL,
  `id_supplement_group` INT( 10 ) DEFAULT NULL ,
  `prod_type` smallint(1) unsigned NOT NULL,
  `max_download` int(11) NOT NULL default '-1', 
  `max_download_time` int(11) NOT NULL default '-1', 
  `quantity_rotation_mode` int(3) NOT NULL default '0', 
  `rotation_mode_value` varchar(30) default NULL, 
  `reload_quantity` int(10) NOT NULL default '0',
  `weight` decimal(20,4) NOT NULL default '0',
  `length` decimal(20,4) NOT NULL default '0',
  `width` decimal(20,4) NOT NULL default '0',
  `height` decimal(20,4) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  KEY `Index_2` (`name`),
  KEY `Index_3` (`keyword`),
  KEY `Index_4` (`id_user`),
  KEY `Index_5` (`status`),
  KEY `Index_6` (`price`),
  KEY `Index_7` (`quantity_rotation_mode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;


-- --------------------------------------------------------
-- 
-- Structure of table `PRODUCT_ATTACHMENTS`
-- 
DROP TABLE IF EXISTS `PRODUCT_ATTACHMENTS`;
CREATE TABLE IF NOT EXISTS `PRODUCT_ATTACHMENTS` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `id_parent_product` int(11) NOT NULL,
  `file_path` VARCHAR(150) NOT NULL,
  `file_name` VARCHAR(150) NOT NULL,
  `content_type` varchar(50) NOT NULL,
  `file_dida` text,
  `file_label` int(11) UNSIGNED NOT NULL default '0',
  `insert_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`),
  KEY `Index_1` (`id_parent_product`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;


-- --------------------------------------------------------
-- 
-- Structure of table `PRODUCT_ATTACHMENTS_DOWNLOAD`
-- 
DROP TABLE IF EXISTS `PRODUCT_ATTACHMENTS_DOWNLOAD`;
CREATE TABLE IF NOT EXISTS `PRODUCT_ATTACHMENTS_DOWNLOAD` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `id_parent_product` int(11) NOT NULL,
  `file_path` VARCHAR(150) NOT NULL,
  `file_name` VARCHAR(150) NOT NULL,
  `content_type` varchar(50) NOT NULL,
  `file_dida` text,
  `file_label` int(11) UNSIGNED NOT NULL default '0',
  `file_size` int(11) UNSIGNED NOT NULL default '0',
  `insert_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`),
  KEY `Index_1` (`id_parent_product`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;


-- --------------------------------------------------------
-- 
-- Structure of table `PRODUCT_ATTACHMENTS_LABEL`
-- 
DROP TABLE IF EXISTS `PRODUCT_ATTACHMENTS_LABEL`;
CREATE TABLE IF NOT EXISTS `PRODUCT_ATTACHMENTS_LABEL` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `description` VARCHAR(50) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `Index_1` (`description`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;


-- --------------------------------------------------------
-- 
-- Structure of table `PRODUCT_LANGUAGES`
-- 
DROP TABLE IF EXISTS `PRODUCT_LANGUAGES`;
CREATE TABLE `PRODUCT_LANGUAGES` (
  `id_language` int(11) NOT NULL,
  `id_parent_product` int(11) NOT NULL,
  PRIMARY KEY (`id_language`, `id_parent_product`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `PRODUCT_CATEGORIES`
-- 
DROP TABLE IF EXISTS `PRODUCT_CATEGORIES`;
CREATE TABLE `PRODUCT_CATEGORIES` (
  `id_category` int(11) NOT NULL,
  `id_parent_product` int(11) NOT NULL,
  PRIMARY KEY (`id_category`, `id_parent_product`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `PRODUCT_FIELDS`
-- 
DROP TABLE IF EXISTS `PRODUCT_FIELDS`;
CREATE TABLE `PRODUCT_FIELDS` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `id_parent_product` int(11) NOT NULL,
  `description` varchar(150) NOT NULL,
  `group_description` varchar(150) DEFAULT NULL,
  `type` int(11) unsigned NOT NULL,
  `type_content` int(11) unsigned NOT NULL,
  `sorting` int(3) unsigned NOT NULL DEFAULT 0,
  `required` smallint(1) UNSIGNED NOT NULL DEFAULT 0,
  `enabled` smallint(1) UNSIGNED NOT NULL DEFAULT 0,
  `max_lenght` int(3) UNSIGNED DEFAULT NULL,
  `editable` smallint(1) UNSIGNED NOT NULL DEFAULT 0,
  `common` smallint(1) UNSIGNED NOT NULL DEFAULT 0,
  `value` TEXT DEFAULT NULL,
  PRIMARY KEY  (`id`),
  KEY `Index_3` (`id_parent_product`),
  KEY `Index_4` (`type`),
  KEY `Index_5` (`value`(250))
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `PRODUCT_FIELDS_VALUES`
-- 
DROP TABLE IF EXISTS `PRODUCT_FIELDS_VALUES`;
CREATE TABLE `PRODUCT_FIELDS_VALUES` (
  `id_parent_field` int(11) unsigned NOT NULL,
  `value` varchar(250) NOT NULL,
  `sorting` int(3) unsigned NOT NULL DEFAULT 0,
  `quantity` int(10) NOT NULL,
  PRIMARY KEY  (`id_parent_field`,`value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- --------------------------------------------------------
-- 
-- Structure of table `PRODUCT_FIELDS_REL_VALUES`
-- 
DROP TABLE IF EXISTS `PRODUCT_FIELDS_REL_VALUES`;
CREATE TABLE IF NOT EXISTS `PRODUCT_FIELDS_REL_VALUES` (
  `id_product` int(11) NOT NULL,
  `id_field` int(11) NOT NULL,
  `field_val` varchar(250) NOT NULL,
  `id_field_rel` int(11) NOT NULL,
  `field_rel_val` varchar(250) NOT NULL,
  `field_rel_name` varchar(250) NOT NULL,
  `quantity` int(10) NOT NULL,
  KEY `kid_product` (`id_product`),
  KEY `kid_field` (`id_field`),
  KEY `kfield_val` (`field_val`),
  KEY `kid_field_rel` (`id_field_rel`),
  KEY `kfield_rel_val` (`field_rel_val`),
  KEY `kfield_rel_name` (`field_rel_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `PRODUCT_MAIN_FIELD_TRANSLATION`
-- 
DROP TABLE IF EXISTS `PRODUCT_MAIN_FIELD_TRANSLATION`;
CREATE TABLE IF NOT EXISTS `PRODUCT_MAIN_FIELD_TRANSLATION` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `id_prod` int(10) NOT NULL,
  `main_field` int(3) NOT NULL,
  `lang_code` varchar(2) NOT NULL,
  `value` text,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `Index_Pmft` (`id_prod`,`main_field`,`lang_code`),
  INDEX `Index_Pmfti`(`id_prod`),
  INDEX `Index_Pmftm`(`main_field`),
  INDEX `Index_Pmftl`(`lang_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `PRODUCT_FIELD_TRANSLATION`
-- 
DROP TABLE IF EXISTS `PRODUCT_FIELD_TRANSLATION`;
CREATE TABLE IF NOT EXISTS `PRODUCT_FIELD_TRANSLATION` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `id_prod` int(10) NOT NULL,
  `id_field` int(3) NOT NULL,
  `type` varchar(10) NOT NULL,
  `base_val` varchar(250) default NULL,
  `lang_code` varchar(2) NOT NULL,
  `value` text,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `Index_Pmft` (`id_prod`,`id_field`,`type`,`base_val`,`lang_code`),
  INDEX `Index_Pmfti`(`id_prod`),
  INDEX `Index_Pmftm`(`id_field`),
  INDEX `Index_Pmftt`(`type`),
  INDEX `Index_Pmftl`(`lang_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `PRODUCT_CALENDAR`
-- 
DROP TABLE IF EXISTS `PRODUCT_CALENDAR`;
CREATE TABLE IF NOT EXISTS `PRODUCT_CALENDAR` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `id_parent_product` int(11) NOT NULL,
  `start_date` timestamp NOT NULL,
  `availability` int(10) NOT NULL DEFAULT 0,  
  `unit` int(10) NOT NULL DEFAULT 0, 
  `content` text,
  PRIMARY KEY  (`id`),
  KEY `Index_1` (`id_parent_product`),
  KEY `Index_2` (`start_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;


-- --------------------------------------------------------
-- 
-- Structure of table `PRODUCT_ROTATION`
-- 
DROP TABLE IF EXISTS `PRODUCT_ROTATION`;
CREATE TABLE `PRODUCT_ROTATION` (
  `id_rotation_mode` int(11) NOT NULL,
  `id_parent_product` int(11) NOT NULL,
  `rotation_value` varchar(50),
  `last_update` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_rotation_mode`, `id_parent_product`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `PRODUCT_RELATIONS`
-- 
DROP TABLE IF EXISTS `PRODUCT_RELATIONS`;
CREATE TABLE IF NOT EXISTS `PRODUCT_RELATIONS` (
  `id_parent_product` int(11) NOT NULL,
  `id_product_rel` int(11) NOT NULL,
  UNIQUE KEY `Index_Rp` (`id_parent_product`,`id_product_rel`),
  INDEX `Index_RpP`(`id_parent_product`),
  INDEX `Index_RpPr`(`id_product_rel`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `SHOPPING_CART`
-- 
DROP TABLE IF EXISTS `SHOPPING_CART`;
CREATE TABLE IF NOT EXISTS `SHOPPING_CART` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `id_user` int(11) NOT NULL,
  `last_update` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;

-- --------------------------------------------------------
-- 
-- Structure of table `SHOPPING_CART_PRODUCT`
-- 
DROP TABLE IF EXISTS `SHOPPING_CART_PRODUCT`;
CREATE TABLE IF NOT EXISTS `SHOPPING_CART_PRODUCT` (
  `id_cart` int(11) NOT NULL,
  `id_prod` int(11) NOT NULL,
  `prod_counter` int(11) NOT NULL,
  `prod_quantity` int(10) NOT NULL,
  `prod_type` smallint(1) unsigned NOT NULL,
  `prod_name` varchar(250) NOT NULL,
  `id_ads` int(11) NOT NULL default '-1',
  PRIMARY KEY  (`id_cart`,`id_prod`,`prod_counter`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `SHOPPING_CART_PRODUCT_FIELD`
-- 
DROP TABLE IF EXISTS `SHOPPING_CART_PRODUCT_FIELD`;
CREATE TABLE IF NOT EXISTS `SHOPPING_CART_PRODUCT_FIELD` (
  `id_cart` int(11) NOT NULL,
  `id_prod` int(11) NOT NULL,
  `prod_counter` INTEGER UNSIGNED NOT NULL,
  `id_field` int(11) NOT NULL,
  `field_type` int(11) NOT NULL,
  `prod_quantity` int(10) NOT NULL,
  `value` varchar(250) NOT NULL,
  `description` varchar(150) NOT NULL,
  PRIMARY KEY  (`id_cart`,`id_prod`,`prod_counter`,`id_field`,`value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `SHOPPING_CART_PRODUCT_CALENDAR`
-- 
DROP TABLE IF EXISTS `SHOPPING_CART_PRODUCT_CALENDAR`;
CREATE TABLE IF NOT EXISTS `SHOPPING_CART_PRODUCT_CALENDAR` (
  `id_cart` int(11) NOT NULL,
  `id_prod` int(11) NOT NULL,
  `prod_counter` INTEGER UNSIGNED NOT NULL,
  `date` timestamp NOT NULL,
  `adults` int(11) NOT NULL DEFAULT '0',
  `children` int(11) NOT NULL DEFAULT '0',
  `rooms` int(11) NOT NULL DEFAULT '0',
  `children_age` varchar(100) NOT NULL,
  `search_text` varchar(250) NOT NULL,
  PRIMARY KEY  (`id_cart`,`id_prod`,`prod_counter`,`date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `ORDERS`
-- 
DROP TABLE IF EXISTS `ORDERS`;
CREATE TABLE IF NOT EXISTS `ORDERS` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `id_user` int(11) NOT NULL default '-1',
  `guid` varchar(100) NOT NULL,
  `notes` text,
  `status` int(1) unsigned NOT NULL default '0',
  `amount` DECIMAL(20,4) NOT NULL default '0.00',
  `taxable` DECIMAL(20,4) NOT NULL default '0.00',
  `supplement` decimal(20,4) NOT NULL default '0.00',
  `payment_id` int(11) unsigned NOT NULL default '0',
  `payment_commission` decimal(20,4) NOT NULL default '0.00',
  `payment_done` smallint(1) unsigned NOT NULL DEFAULT '0',
  `download_notified` smallint(1) unsigned NOT NULL DEFAULT '0',
  `no_registration` smallint(1) unsigned NOT NULL DEFAULT '0',
  `mail_sent` smallint(1) unsigned NOT NULL DEFAULT '0',
  `ads_enabled` smallint(1) unsigned NOT NULL DEFAULT '0',
  `last_update` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `insert_date` timestamp NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `Index_user` (`id_user`),
  KEY `Index_guid` (`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;


-- --------------------------------------------------------
-- 
-- Structure of table `ORDER_PRODUCTS`
-- 
DROP TABLE IF EXISTS `ORDER_PRODUCTS`;
CREATE TABLE IF NOT EXISTS `ORDER_PRODUCTS` (
  `id_order` int(11) NOT NULL,
  `id_prod` int(11) NOT NULL,
  `prod_counter` int(11) NOT NULL,
  `prod_quantity` int(11) unsigned NOT NULL,
  `prod_type` smallint(1) unsigned NOT NULL default '0',
  `prod_name` varchar(250) NOT NULL,
  `amount` DECIMAL(20,4) NOT NULL default '0.00',
  `taxable` DECIMAL(20,4) NOT NULL default '0.00',
  `supplement` decimal(20,4) NOT NULL default '0.00', 
  `discount_perc` decimal(20,4) NOT NULL default '0.00', 
  `discount` decimal(20,4) NOT NULL default '0.00', 
  `margin` decimal(20,4) NOT NULL default '0.00', 
  `supplement_desc` varchar(100) DEFAULT NULL,
  `id_ads` int(11) NOT NULL default '-1',
  PRIMARY KEY  (`id_order`,`id_prod`,`prod_counter`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	

-- --------------------------------------------------------
-- 
-- Structure of table `ORDER_PRODUCT_FIELDS`
-- 
DROP TABLE IF EXISTS `ORDER_PRODUCT_FIELDS`;
CREATE TABLE IF NOT EXISTS `ORDER_PRODUCT_FIELDS` (
  `id_order` int(11) NOT NULL,
  `id_prod` int(11) NOT NULL,
  `prod_counter` int(11) NOT NULL,
  `id_field` int(11) NOT NULL,
  `field_type` int(11) NOT NULL,
  `value` varchar(250) NOT NULL,
  `prod_quantity` int(11) NOT NULL,
  `description` varchar(250) NOT NULL,
  PRIMARY KEY  (`id_order`,`id_prod`,`prod_counter`,`id_field`,`field_type`,`value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `ORDER_PRODUCT_CALENDAR`
-- 
DROP TABLE IF EXISTS `ORDER_PRODUCT_CALENDAR`;
CREATE TABLE IF NOT EXISTS `ORDER_PRODUCT_CALENDAR` (
  `id_order` int(11) NOT NULL,
  `id_prod` int(11) NOT NULL,
  `prod_counter` INTEGER UNSIGNED NOT NULL,
  `date` timestamp NOT NULL,
  `adults` int(11) NOT NULL DEFAULT '0',
  `children` int(11) NOT NULL DEFAULT '0',
  `rooms` int(11) NOT NULL DEFAULT '0',
  `children_age` varchar(100) NOT NULL,
  `search_text` varchar(250) NOT NULL,
  PRIMARY KEY  (`id_order`,`id_prod`,`prod_counter`,`date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `ORDER_PRODUCT_ATTACHMENT_DOWNLOAD`
-- 
DROP TABLE IF EXISTS `ORDER_PRODUCT_ATTACHMENT_DOWNLOAD`;
CREATE TABLE `ORDER_PRODUCT_ATTACHMENT_DOWNLOAD` (
`id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
`id_order` INT(11) NOT NULL ,
`id_parent_product` INT(11) NOT NULL ,
`id_down_file` INT(11) NOT NULL ,
`id_user` INT(11) NOT NULL ,
`active` SMALLINT(1) UNSIGNED NOT NULL default '0',
`max_download` INT(3) NOT NULL  default '-1',
`insert_date` TIMESTAMP NOT NULL ,
`expire_date` datetime NOT NULL default '9999-12-31 23:59:59',
`download_date` datetime NOT NULL default '9999-12-31 23:59:59',
`download_counter` INT(3) UNSIGNED NOT NULL  default '0',
 PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
		

-- --------------------------------------------------------
-- 
-- Structure of table `ORDER_FEES`
-- 
DROP TABLE IF EXISTS `ORDER_FEES`;
CREATE TABLE `ORDER_FEES` (
  `id_order` INT(11) NOT NULL ,
  `id_fee` INT(11) NOT NULL ,
  `amount` DECIMAL(20,4) NOT NULL default '0.00',
  `taxable` DECIMAL(20,4) NOT NULL default '0.00',
  `supplement` decimal(20,4) NOT NULL default '0.00',  
  `fee_desc` varchar(100) DEFAULT NULL,
  `autoactive` SMALLINT(1) UNSIGNED NOT NULL default '0',
  `required` SMALLINT(1) UNSIGNED NOT NULL default '0',
  `multiply` SMALLINT(1) UNSIGNED NOT NULL default '0',
  `fee_group` VARCHAR(100) default NULL,
  `ext_provider` SMALLINT(1) NOT NULL default '0',
  `shipping_enabled` smallint(1) NOT NULL default '0',
  `shipping_response` text,
  PRIMARY KEY  (`id_order`,`id_fee`)
)ENGINE = InnoDB  DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `SHIPPING_ADDRESS`
-- 
DROP TABLE IF EXISTS `SHIPPING_ADDRESS`;
CREATE TABLE IF NOT EXISTS `SHIPPING_ADDRESS` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `id_user` int(11) NOT NULL,
  `name` varchar(100) default NULL,
  `surname` varchar(100) default NULL,
  `cfiscvat` varchar(30) default NULL,
  `address` varchar(250) default NULL,
  `city` varchar(100) default NULL,
  `zip_code` varchar(20) default NULL,
  `country` varchar(100) default NULL,
  `state_region` varchar(100) default NULL,
  `is_company_client` SMALLINT(1) UNSIGNED NOT NULL default '0',  
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `ORDER_SHIPPING_ADDRESS`
-- 
DROP TABLE IF EXISTS `ORDER_SHIPPING_ADDRESS`;
CREATE TABLE IF NOT EXISTS `ORDER_SHIPPING_ADDRESS` (
  `id_order` int(11) NOT NULL,
  `name` varchar(100) default NULL,
  `surname` varchar(100) default NULL,
  `cfiscvat` varchar(30) default NULL,
  `address` varchar(250) default NULL,
  `city` varchar(100) default NULL,
  `zip_code` varchar(20) default NULL,
  `country` varchar(100) default NULL,
  `state_region` varchar(100) default NULL,
  `is_company_client` SMALLINT(1) UNSIGNED NOT NULL default '0',
  PRIMARY KEY (`id_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `BILLS_ADDRESS`
-- 
DROP TABLE IF EXISTS `BILLS_ADDRESS`;
CREATE TABLE IF NOT EXISTS `BILLS_ADDRESS` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `id_user` int(11) NOT NULL,
  `name` varchar(100) default NULL,
  `surname` varchar(100) default NULL,
  `cfiscvat` varchar(30) default NULL,
  `address` varchar(250) default NULL,
  `city` varchar(100) default NULL,
  `zip_code` varchar(20) default NULL,
  `country` varchar(100) default NULL,
  `state_region` varchar(100) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `ORDER_BILLS_ADDRESS`
-- 
DROP TABLE IF EXISTS `ORDER_BILLS_ADDRESS`;
CREATE TABLE IF NOT EXISTS `ORDER_BILLS_ADDRESS` (
  `id_order` int(11) NOT NULL,
  `name` varchar(100) default NULL,
  `surname` varchar(100) default NULL,
  `cfiscvat` varchar(30) default NULL,
  `address` varchar(250) default NULL,
  `city` varchar(100) default NULL,
  `zip_code` varchar(20) default NULL,
  `country` varchar(100) default NULL,
  `state_region` varchar(100) default NULL,
  PRIMARY KEY (`id_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `BILLING`
-- 
DROP TABLE IF EXISTS `BILLING`;
CREATE TABLE IF NOT EXISTS `BILLING` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `id_parent_order` int(11) NOT NULL,
  `order_amount` DECIMAL(20,4) NOT NULL default '0.00',
  `name` varchar(100) default NULL,
  `cfiscvat` varchar(30) default NULL,
  `address` varchar(250) default NULL,
  `city` varchar(100) default NULL,
  `zip_code` varchar(20) default NULL,
  `country` varchar(100) default NULL,
  `state_region` varchar(100) default NULL,
  `phone` varchar(50) default NULL,
  `fax` varchar(50) default NULL,
  `description` text,
  `last_update` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `insert_date` timestamp NOT NULL,
  `order_date` timestamp NOT NULL,
  `id_registered_billing` int(11) NOT NULL default '0',
  `registered_date` timestamp NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `BILLING_DATA`
-- 
DROP TABLE IF EXISTS `BILLING_DATA`;
CREATE TABLE IF NOT EXISTS `BILLING_DATA` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `name` varchar(100) default NULL,
  `cfiscvat` varchar(30) default NULL,
  `address` varchar(250) default NULL,
  `city` varchar(100) default NULL,
  `zip_code` varchar(20) default NULL,
  `country` varchar(100) default NULL,
  `state_region` varchar(100) default NULL,
  `phone` varchar(50) default NULL,
  `fax` varchar(50) default NULL,
  `description` text,
  `file_path` varchar(250) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `BUSINESS_RULE`
-- 
DROP TABLE IF EXISTS `BUSINESS_RULE`;
CREATE TABLE IF NOT EXISTS `BUSINESS_RULE` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `rule_type` int(10) unsigned NOT NULL,
  `label` varchar(100) NOT NULL,
  `description` text,
  `active` smallint(1) unsigned NOT NULL default '0',
  `voucher_id` int(10) NOT NULL default '-1',
  PRIMARY KEY  (`id`),
  KEY `Index_label` (`label`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `BUSINESS_RULE_CONFIG`
-- 
DROP TABLE IF EXISTS `BUSINESS_RULE_CONFIG`;
CREATE TABLE IF NOT EXISTS `BUSINESS_RULE_CONFIG` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `id_rule` int(11) NOT NULL,
  `id_product` int(11) NOT NULL default '-1',
  `id_product_ref` int(10) NOT NULL default '-1',
  `rate_from` decimal(20,4) NOT NULL default '0.00',
  `rate_to` decimal(20,4) NOT NULL default '0.00',
  `rate_from_ref` decimal(20,4) NOT NULL default '0.00',
  `rate_to_ref` decimal(20,4) NOT NULL default '0.00',
  `operation` smallint(1) unsigned NOT NULL default '0' COMMENT 'tipo di operatione da eseguire: 0 nulla, 1 somma, 2 sottrazione;',
  `applyto` smallint(1) unsigned NOT NULL default '0' COMMENT 'a chi deve essere applicata la regola: 0 nulla, 1 a prod_orig, 2 a prod_ref, 3 al meno caro, 4 al più caro, 5 a tutti e due;',
  `apply_to_quantity` int(10) unsigned NOT NULL default '0' COMMENT 'per quale quantità  deve essere applicata la regola',
  `value` decimal(20,4) NOT NULL default '0.00',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `Index_U` (`id_rule`,`id_product`,`rate_from`,`rate_to`,`id_product_ref`),
  KEY `Index_From` (`rate_from`),
  KEY `Index_To` (`rate_to`),
  KEY `Index_Val` (`value`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `ORDER_BUSINESS_RULES`
-- 
DROP TABLE IF EXISTS `ORDER_BUSINESS_RULES`;
CREATE TABLE IF NOT EXISTS `ORDER_BUSINESS_RULES` (
  `id_rule` int(11) NOT NULL,
  `id_order` int(11) NOT NULL,
  `id_product` int(11) NOT NULL default '-1',
  `product_counter` int(11) unsigned NOT NULL default '0',
  `rule_type` int(10) unsigned NOT NULL,
  `label` VARCHAR(100) NOT NULL,
  `value` DECIMAL(20,4) NOT NULL,   
  PRIMARY KEY (`id_rule`,`id_order`,`id_product`,`product_counter`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `ADS`
-- 
DROP TABLE IF EXISTS `ADS`;
CREATE TABLE IF NOT EXISTS `ADS` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `id_element` int(11) NOT NULL,
  `id_user` int(11) NOT NULL,
  `phone` varchar(100) DEFAULT NULL,
  `type` int(1) unsigned NOT NULL default '0',
  `price` decimal(20,4) DEFAULT NULL,
  `insert_date` timestamp NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `ADS_PROMOTION`
-- 
DROP TABLE IF EXISTS `ADS_PROMOTION`;
CREATE TABLE IF NOT EXISTS `ADS_PROMOTION` (
  `id_ads` int(11) NOT NULL,
  `id_element` int(11) NOT NULL,
  `cod_element` VARCHAR(100) NOT NULL,
  `active` SMALLINT(1) UNSIGNED NOT NULL default '0',
  `insert_date` timestamp NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id_ads`,`id_element`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `VOUCHER_CAMPAIGN`
-- 
DROP TABLE IF EXISTS `VOUCHER_CAMPAIGN`;
CREATE TABLE IF NOT EXISTS `VOUCHER_CAMPAIGN` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `label` varchar(100) NOT NULL,
  `voucher_type` int(10) unsigned NOT NULL default '0' COMMENT 'tipo di voucher creato - 0=one shot, 1=per x volte, 2=one shot entro il periodo specificato, 3=per x volte entro il periodo specificato, 4=gift (come one shot ma con id_utente che ha fatto il regalo associato al voucher)',
  `description` text,
  `voucher_amount` decimal(20,4) NOT NULL,
  `operation` smallint(1) unsigned NOT NULL default '0' COMMENT 'tipo di calcolo applicato - 0=percentuale, 1=fisso',
  `active` smallint(1) unsigned NOT NULL default '0',
  `max_generation` int(10) NOT NULL default '-1',
  `max_usage` int(10) NOT NULL default '-1',
  `enable_date` datetime NOT NULL default '9999-12-31 23:59:59',
  `expire_date` datetime NOT NULL default '9999-12-31 23:59:59',
  `exclude_prod_rule` smallint(1) unsigned NOT NULL default '0',
  PRIMARY KEY  (`id`),
  KEY `Index_label` (`label`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `VOUCHER_CODE`
-- 
DROP TABLE IF EXISTS `VOUCHER_CODE`;
CREATE TABLE IF NOT EXISTS `VOUCHER_CODE` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `code` varchar(100) NOT NULL COMMENT 'il codice voucher verrà generato con un nuovo GUID ad hoc',
  `voucher_campaign` int(10) NOT NULL,
  `insert_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `usage_counter` int(10) unsigned NOT NULL default '0',
  `id_user` int(10) unsigned default NULL,
  PRIMARY KEY  (`id`,`code`),
  KEY `Index_vc` (`voucher_campaign`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;


-- --------------------------------------------------------
-- 
-- Structure of table `ORDER_VOUCHERS`
-- 
DROP TABLE IF EXISTS `ORDER_VOUCHERS`;
CREATE TABLE IF NOT EXISTS `ORDER_VOUCHERS` (
  `id_order` int(11) NOT NULL,
  `id_voucher` int(11) NOT NULL,
  `voucher_code` varchar(100) NOT NULL,
  `voucher_amount` decimal(20,4) NOT NULL,
  `insert_date` TIMESTAMP NOT NULL ,
  PRIMARY KEY  (`id_order`,`voucher_code`,`id_voucher`, `insert_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;