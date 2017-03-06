Feature: Container can start
  In order to be sure of a stable image before I use it
  As an image user
  I want a container using the image to be able to start

Scenario Outline: Container can start
  Given I have pulled the image <image_name>
  When I start a container based on the image
  Then the container should start successfully

  Examples:
    | image_name           |
    | drupal8_apache       |
    | drupal8_solr_4_10    |
    | drupal8_solr_6_2     |
    | drupal8_varnish      |
    | ez                   |
    | hem                  |
    | magento1_nginx       |
    | magento2_nginx       |
    | magento2_varnish     |
    | mailcatcher          |
    | memcached            |
    | mongodb34            |
    | mysql80              |
    | mysql57              |
    | mysql56              |
    | nginx                |
    | nginx_reverse_proxy  |
    | nodejs6              |
    | nodejs6_small        |
    | nodejs7              |
    | nodejs7_small        |
    | phantomjs2           |
    | php71_apache         |
    | php70_apache         |
    | php56_apache         |
    | php71_nginx          |
    | php70_nginx          |
    | php56_nginx          |
    | scala_sbt            |
    | redis                |
    | elasticsearch        |
    | solr_4_10            |
    | solr_6_2             |
    | symfony_php71_nginx  |
    | symfony_php70_nginx  |
    | symfony_php56_nginx  |
    | symfony_php71_apache |
    | symfony_php70_apache |
    | symfony_php56_apache |
    | ubuntu               |
    | varnish              |
