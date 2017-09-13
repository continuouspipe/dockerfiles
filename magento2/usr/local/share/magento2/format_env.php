<?php

require_once('/app/vendor/magento/framework/App/DeploymentConfig/Writer/FormatterInterface.php');
require_once('/app/vendor/magento/framework/App/DeploymentConfig/Writer/PhpFormatter.php');

$config = require('/app/app/etc/env.php');
$formatter = new \Magento\Framework\App\DeploymentConfig\Writer\PhpFormatter();
$formattedConfig = $formatter->format($config);
if ($formattedConfig) {
  file_put_contents('/app/app/etc/env.php', $formattedConfig);
}
