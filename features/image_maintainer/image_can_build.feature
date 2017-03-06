Feature: Image can build
  In order to release new image versions
  As an image maintainer
  I want the images to build successfully

Scenario Outline: Image can build
  Given the image <image_name> has dependencies <image_dependencies>
  When I build the image and it's dependencies
  Then the build should complete successfully

  Examples:
    | image_name           | image_dependencies  |
    | drupal8_apache       | ubuntu,php70_apache |
    | drupal8_solr_4_10    | solr_4_10           |
    | drupal8_solr_6_2     | solr_6_2            |
    | drupal8_varnish      | ubuntu,varnish4     |
    | ez                   | ubuntu,php70_apache |
    | hem                  | ubuntu              |
    | magento1_nginx       | ubuntu,php56_nginx  |
    | magento2_nginx       | ubuntu,php70_nginx  |
    | magento2_varnish     | ubuntu,varnish4     |
    | mailcatcher          | ubuntu              |
    | memcached            | ubuntu              |
    | mongodb34            | ubuntu              |
    | mysql80              |                     |
    | mysql57              |                     |
    | mysql56              |                     |
    | nginx                | ubuntu              |
    | nginx_reverse_proxy  | ubuntu,nginx        |
    | nodejs6              | ubuntu              |
    | nodejs6_small        | ubuntu              |
    | nodejs7              | ubuntu              |
    | nodejs7_small        | ubuntu              |
    | phantomjs2           | ubuntu              |
    | php71_apache         | ubuntu              |
    | php70_apache         | ubuntu              |
    | php56_apache         | ubuntu              |
    | php71_nginx          | ubuntu              |
    | php70_nginx          | ubuntu              |
    | php56_nginx          | ubuntu              |
    | scala_sbt            | ubuntu              |
    | redis                |                     |
    | elasticsearch        |                     |
    | solr_4_10            |                     |
    | solr_6_2             |                     |
    | symfony_php71_nginx  | ubuntu,php71_nginx  |
    | symfony_php70_nginx  | ubuntu,php70_nginx  |
    | symfony_php56_nginx  | ubuntu,php56_nginx  |
    | symfony_php71_apache | ubuntu,php71_apache |
    | symfony_php70_apache | ubuntu,php70_apache |
    | symfony_php56_apache | ubuntu,php56_apache |
    | ubuntu               |                     |
    | varnish              |                     |

Scenario Outline: Built container can start
  Given I have built the image <image_name>
  When I start a container based on the image
  Then The container should start successfully

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
