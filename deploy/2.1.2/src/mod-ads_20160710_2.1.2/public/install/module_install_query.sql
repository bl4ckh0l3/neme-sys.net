INSERT INTO `MODULES` (`keyword`, `description`, `version`, `active`) VALUES ('mod-ads', 'ads module installation', '2.1.2', '1');
INSERT INTO `MAIL` (`id`, `name`, `description`, `lang_code`, `receiver`, `sender`, `cc`, `bcc`, `priority`, `subject`, `body`, `active`, `body_html`, `base`, `modify_date`, `mail_category`) VALUES(19, 'ads-contact-mail', 'Mail di invio richiesta informazioni per un annuncio pubblicato', '', '', 'info@neme-sys.it', '', '', 1, 'neme-sys .net - richiesta informazioni annuncio', '<html dir="ltr">\r\n    <head>\r\n        <title></title>\r\n    </head>\r\n    <body>\r\n        [#content#]<br />\r\n    </body>\r\n</html>', 1, 1, 1, '2015-11-27 21:13:39', 'comunicazioni utente');