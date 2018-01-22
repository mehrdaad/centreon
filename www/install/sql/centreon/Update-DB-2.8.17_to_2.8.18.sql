-- Change version of Centreon
UPDATE `informations` SET `value` = '2.8.18' WHERE CONVERT( `informations`.`key` USING utf8 ) = 'version' AND CONVERT ( `informations`.`value` USING utf8 ) = '2.8.17' LIMIT 1;


-- lua custom output for centreon-broker
ALTER TABLE `cb_type_field_relation` ADD COLUMN `jshook_name` VARCHAR(255) DEFAULT NULL;
ALTER TABLE `cb_type_field_relation` ADD COLUMN `jshook_arguments` VARCHAR(255) DEFAULT NULL;


INSERT INTO `cb_module` (`name`, `libname`, `loading_pos`, `is_activated`) VALUES ('Lua', 'lua.so', 40,1);

INSERT INTO `cb_type` (`type_name`, `type_shortname`, `cb_module_id`)
VALUES ('Lua script', 'custom', (SELECT `cb_module_id` FROM `cb_module` WHERE `libname` = 'Lua.so'));

INSERT INTO `cb_fieldgroup` (`groupname`, `displayname`, `multiple`, `group_parent_id`)
VALUES ('metrics_lua', 'metrics Lua', 1, NULL);

INSERT INTO `cb_field` (`fieldname`, `displayname`, `description`, `fieldtype`, `external`, `cb_fieldgroup_id`)
VALUES
('path', 'Path', 'Path of the lua script.', 'text', NULL, NULL),
('type', 'Type', 'Type of the metric.', 'select', NULL, (SELECT `cb_fieldgroup_id` FROM `cb_fieldgroup` WHERE `groupname` = 'metrics_lua')),
('name', 'Name', 'Name of the metric.', 'text', NULL, (SELECT `cb_fieldgroup_id` FROM `cb_fieldgroup` WHERE `groupname` = 'metrics_lua')),
('value', 'Value', 'Value of the metric.', 'text', NULL, (SELECT `cb_fieldgroup_id` FROM `cb_fieldgroup` WHERE `groupname` = 'metrics_lua'));

INSERT INTO `cb_type_field_relation` (`cb_type_id`, `cb_field_id`, `is_required`, `order_display`, `jshook_name`, `jshook_arguments`)
VALUES (
(SELECT `cb_type_id` FROM `cb_type` WHERE `type_shortname` = 'custom'),
(SELECT `cb_field_id` FROM `cb_field` WHERE `description` = 'Path of the lua script.'),
1, 1, NULL, NULL),
((SELECT `cb_type_id` FROM `cb_type` WHERE `type_shortname` = 'custom'),
(SELECT `cb_field_id` FROM `cb_field` WHERE `description` = 'Type of the metric.'),
0, 5, 'luaArguments', '{"target": "metrics_lua__value_%d"}'),
((SELECT `cb_type_id` FROM `cb_type` WHERE `type_shortname` = 'custom'),
(SELECT `cb_field_id` FROM `cb_field` WHERE `description` = 'Name of the metric.'),
0, 4, NULL, NULL),
((SELECT `cb_type_id` FROM `cb_type` WHERE `type_shortname` = 'custom'),
(SELECT `cb_field_id` FROM `cb_field` WHERE `description` = 'Value of the metric.'),
0, 3, NULL, NULL);

INSERT INTO `cb_list` (`cb_field_id`, `default_value`)
VALUES((SELECT `cb_field_id` FROM `cb_field` WHERE `description` = 'Type of the metric.'), 'string');

INSERT INTO `cb_list_values` (`cb_list_id`, `value_name`, `value_value`)
VALUES
((SELECT `cb_list_id` FROM `cb_list` WHERE `cb_field_id` =
  (SELECT `cb_field_id` FROM `cb_field` WHERE `description` = 'Type of the metric.')), 'String', 'string'
),
((SELECT `cb_list_id` FROM `cb_list` WHERE `cb_field_id` =
  (SELECT `cb_field_id` FROM `cb_field` WHERE `description` = 'Type of the metric.')), 'Number', 'number'
),
((SELECT `cb_list_id` FROM `cb_list` WHERE `cb_field_id` =
  (SELECT `cb_field_id` FROM `cb_field` WHERE `description` = 'Type of the metric.')), 'Password', 'password'
),
((SELECT `cb_list_id` FROM `cb_list` WHERE `cb_field_id` =
  (SELECT `cb_field_id` FROM `cb_field` WHERE `description` = 'Type of the metric.')), 'Hostgroup', 'hostgroup'
),
((SELECT `cb_list_id` FROM `cb_list` WHERE `cb_field_id` =
  (SELECT `cb_field_id` FROM `cb_field` WHERE `description` = 'Type of the metric.')), 'Servicegroup', 'servicegroup'
),
((SELECT `cb_list_id` FROM `cb_list` WHERE `cb_field_id` =
  (SELECT `cb_field_id` FROM `cb_field` WHERE `description` = 'Type of the metric.')), 'Ba', 'ba'
),
((SELECT `cb_list_id` FROM `cb_list` WHERE `cb_field_id` =
  (SELECT `cb_field_id` FROM `cb_field` WHERE `description` = 'Type of the metric.')), 'Timeperiod', 'timeperiod'
);

INSERT INTO `cb_tag_type_relation` (`cb_tag_id`, `cb_type_id`, `cb_type_uniq`)
 VALUES (1, (SELECT `cb_type_id` FROM `cb_type` WHERE `type_shortname` = 'custom'), 0);
